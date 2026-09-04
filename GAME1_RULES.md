# game1 Production Rules

This file contains project-specific rules consumed by the generic `orchestrating-game-production` skill.

## Canonical workstreams

Canonical identity is the branch, not a historical PR number.

- Map canonical branch: `feat/main-map-rebuild-commercial-pass`
  - historical merged PR: #139
  - current state: merged-but-unaccepted; requires one sequential remediation PR on this same branch after the branch is moved to current `main`.
- Player canonical branch: `character/player-controller-polish-20260902`
  - historical merged PR: #140
  - current state: merged-but-unaccepted; requires one sequential remediation PR on this same branch after the branch is moved to current `main`.
- Integration canonical branch: `automation/supervisor-player-map-integration`
  - reserved PR: #138
  - current state: parked/closed until MAP and PLAYER pass their own gates; reopen this same PR for final integration, do not create a replacement integration PR.

Do not create parallel implementation branches for these domains. At most one open implementation/remediation PR may exist per domain.

### Branch-creation enforcement

Branch governance is executable, not advisory. `tools/governance/branch_policy.json` and `tools/governance/check_branches.py` mirror the canonical identities above and are enforced by CI.

Before any worker or automation creates a branch:

1. fetch/prune remote refs;
2. identify the owning domain;
3. resolve its canonical branch from this file/policy;
4. if the canonical branch exists, continue it instead of creating another branch;
5. if the canonical branch does not exist, create exactly the approved canonical identity;
6. never invent `-v2`, `-v3`, `-retry`, `-new` or equivalent replacement suffixes;
7. never create a second managed MAP, PLAYER or INTEGRATION branch while another canonical branch is active;
8. if the user explicitly dismisses/replaces a worker, follow the dismissal rule: the replacement branch must be a newly approved canonical identity from clean `main`, and the policy must be updated atomically with that change.

Historical stale refs that cannot yet be physically deleted must be listed explicitly as `cleanup_debt` in the policy. This is a temporary allowlist only: it prevents old known debt from blocking CI while any new duplicate still fails immediately. Do not add new branches to `cleanup_debt` merely to make CI green.

Physical cleanup is complete only after the remote refs are deleted. `tools/governance/delete_cleanup_debt.sh` may be used from a credentialed Git environment; it refuses to delete any configured debt branch that is not already merged into `origin/main`.

### Premature-merge remediation rule

If a domain PR was merged before acceptance:

1. treat the merged PR as historical, not active;
2. preserve the same canonical branch identity;
3. move the canonical branch to current `main` before new work;
4. open exactly one remediation PR from that same branch;
5. perform only domain-owned remediation there;
6. keep integration debt out of the domain PR and domain debt out of #138;
7. after acceptance/merge, delete the canonical branch if no further remediation is needed.

This sequential remediation PR is not a parallel workstream because the previous PR is already merged/closed and the same branch is reused.

## Main-map rule

The previous main-map layout is discarded.

Do not reuse its:

- layout;
- composition;
- spatial patterns;
- object distribution;
- navigation design;
- authored spatial structure.

Generic technical infrastructure may be reused. Individual assets may be reused only when they independently satisfy the current quality bar.

`world/maps/verdant_test/` is a deliberately isolated visual sandbox. It is not the production main map and must never be registered into the production world/save flow unless explicitly promoted through the canonical map workstream after review.

## Design authority

Routine design and technical decisions required to progress are pre-approved. Do not block waiting for approval unless a decision is critically irreversible or presents a clear material risk.

## Quality target

The vertical slice must read as a commercially credible indie game, not a prototype.

### Player gate

Require:

- fluid movement and transitions;
- stable directional facing;
- dedicated production-quality idle/walk/run/interact behavior;
- functional collisions;
- functional directional interactions;
- coherent visual scale and animation;
- verification on the rebuilt map.

A run state that is only accelerated walk is not final-quality acceptance.

### Map gate

Require:

- a new authored spatial composition built from scratch;
- strong visual hierarchy and recognizable landmarks;
- terrain and dressing without obvious mathematical/procedural repetition;
- coherent paths, clusters, foreground/gameplay/background depth and Y-sort;
- correct collisions, navigation and interaction points;
- acceptable performance;
- no obvious placeholder/prototype geometry.

### Pixel-art production gate

Pixel-art work must follow a specialized pipeline:

1. art direction/reference;
2. concept/base generation where useful;
3. manual/intentional pixel-art cleanup and palette/silhouette consistency;
4. tileset/spritesheet/prop-family assembly;
5. Godot import with correct filtering, scale, pivots, layers/Y-sort and collision/navigation contracts;
6. real gameplay capture at 1280x720;
7. visual critique and revision.

Generated or conceptual images are source material only. They are never accepted as production game art until cleaned, integrated and reviewed in-game.

### Integration gate

PR #138 exists only to verify and fix cross-domain behavior:

- camera;
- scale;
- layers/Y-sort;
- spawn/traversal;
- navigation;
- collisions;
- interactions;
- performance;
- capture tooling;
- regressions caused by combining accepted MAP and PLAYER states.

Do not independently implement map or player features in #138.

While either MAP or PLAYER is below its own acceptance gate, #138 stays parked/closed. When both are accepted, reopen #138 and refresh/rebuild it from accepted `main`, keeping only genuine integration deltas. Do not open a replacement integration PR.

## Verification requirements

Before acceptance, require as applicable:

- Godot import/build success;
- smoke launch;
- relevant automated tests;
- lint/static checks;
- real gameplay verification;
- real 1280x720 gameplay screenshots/video for visual review.

Tests alone are never sufficient evidence for commercial visual quality.

Merged is not accepted. A merge with missing evidence or red required gates creates remediation debt and must immediately follow the premature-merge remediation rule above.

## Cleanup rule

When a PR/workstream is superseded:

1. port unique valuable work to the canonical branch if still relevant;
2. close the superseded PR;
3. delete its obsolete branch ref once safe;
4. do not allow automations to reopen the same workstream under a new branch.

When a historical merged PR remains unaccepted, its canonical branch may be reused only for the single sequential remediation PR defined above.

Repointing a duplicate/stale branch to current `main` or the canonical SHA is only temporary containment when deletion tooling is unavailable. Such a branch still counts as cleanup debt and must be reported as **not fully cleaned** until the ref is deleted.

## Operational documentation

`GAME1_RULES.md`, `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` and `README.md` must not materially contradict the current production state. After significant orchestration changes, update the designated operational docs before treating the pass as complete.

## Priority order

1. Playable integrated loop
2. Correctness and regressions
3. Visual/animation quality
4. Content richness
5. Optimization beyond required performance

At every supervisor pass, report: **Works / Broken or unverified / Changed / Next**.
