from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github/workflows/ci.yml"
RUNNER = ROOT / "tools/gameplay_capture/gameplay_video_runner.gd"


def test_gameplay_video_runner_exists() -> None:
    assert RUNNER.is_file(), "gameplay video runner must exist"


def test_ci_records_real_gameplay_mp4() -> None:
    workflow = WORKFLOW.read_text(encoding="utf-8")
    assert "gameplay-video" in workflow
    assert "ffmpeg" in workflow
    assert "gameplay.mp4" in workflow
    assert "gameplay_video_runner.gd" in workflow
    assert "x11grab" in workflow


def test_runner_drives_walk_run_and_interaction() -> None:
    source = RUNNER.read_text(encoding="utf-8")
    assert 'Input.action_press("move_' in source
    assert 'Input.action_press("run")' in source
    assert 'Input.action_press("interact")' in source
    assert "1280" in source and "720" in source
