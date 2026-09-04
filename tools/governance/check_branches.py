#!/usr/bin/env python3
"""Validate branch governance for game1."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Iterable

POLICY_PATH = Path(__file__).with_name("branch_policy.json")


def load_policy(path: Path = POLICY_PATH) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def list_remote_branches(remote: str = "origin") -> list[str]:
    result = subprocess.run(
        ["git", "ls-remote", "--heads", remote],
        check=True,
        capture_output=True,
        text=True,
    )
    branches: list[str] = []
    for line in result.stdout.splitlines():
        if not line.strip():
            continue
        _, ref = line.split(maxsplit=1)
        prefix = "refs/heads/"
        if ref.startswith(prefix):
            branches.append(ref[len(prefix) :])
    return sorted(set(branches))


def evaluate(
    branches: Iterable[str], policy: dict, *, strict_cleanup: bool = False
) -> tuple[list[str], list[str]]:
    branch_set = set(branches)
    cleanup_debt = set(policy.get("cleanup_debt", []))
    errors: list[str] = []
    warnings: list[str] = []

    debt_present = sorted(branch_set & cleanup_debt)
    if debt_present:
        message = "Cleanup debt still present: " + ", ".join(debt_present)
        if strict_cleanup:
            errors.append(message)
        else:
            warnings.append(message)

    retry_pattern = re.compile(policy["forbidden_retry_suffix"])
    for branch in sorted(branch_set - cleanup_debt):
        if retry_pattern.search(branch):
            errors.append(
                f"Forbidden retry/version branch name: {branch}. "
                "Continue the canonical branch instead."
            )

    canonical = policy["canonical"]
    for domain, pattern_text in policy["managed_patterns"].items():
        pattern = re.compile(pattern_text)
        managed = sorted(
            branch
            for branch in branch_set
            if pattern.search(branch) and branch not in cleanup_debt
        )
        expected = canonical[domain]

        if len(managed) > 1:
            errors.append(
                f"{domain} has multiple active managed branches: {', '.join(managed)}"
            )
        elif len(managed) == 1 and managed[0] != expected:
            errors.append(
                f"{domain} active branch is {managed[0]}, expected canonical {expected}"
            )

    return errors, warnings


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--remote", default="origin")
    parser.add_argument(
        "--candidate",
        action="append",
        default=[],
        help="Additional branch name to validate, e.g. the current PR head branch.",
    )
    parser.add_argument(
        "--strict-cleanup",
        action="store_true",
        help="Fail while any configured historical cleanup-debt branch still exists.",
    )
    args = parser.parse_args(argv)

    try:
        branches = list_remote_branches(args.remote)
        branches.extend(branch for branch in args.candidate if branch)
        policy = load_policy()
    except (OSError, subprocess.CalledProcessError, json.JSONDecodeError) as exc:
        print(f"branch-governance: unable to inspect policy/remote: {exc}", file=sys.stderr)
        return 2

    unique_branches = sorted(set(branches))
    errors, warnings = evaluate(
        unique_branches, policy, strict_cleanup=args.strict_cleanup
    )

    for warning in warnings:
        print(f"WARNING: {warning}")
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)

    if errors:
        print(f"branch-governance: FAIL ({len(errors)} error(s))", file=sys.stderr)
        return 1

    print(
        f"branch-governance: PASS ({len(unique_branches)} branches inspected, "
        f"{len(warnings)} cleanup warning(s))"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
