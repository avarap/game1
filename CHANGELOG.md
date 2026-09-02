# CHANGELOG

## Unreleased

### Added
- `GAME1_RULES.md` as project-specific production contract.
- `.agents/skills/orchestrating-game-production/SKILL.md` as the reusable orchestration process.
- Canonical workstream model: MAP #139, PLAYER #140, INTEGRATION #138.
- Specialized pixel-art production pipeline: art direction -> concept/base -> pixel cleanup -> asset-system assembly -> Godot integration -> 1280x720 capture -> visual critique/revision.
- Explicit treatment of `world/maps/verdant_test/` as an isolated visual sandbox, not production world content.

### Changed
- Main-map policy: previous main-map layout/composition/patterns/distribution/spatial design are discarded and may not be reused.
- Completion policy: CI/tests alone are insufficient for gameplay or visual acceptance.
- Branch policy: one domain, one canonical branch/PR; integration is separate from feature implementation.
- Cleanup policy: superseded branch refs must be deleted once safe. Repointing to a canonical SHA is only temporary containment and remains cleanup debt.
- Integration policy: #138 remains parked/closed until MAP and PLAYER satisfy their actual gates; merge status alone is not acceptance.
- Operational documentation refreshed around the real merged-but-unaccepted production state.

### Current Work / Gates
- MAP #139 — merged to `main` on 2026-09-02. Pre-merge technical CI was green, but visual gate was still rejected. Current debt: authored terrain/path system, elimination of visible grid/banding/repetition, stronger landmarks/depth and accepted 1280x720 recapture.
- PLAYER #140 — merged to `main` on 2026-09-02 despite a red pre-merge CI. `main` still contains procedural character-frame generation in `PlayerVisual`; current debt: full technical green, authored/pixel-cleaned atlas, real 8-direction idle/walk/run/interact and 1280x720 gameplay evidence.
- INTEGRATION #138 — parked/closed. Do not reactivate until the merged MAP and PLAYER states are actually accepted. Then reopen the same PR and keep only cross-domain deltas.
- Historical stale refs currently appear again in the GitHub branch list. They must not receive new work; treat them as hygiene debt rather than as active workstreams.

### Historical foundations retained
- Fases 0–7 completed.
- Godot 4.7.2 remains the runtime/CI target.
- Existing gameplay systems remain the technical foundation unless intentionally replaced through the governed production path.
- Existing capture/testing infrastructure remains reusable where it satisfies current gates.

### Visual quality decisions
- Pixel art must read as authored game art, not a generic generated image, vector blockout or procedural texture field.
- Generated/concept art is source material only until pixel cleanup and in-game integration/review.
- Real gameplay screenshots/video are mandatory evidence for visual acceptance.
- Grid logic may remain technical, but visible composition must avoid obvious tile repetition, mathematical distribution, uniform spacing and prototype geometry.

### Cleanup decisions
- PRs #134, #135, #136, #137 and #126 were superseded/closed during consolidation.
- #139 and #140 are merged but remain unaccepted until their missing gates are satisfied.
- PR #138 is not superseded; it remains parked/closed until integration should actually start, and must be reopened rather than replaced.
