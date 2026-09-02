# game1 Production Rules

This file contains project-specific rules consumed by the generic `orchestrating-game-production` skill.

## Canonical workstreams

- Map: PR #139 — branch `feat/main-map-rebuild-commercial-pass`
- Player: PR #140 — branch `character/player-controller-polish-20260902`
- Integration: PR #138 — branch `automation/supervisor-player-map-integration`

Do not create parallel implementation PRs or branches for these domains while the canonical workstream is active.

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
- regressions caused by combining #139 and #140.

Do not independently implement map or player features in #138.

## Verification requirements

Before acceptance, require as applicable:

- Godot import/build success;
- smoke launch;
- relevant automated tests;
- lint/static checks;
- real gameplay verification;
- real 1280x720 gameplay screenshots/video for visual review.

Tests alone are never sufficient evidence for commercial visual quality.

## Cleanup rule

When a PR/workstream is superseded:

1. port unique valuable work to the canonical branch if still relevant;
2. close the superseded PR;
3. delete its obsolete branch ref once safe;
4. do not allow automations to reopen the same workstream under a new branch.

Repointing a duplicate branch to the canonical SHA is only temporary containment when deletion tooling is unavailable. Such a branch still counts as cleanup debt and must be reported as **not fully cleaned** until the ref is deleted.

## Operational documentation

`GAME1_RULES.md`, `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` and `README.md` must not materially contradict the current production state. After significant orchestration changes, update the designated operational docs before treating the pass as complete.

## Priority order

1. Playable integrated loop
2. Correctness and regressions
3. Visual/animation quality
4. Content richness
5. Optimization beyond required performance

At every supervisor pass, report: **Works / Broken or unverified / Changed / Next**.
