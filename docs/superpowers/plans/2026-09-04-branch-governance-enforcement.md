# Branch Governance Enforcement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent new duplicate domain branches, make historical cleanup debt explicit, and provide a safe one-shot remote cleanup command.

**Architecture:** Add a small Python policy checker driven by JSON configuration, run it in GitHub Actions, and provide a shell cleanup utility that deletes only cleanup-debt branches proven merged into `origin/main`. Existing stale refs are temporarily allowlisted as cleanup debt because the current connector cannot delete remote refs; any new duplicate or retry-style branch fails CI immediately.

**Tech Stack:** Python 3.12 standard library, Bash, Git, GitHub Actions.

**Spec:** `GAME1_RULES.md`

## Global Constraints

- One canonical branch per MAP, PLAYER and INTEGRATION domain.
- No `-v2`, `-v3`, `-retry`, or `-new` branch variants for replacement attempts.
- Historical cleanup debt must be reported as incomplete until physically deleted.
- Cleanup must refuse to delete a branch that is not merged into `origin/main`.
- No gameplay, map, player, scene or asset changes in this workstream.

---

### Task 1: Define executable branch policy

**Files:**
- Create: `tools/governance/branch_policy.json`
- Create: `tools/governance/check_branches.py`
- Create: `tests/test_branch_governance.py`

**Interfaces:**
- Consumes: remote branch names from `git ls-remote --heads origin`.
- Produces: exit code 0 when policy is satisfied; exit code 1 on new duplicate/noncanonical managed branches or forbidden retry naming.

- [ ] Add canonical branch identities, managed-domain matchers and explicit historical cleanup-debt refs.
- [ ] Implement pure `evaluate()` logic plus CLI remote-ref discovery.
- [ ] Add tests for clean state, duplicate MAP, retry suffix, cleanup-debt warning and strict cleanup failure.
- [ ] Run `python tests/test_branch_governance.py` and require all tests to pass.

### Task 2: Add safe physical cleanup utility

**Files:**
- Create: `tools/governance/delete_cleanup_debt.sh`

**Interfaces:**
- Consumes: `cleanup_debt` from `branch_policy.json`.
- Produces: remote branch deletion only when the branch exists and is an ancestor of `origin/main`.

- [ ] Fetch/prune remote refs.
- [ ] Refuse deletion for any debt branch not merged into main.
- [ ] Delete safe refs with `git push origin --delete`.
- [ ] Run strict governance validation after cleanup.

### Task 3: Enforce policy in CI and rules

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `GAME1_RULES.md`

**Interfaces:**
- Consumes: governance checker from Task 1.
- Produces: a required CI job that blocks new branch duplication and documented operator rules matching executable behavior.

- [ ] Add `branch-governance` CI job using Python 3.12 and full checkout/ref visibility.
- [ ] Add explicit branch-creation guardrail and prohibited retry-suffix rule to `GAME1_RULES.md`.
- [ ] Verify repository diff contains governance/docs only.

### Task 4: Review and publish

**Files:**
- No new files.

- [ ] Run branch checker against current remote state; historical debt may warn but must not error.
- [ ] Run unit tests.
- [ ] Compare branch against `main` and confirm no gameplay/assets changed.
- [ ] Open a PR against `main` and report physical cleanup as incomplete until remote deletion is performed from a credentialed Git environment.
