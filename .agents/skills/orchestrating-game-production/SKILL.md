---
name: orchestrating-game-production
description: Use when coordinating parallel game-development workstreams, pull requests, integration, quality gates, or cleanup across a playable game project.
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

1. **Inspect** — read project rules, `main`, open PRs, active branches, CI, tests, gameplay evidence and current blockers.
2. **Normalize** — identify domains; enforce exactly one canonical branch/PR per active domain. If duplicates exist, select the canonical implementation, port only useful unique work, close/supersede duplicates, and remove or neutralize stale branches.
3. **Prioritize** — choose the smallest critical-path change that improves the playable build. Prefer playable/correct/integrated work over conceptual or speculative work.
4. **Dispatch** — parallelize only independent domains. Agents must not edit outside their domain ownership.
5. **Implement** — work only on the canonical branch/PR for that domain. Never create a parallel PR when a canonical one exists.
6. **Verify technical gates** — import/build, smoke launch, tests, lint/static checks, collisions/navigation/interactions, and relevant performance checks.
7. **Verify gameplay gate** — prove the player can execute the intended loop in the real integrated scene.
8. **Verify visual gate** — where visuals matter, require real in-game screenshots/video and inspect hierarchy, composition, animation, scale, layers, readability, repetition and style consistency.
9. **Integrate** — use a dedicated integration branch/PR only for cross-domain conflicts/regressions. Do not develop independent features there.
10. **Clean** — after integration is accepted, merge according to project policy, close superseded PRs, delete stale branches when safe, and leave the repository with no divergent abandoned implementation lines.
11. **Repeat** — reassess the next playable bottleneck from current evidence.

## Canonical-workstream invariant

For every active domain:

```text
0 canonical PRs -> create one only when implementation actually starts
1 canonical PR  -> continue it
2+ PRs          -> stop feature expansion; consolidate first
```

A supervisor/integration PR is not another implementation branch.

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

- Closed/superseded implementation branches must not remain divergent indefinitely.
- Preserve unique valuable commits by porting them before cleanup.
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

- multiple PRs implementing the same domain;
- an automation creates a new branch despite an existing canonical branch;
- integration branch starts implementing domain features;
- old discarded design reappears during conflict resolution;
- completion is claimed from tests without real gameplay/visual evidence when those are required;
- stale branches contain divergent obsolete implementations after their PRs are closed.
