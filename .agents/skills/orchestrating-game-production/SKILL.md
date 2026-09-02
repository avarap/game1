---
name: orchestrating-game-production
description: Use when coordinating parallel game-development workstreams, pull requests, integration, quality gates, visual-production pipelines, or cleanup across a playable game project.
---

# Orchestrating Game Production

## Overview

Centralize game production around one canonical workstream per domain and one final integration gate. Optimize for verified playable progress, not activity volume.

**Core principle:** one domain, one canonical branch/PR, one owner; integration is separate from feature implementation.

## Required sub-skills

Use these when their trigger applies; do not reimplement them here:

- **REQUIRED:** `superpowers:brainstorming` before new creative/design behavior.
- **REQUIRED:** `superpowers:writing-plans` for multi-step implementation.
- **REQUIRED:** `superpowers:test-driven-development` for features/bugfixes.
- **REQUIRED:** `superpowers:systematic-debugging` for failures/regressions.
- **REQUIRED:** `superpowers:dispatching-parallel-agents` when independent domains can proceed concurrently.
- **REQUIRED:** `superpowers:requesting-code-review` before integration.
- **REQUIRED:** `superpowers:verification-before-completion` before any completion claim.
- **REQUIRED:** `superpowers:finishing-a-development-branch` for merge/branch cleanup.

## Production loop

1. **Inspect** — read project rules, `main`, open PRs, active branches, CI, tests, gameplay evidence, visual evidence and current blockers.
2. **Normalize** — enforce exactly one canonical branch/PR per active domain. If duplicates exist, stop feature expansion, port only unique valuable work, close superseded PRs and delete superseded branch refs once safe.
3. **Prioritize** — choose the smallest critical-path change that improves the playable build. Prefer playable/correct/integrated work over conceptual or speculative work.
4. **Dispatch** — parallelize only independent domains. Agents must not edit outside their domain ownership.
5. **Implement** — work only on the canonical branch/PR for that domain. Never create a parallel PR when a canonical one exists.
6. **Verify technical gates** — import/build, smoke launch, tests, lint/static checks, collisions/navigation/interactions, and relevant performance checks.
7. **Verify gameplay gate** — prove the player can execute the intended loop in the real integrated scene.
8. **Verify visual gate** — require real in-game screenshots/video and inspect hierarchy, composition, animation, scale, layers, readability, repetition and style consistency.
9. **Integrate** — use a dedicated integration branch/PR only for cross-domain conflicts/regressions. Do not develop independent features there.
10. **Clean** — after integration is accepted, merge according to project policy, close superseded PRs, delete stale branch refs when safe, and leave no duplicate implementation branches.
11. **Synchronize operational docs** — update project memory/roadmap/changelog/readme when they are designated operational sources of truth.
12. **Repeat** — reassess the next playable bottleneck from current evidence.

## Canonical-workstream invariant

For every active domain:

```text
0 canonical PRs -> create one only when implementation actually starts
1 canonical PR  -> continue it
2+ PRs/branches -> stop feature expansion; consolidate and delete duplicates first
```

A supervisor/integration PR is not another implementation branch.

A branch with the same commit as the canonical branch is still a duplicate ref. Repointing or "neutralizing" it is only a temporary containment measure, not completed cleanup.

## Pixel-art production pipeline

When pixel art is part of the product, treat it as a specialized production pipeline rather than generic image generation:

1. **Art direction/reference** — define palette, scale, silhouette, lighting, material language and perspective.
2. **Concept/base generation** — generation tools may produce references or source material, but this is not final game art.
3. **Pixel-art cleanup** — enforce intentional clusters, controlled palette, clean silhouettes, consistent pixel density, readable animation frames and removal of vector/AI interpolation artifacts.
4. **Asset-system assembly** — build coherent tilesets, transitions, props, animation sheets and reusable families rather than isolated pretty images.
5. **Engine integration** — import with correct filtering, scale, pivots, Y-sort/layers, collision and navigation contracts.
6. **In-game capture** — review the asset only in the real scene/camera at gameplay resolution.
7. **Visual critique loop** — reject repetition, grid visibility, inconsistent scale, flat volume, noisy detail or weak landmarks; revise and recapture.

Do not approve conceptual/generated art merely because it looks attractive outside the game. The acceptance artifact is the integrated in-game result.

## Evidence contract

Never call work complete based only on code existing or tests passing. Completion requires evidence appropriate to the domain:

- technical: build/import + smoke + relevant tests/checks;
- gameplay: real movement/action/interactions in the integrated scene;
- visual: real capture from the game when visual quality is part of acceptance;
- integration: canonical domain implementations working together without regressions.

If a required evidence class is missing, report **not verified**, not done.

## Conflict policy

When resolving conflicts, preserve the canonical implementation for each domain unless a regression is demonstrated. Never resurrect superseded layouts, assets, controllers or architecture merely because Git chooses them more easily.

If conflict resolution crosses ownership boundaries, move the fix to the integration workstream or coordinate explicitly with the owning canonical PR.

## Cleanup policy

- Closed/superseded implementation branches must be deleted once their unique valuable work has been ported or judged obsolete.
- Do not keep duplicate branch refs merely because they point to the same commit.
- If the current tool/API cannot delete a safe stale branch, temporarily repoint it to the canonical head, mark cleanup **incomplete**, and retry deletion from a capable environment; do not describe that state as cleaned.
- Do not preserve obsolete implementations "just in case" when they contradict current project rules.
- Do not delete protected/default branches or unreviewed unique work.

## Status output

Every orchestration pass reports only:

- **Works** — verified current behavior.
- **Broken / unverified** — concrete failures or missing evidence.
- **Changed** — fixes, consolidation or cleanup performed now.
- **Next** — single highest-priority playable bottleneck.

## Red flags

Stop and normalize before continuing if any occur:

- multiple PRs or branch refs implementing the same domain;
- an automation creates a new branch despite an existing canonical branch;
- integration branch starts implementing domain features;
- old discarded design reappears during conflict resolution;
- completion is claimed from tests without real gameplay/visual evidence when those are required;
- generated/concept art is accepted without pixel-art cleanup and in-game review;
- operational documentation materially disagrees with the current production state;
- stale/duplicate branch refs remain after their PRs are superseded.
