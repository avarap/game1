# Visual scale validation handoff — #94 → #109

The architecture decision in #94 selects **64×96 native frames** as the default production target for the player and key NPCs, with 48×72 allowed only when in-game evidence proves equivalent perceptual quality. The current 32×48 hero baseline is considered a functional placeholder.

`main` now includes the reproducible visual-capture tooling from #96 / PR #108. The remaining perceptual proof is intentionally separated from architecture ownership into #109 `[AUTO][CHARACTERS][P0] 64x96 hero benchmark and in-game scale proof (#94)`.

#109 must author native 48×72 and 64×96 alternatives, keep collision/navigation independent from visible canvas size, and use the #96 toolchain to compare the current 32×48 baseline against both candidates at 1280×720 and candidate camera zooms 1.0, 1.25 and 1.5. The screenshots under `docs/` remain the official human-review benchmark.

This split allows #94 to close as the architecture/pipeline decision without pretending that architecture diagrams are final visual evidence. Final player/character acceptance remains blocked on #109 and the later visual gates #31/#70.
