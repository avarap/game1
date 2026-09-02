# CHANGELOG

## Unreleased

### Added
- `GAME1_RULES.md` as project-specific production contract.
- `.agents/skills/orchestrating-game-production/SKILL.md` as reusable orchestration process.
- Specialized pixel-art production pipeline: art direction -> concept/base -> pixel cleanup -> asset-system assembly -> Godot integration -> 1280x720 capture -> critique/revision.
- Explicit remediation lifecycle for premature merges: canonical identity is the domain branch; a merged-but-unaccepted domain continues through one sequential remediation PR on that same branch.

### Changed
- Governance no longer binds canonical identity permanently to PR #139/#140. Those PRs are historical merged surfaces; MAP/PLAYER remediation reuses their existing canonical branches.
- Maximum one open implementation/remediation PR per domain; parallel domain branches remain forbidden.
- #138 remains integration-only and PARKED/CLOSED until MAP and PLAYER are accepted.
- Merged != accepted remains mandatory; technical/gameplay/visual gates are unchanged.
- Cleanup historical no longer creates a production deadlock when stale refs are verified as containing no unique work.

### Current Work / Gates
- PLAYER — canonical branch `character/player-controller-polish-20260902`. Priority: fix formatting/bootstrap regressions, remove procedural character-frame generation, integrate authored/pixel-cleaned 8-direction idle/walk/run/interact and prove gameplay at 1280x720.
- MAP — canonical branch `feat/main-map-rebuild-commercial-pass`. Maintain technical green; replace visible grid/repetition/orthogonal path language with authored terrain/path transitions, stronger landmarks/depth and accepted 1280x720 recapture.
- INTEGRATION #138 — PARKED/CLOSED. Reopen the same PR only after both domain remediation gates pass.

### Cleanup decisions
- PRs #134, #135, #136, #137 and #126 remain superseded/closed.
- #139 and #140 are historical merged PRs, not active implementation surfaces.
- Stale refs checked during governance cleanup were `ahead_by=0` relative to `main`; no unique work required porting.
- Because the connected GitHub tooling does not expose ref deletion, stale refs were contained by repointing to `main`. Physical deletion remains hygiene debt and must not be described as fully cleaned.

### Historical foundations retained
- Fases 0–7 completed.
- Godot 4.7.2 remains runtime/CI target.
- Previous main-map composition remains discarded.
- Tests alone never establish visual/gameplay acceptance.
