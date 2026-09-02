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
- Operational documentation (`DEV_MEMORY.md`, `ROADMAP.md`, `README.md`, `CHANGELOG.md`) refreshed around the current canonical production flow.

### Current Work / Gates
- MAP #139 — `feat/main-map-rebuild-commercial-pass`: draft/open. Must reach authored commercial-quality composition, functional navigation/collisions/interactions, technical gates and real 1280x720 visual evidence.
- PLAYER #140 — `character/player-controller-polish-20260902`: draft/open. Must reach commercial locomotion/animation/interactions and real verification on the rebuilt map; run=accelerated-walk is not final acceptance.
- INTEGRATION #138 — `automation/supervisor-player-map-integration`: draft/open. Reserved for cross-domain integration/regressions only.
- Duplicate historical branch refs remain a known cleanup debt until they can be physically deleted through tooling that supports remote-ref deletion.

### Historical foundations retained
- Fases 0–7 completed.
- Godot 4.7.2 remains the runtime/CI target.
- Existing gameplay systems for movement, inventory, energy, crafting, cemetery, time/sleep, NPCs, dialogue, relationships, quests, economy, technology and modular world remain the technical foundation unless a canonical workstream intentionally replaces them.
- Existing capture/testing infrastructure remains reusable where it satisfies current gates.

### Visual quality decisions
- Pixel art must read as authored game art, not a generic generated image, vector blockout or procedural texture field.
- Generated/concept art is source material only until pixel cleanup and in-game integration/review.
- Real gameplay screenshots/video are mandatory evidence for visual acceptance.
- Grid logic may remain technical, but visible composition must avoid obvious tile repetition, mathematical distribution, uniform spacing and prototype geometry.

### Cleanup decisions
- PRs #134, #135, #136, #137 and #126 were superseded/closed during consolidation.
- Their historical branches must not be used for new work.
- If deletion tooling is unavailable, temporary ref neutralization may prevent divergent implementation, but the repository is not considered fully cleaned until those refs are deleted.
