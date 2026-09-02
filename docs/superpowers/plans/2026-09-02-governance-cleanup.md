# Governance Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the post-merge governance deadlock, restore one legal implementation surface per domain, and clean stale workstream state without weakening technical/gameplay/visual gates.

**Architecture:** Canonical identity is the domain branch, not an immutable PR number. A domain may have at most one open implementation/remediation PR at a time on its canonical branch. If a canonical PR merged before acceptance, reset/fast-forward that same canonical branch to current `main`, open one remediation PR from it, and continue until gates pass. Integration remains isolated in #138.

**Tech Stack:** GitHub branches/PRs, Markdown operational governance, Godot 4.7.2 CI.

**Spec:** `GAME1_RULES.md`

## Global Constraints

- One domain, one canonical branch, one owner.
- Never use #138 for MAP/PLAYER feature debt.
- Merged does not mean accepted.
- Technical, gameplay and visual gates remain mandatory.
- No parallel domain branches.

---

### Task 1: Repair governance contract

**Files:**
- Modify: `.agents/skills/orchestrating-game-production/SKILL.md`
- Modify: `GAME1_RULES.md`

- [ ] Define branch as canonical domain identity.
- [ ] Define sequential remediation PR lifecycle after premature merge.
- [ ] Preserve one-open-PR maximum per domain.
- [ ] Preserve integration-only #138 and all acceptance gates.

### Task 2: Align operational documentation

**Files:**
- Modify: `DEV_MEMORY.md`
- Modify: `ROADMAP.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md`

- [ ] Replace deadlocked wording with remediation lifecycle.
- [ ] Record #139/#140 as historical merged PRs, not active implementation surfaces.
- [ ] Record PLAYER as first remediation bottleneck and MAP as parallel remediation.

### Task 3: Normalize branches and PR surfaces

**Interfaces:**
- Canonical MAP branch: `feat/main-map-rebuild-commercial-pass`
- Canonical PLAYER branch: `character/player-controller-polish-20260902`
- Integration branch: `automation/supervisor-player-map-integration`

- [ ] Verify stale refs contain no unique work before cleanup.
- [ ] Repoint stale refs to current `main` only when deletion tooling is unavailable; report physical deletion debt explicitly.
- [ ] Move canonical MAP/PLAYER branches to current `main` after their historical merges.
- [ ] Open exactly one remediation PR per domain from the existing canonical branch; do not create new branches.
- [ ] Keep #138 closed until both domain remediation gates pass.

### Task 4: Worker normalization

- [ ] Update MAP/PLAYER workers to use only remediation PRs on canonical branches.
- [ ] Require executable commits and evidence, not planning-only commits.
- [ ] Keep orchestrator checking branch duplication, CI, gameplay and visual evidence.

### Task 5: Verification

- [ ] Confirm no parallel active MAP/PLAYER implementation branches exist.
- [ ] Confirm exactly one active remediation PR per unfinished domain.
- [ ] Confirm #138 remains closed.
- [ ] Confirm operational docs agree with repository state.
- [ ] Confirm current `main` failures remain recorded as unresolved rather than mislabeled green.
