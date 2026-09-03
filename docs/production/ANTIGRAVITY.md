# Antigravity production setup for game1

This repository contains an experimental Google Antigravity production layer on branch `experiment/antigravity-production`.

## What Antigravity discovers

Workspace customizations live under `.agents/`:

- `.agents/rules/game1-production.md` — persistent project production constraints;
- `.agents/agents/*/agent.md` — specialist agents for ORCHESTRATOR, MAP, PLAYER, VISUAL-QA and INTEGRATION;
- `.agents/skills/` — existing reusable game-production skills;
- `.agents/workflows/*.md` — slash-command production workflows.

The authoritative project sources remain:

1. `GAME1_RULES.md`
2. `docs/production/LESSONS_LEARNED.md`
3. `.agents/skills/orchestrating-game-production/SKILL.md`

Do not duplicate or override their governance in Antigravity prompts.

## Start

1. Check out this branch locally and open the repository root as the Antigravity workspace.
2. Confirm the workspace customizations are visible. Custom agents are available through `/agents`; workflows are invoked by their file name, for example `/game1-start`.
3. Run `/game1-start` first. It inspects the real production state and identifies the next bottleneck.
4. Use `/game1-map` or `/game1-player` only for the corresponding canonical workstream.
5. Use `/game1-review` for independent evidence review.
6. Use `/game1-integrate` only after MAP and PLAYER are independently accepted.

## Optional Teamwork

On plans that support it, `/teamwork-preview` can coordinate a multi-agent team. Use it only when workstreams are genuinely independent.

Antigravity Teamwork provides isolated project directories and exclusive file ownership, but that isolation does not replace game1 Git governance. Scratch/project directories are temporary execution surfaces. Canonical state remains the branches, commits, PRs, CI and operational documentation defined in `GAME1_RULES.md`.

Recommended ownership:

- MAP worker: MAP-owned files only;
- PLAYER worker: PLAYER-owned files only;
- VISUAL-QA: review/evidence only by default;
- INTEGRATION: cross-domain deltas only after acceptance;
- ORCHESTRATOR: prioritization, gates and reversible root-cause intervention.

## First benchmark experiment

Do not migrate production immediately. Use Antigravity to reproduce one difficult, measurable task and compare it with the current workflow.

Recommended benchmark: PLAYER.

Success metrics:

- time to a genuinely playable result;
- number of human interventions;
- useful commits versus churn;
- import/build/tests/lint/format results;
- real gameplay behavior;
- 1280x720 visual quality;
- rework required;
- cost.

For a clean A/B experiment, start from current `main` in a disposable test worktree/branch and do not mutate the current canonical PLAYER/MAP branches unless you explicitly decide Antigravity is taking ownership. The experiment must still obey copyright and evidence rules.

## Commands

- `/game1-start` — production status and routing.
- `/game1-map` — MAP production loop.
- `/game1-player` — PLAYER production loop.
- `/game1-review` — independent acceptance review.
- `/game1-integrate` — final cross-domain integration after gates pass.

## Non-goals

This Antigravity branch does not change game content, replace `GAME1_RULES.md`, merge MAP/PLAYER work, reopen #138, or declare the current vertical slice accepted.