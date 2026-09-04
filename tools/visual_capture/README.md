# Visual capture runner

This tool produces deterministic in-game evidence for visual review. It does not score or approve art automatically; compare the generated captures manually against the reference screenshots in `docs/`.

## Requirements

- Godot 4.7.2 available as `godot`, or set `GODOT_BIN`.
- Run from the repository root with a graphical display available.

## Command

```bash
bash tools/visual_capture/run_capture.sh
```

Optional output directory:

```bash
bash tools/visual_capture/run_capture.sh /tmp/game1-visual-captures
```

The default output is `.visual-captures/<git-sha>/`. Each run writes deterministic PNG names plus `capture_metadata.json` containing the commit SHA, source scene, viewport size and camera zoom. Character entries also record their authored state, look direction and selected review frame.

The player evidence set contains 32 captures: eight idle views named `player_<direction>.png`, then eight views each for walk, run and interact named `player_<state>_<direction>.png`. The manifest also captures Brother Aldren in all eight directions in cemetery context, cemetery day/night, the workshop/prop area, and representative inventory, storage, crafting and trade UI states. The runner uses 1280x720 and the same 1.5x camera zoom validated from `player/player.tscn`.

CI checks the manifest, scene loadability, camera contract and runner resources, then renders the complete evidence set and uploads it as the `cemetery-visual-captures` artifact. The PNGs are review evidence, not an automatic visual approval signal.
