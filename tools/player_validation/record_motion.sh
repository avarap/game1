#!/usr/bin/env bash
# Run inside an existing 1280x720 X display. Never substitute a posed sprite.
set -euo pipefail

output="${1:-artifacts/player_motion}"
actual_sha="$(git rev-parse HEAD)"
git diff --quiet HEAD --
test "${PLAYER_CAPTURE_SHA:-$actual_sha}" = "$actual_sha"
export PLAYER_CAPTURE_SHA="$actual_sha"
mkdir -p "$output"
scratch="$(mktemp -d "$output/recorder-XXXXXX")"
mkfifo "$scratch/input"
exec 3<>"$scratch/input"
recorder=""
cleanup() {
  if [[ -n "$recorder" ]] && kill -0 "$recorder" 2>/dev/null; then
    kill -TERM "$recorder" 2>/dev/null || true
    wait "$recorder" 2>/dev/null || true
  fi
  exec 3>&-
  rm -f "$scratch/input"
  rmdir "$scratch"
}
trap cleanup EXIT

ffmpeg -hide_banner -loglevel warning -y \
  -f x11grab -video_size 1280x720 -framerate 30 -i "$DISPLAY" \
  -an -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p \
  "$output/player_motion.mp4" <&3 >"$output/ffmpeg.log" 2>&1 &
recorder=$!
sleep 0.4
kill -0 "$recorder"
started="$(date +%s.%N)"
set +e
timeout 45s godot --path . --max-fps 30 \
  --rendering-method gl_compatibility --display-driver x11 \
  --script res://tests/test_player_phase_runtime.gd 2>&1 | tee "$output/runtime.log"
game_status=${PIPESTATUS[0]}
set -e
finished="$(date +%s.%N)"
# A nonempty/truncated MP4 is not evidence of the completed scenario.
kill -0 "$recorder"
printf 'q\n' >&3
wait "$recorder"
recorder=""
test "$game_status" -eq 0
ffprobe -v error -show_streams -show_format -of json \
  "$output/player_motion.mp4" >"$output/video_probe.json"
ffmpeg -v error -xerror -i "$output/player_motion.mp4" -f null - \
  >"$output/decode.log" 2>&1
python3 - "$output" "$started" "$finished" <<'PY'
import json
import os
from pathlib import Path
import sys

output = Path(sys.argv[1])
elapsed = float(sys.argv[3]) - float(sys.argv[2])
probe = json.loads((output / "video_probe.json").read_text())
stream = next(s for s in probe["streams"] if s["codec_type"] == "video")
duration = float(probe["format"]["duration"])
assert (stream["width"], stream["height"]) == (1280, 720), stream
assert duration >= 6.0 and duration + 0.3 >= elapsed, (duration, elapsed)
prefix = "[PLAYER_PHASE_RUNTIME] "
summaries = [line[len(prefix):] for line in (output / "runtime.log").read_text().splitlines()
             if line.startswith(prefix)]
assert len(summaries) == 1, "Missing completed runtime summary"
summary = json.loads(summaries[0])
assert summary["executed_commit"] == os.environ["PLAYER_CAPTURE_SHA"]
assert not summary["failures"], summary["failures"]
assert summary["phase_checks"] == 16 and summary["action_start_checks"] == 2
summary["video_duration_seconds"] = duration
summary["game_wall_seconds"] = elapsed
summary["video_decoded_without_errors"] = True
(output / "metadata.json").write_text(json.dumps(summary, indent=2) + "\n")
print("Verified complete player-motion recording:", summary["executed_commit"])
PY
