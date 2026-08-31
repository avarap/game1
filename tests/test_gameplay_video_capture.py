from pathlib import Path


def require_token(text: str, token: str, label: str) -> None:
    assert token in text, f"Missing {label}: {token}"


def test_gameplay_video_capture_contract() -> None:
    runner = Path("tools/gameplay_capture/gameplay_capture.gd")
    workflow = Path(".github/workflows/gameplay-video.yml")

    assert runner.exists(), "Gameplay capture runner must exist"
    assert workflow.exists(), "Gameplay video workflow must exist"

    runner_text = runner.read_text(encoding="utf-8")
    workflow_text = workflow.read_text(encoding="utf-8")

    require_token(runner_text, 'res://main.tscn', "real main scene capture")
    require_token(runner_text, 'Input.action_press', "real gameplay input driving")
    require_token(runner_text, 'Input.action_release', "input cleanup")
    require_token(runner_text, 'quit(0)', "deterministic capture termination")

    require_token(workflow_text, 'Godot_v4.7.2-stable_linux.x86_64.zip', "Godot 4.7.2 pin")
    require_token(workflow_text, '--write-movie', "Godot Movie Maker recording")
    require_token(workflow_text, 'ffmpeg', "MP4 conversion")
    require_token(workflow_text, 'actions/upload-artifact@v4', "artifact upload")
    require_token(workflow_text, '1280x720', "capture resolution metadata")


if __name__ == "__main__":
    test_gameplay_video_capture_contract()
    print("gameplay video capture contract: ok")
