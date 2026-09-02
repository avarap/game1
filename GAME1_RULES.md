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

When a PR is superseded:

1. port unique valuable work to the canonical branch if still relevant;
2. close the superseded PR;
3. remove or neutralize its divergent branch;
4. do not allow automations to reopen the same workstream under a new branch.

## Priority order

1. Playable integrated loop
2. Correctness and regressions
3. Visual/animation quality
4. Content richness
5. Optimization beyond required performance

At every supervisor pass, report: **Works / Broken or unverified / Changed / Next**.
