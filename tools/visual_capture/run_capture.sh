#!/usr/bin/env bash
set -euo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
VERSION="$($GODOT_BIN --version)"
if [[ "$VERSION" != 4.7.2* ]]; then
  echo "Expected Godot 4.7.2, got: $VERSION" >&2
  exit 2
fi

SHA="${VISUAL_CAPTURE_SHA:-$(git rev-parse HEAD)}"
OUTPUT="${1:-$PWD/.visual-captures/$SHA}"
mkdir -p "$OUTPUT"

"$GODOT_BIN" --path . --script tools/visual_capture/capture_runner.gd -- \
  "--sha=$SHA" \
  "--output=$OUTPUT"

echo "Visual captures: $OUTPUT"
