# Antigravity Production Layer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an isolated Antigravity production layer that exposes game1 governance through discoverable rules, specialist agents and repeatable workflows without changing game content.

**Architecture:** Keep `GAME1_RULES.md`, `docs/production/LESSONS_LEARNED.md` and the existing orchestration skill authoritative. Add thin Antigravity adapters under `.agents/rules`, `.agents/agents` and `.agents/workflows`; no duplicate domain implementation branches or production logic.

**Tech Stack:** Google Antigravity workspace customizations, Markdown, Git/GitHub, Godot 4 project governance.

**Spec:** `docs/superpowers/specs/2026-09-03-antigravity-production-design.md`

## Global Constraints

- Branch: `experiment/antigravity-production`, created from current `main`.
- No game-content changes.
- No changes to canonical MAP/PLAYER/INTEGRATION branch identities.
- #138 remains parked until MAP and PLAYER acceptance.
- Existing project rules and lessons remain source of truth.

---

### Task 1: Workspace production rule

**Files:**
- Create: `.agents/rules/game1-production.md`

**Interfaces:**
- Consumes: `GAME1_RULES.md`, `docs/production/LESSONS_LEARNED.md`, `.agents/skills/orchestrating-game-production/SKILL.md`
- Produces: always-on Antigravity context pointing agents at authoritative governance.

- [ ] Create a concise always-on rule that requires reading the three authoritative sources before production work.
- [ ] Encode domain ownership, evidence requirements, #138 gate and dismissal policy by reference, not duplication.
- [ ] Verify the file references only paths that exist on `main`.
- [ ] Commit.

### Task 2: Specialist agents

**Files:**
- Create: `.agents/agents/orchestrator/agent.md`
- Create: `.agents/agents/map/agent.md`
- Create: `.agents/agents/player/agent.md`
- Create: `.agents/agents/visual-qa/agent.md`
- Create: `.agents/agents/integration/agent.md`

**Interfaces:**
- Consumes: workspace rule + authoritative production sources.
- Produces: five explicit Antigravity roles with non-overlapping ownership.

- [ ] Add YAML frontmatter with unique names/descriptions.
- [ ] Define each role's owned files/concerns and forbidden cross-domain behavior.
- [ ] Require evidence-based completion and real 1280x720 visual review where applicable.
- [ ] Verify no agent can authorize #138 before both domain gates pass.
- [ ] Commit.

### Task 3: Repeatable workflows

**Files:**
- Create: `.agents/workflows/game1-start.md`
- Create: `.agents/workflows/game1-map.md`
- Create: `.agents/workflows/game1-player.md`
- Create: `.agents/workflows/game1-review.md`
- Create: `.agents/workflows/game1-integrate.md`

**Interfaces:**
- Consumes: specialist roles and canonical governance.
- Produces: slash-command trajectories for common production loops.

- [ ] Add title, description and explicit sequential steps to every workflow.
- [ ] Make MAP and PLAYER workflows stay on their canonical workstreams.
- [ ] Make review independent from implementation claims.
- [ ] Make integration stop immediately unless MAP and PLAYER are accepted.
- [ ] Commit.

### Task 4: Operator guide

**Files:**
- Create: `docs/production/ANTIGRAVITY.md`

**Interfaces:**
- Consumes: all Antigravity workspace files.
- Produces: minimal setup/use guide for a human operator.

- [ ] Document how to open the repository as an Antigravity workspace.
- [ ] Document `/agents`, workflows and optional `/teamwork-preview` usage.
- [ ] Explain that Teamwork workspace isolation does not replace canonical Git governance.
- [ ] Include the first recommended experiment: run PLAYER from clean `main` evidence, without touching current production branches until explicitly chosen.
- [ ] Commit.

### Task 5: Verification and PR

**Files:**
- Verify all files above.

**Interfaces:**
- Consumes: branch diff.
- Produces: reviewable PR against `main`.

- [ ] Compare `main...experiment/antigravity-production` and confirm only configuration/docs changed.
- [ ] Verify every referenced repository path exists.
- [ ] Check that all agent Markdown contains valid YAML frontmatter where required.
- [ ] Open a draft PR against `main` describing the experiment and its non-interference guarantees.
- [ ] Do not merge automatically.