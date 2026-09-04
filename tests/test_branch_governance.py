#!/usr/bin/env python3
from __future__ import annotations

import json
import unittest
from pathlib import Path
import importlib.util

ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "tools" / "governance" / "check_branches.py"
POLICY_PATH = ROOT / "tools" / "governance" / "branch_policy.json"

spec = importlib.util.spec_from_file_location("check_branches", MODULE_PATH)
check_branches = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(check_branches)


class BranchGovernanceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.policy = json.loads(POLICY_PATH.read_text(encoding="utf-8"))

    def test_clean_canonical_state_passes(self) -> None:
        branches = {
            "main",
            self.policy["canonical"]["MAP"],
            self.policy["canonical"]["PLAYER"],
            self.policy["canonical"]["INTEGRATION"],
            "experiment/antigravity-production",
        }
        errors, warnings = check_branches.evaluate(branches, self.policy)
        self.assertEqual([], errors)
        self.assertEqual([], warnings)

    def test_duplicate_map_branch_fails(self) -> None:
        branches = {
            self.policy["canonical"]["MAP"],
            "feature/main-map-another-pass",
        }
        errors, _ = check_branches.evaluate(branches, self.policy)
        self.assertTrue(any("MAP has multiple active managed branches" in e for e in errors))

    def test_retry_suffix_fails(self) -> None:
        errors, _ = check_branches.evaluate(
            {"docs/reorganize-production-knowledge-v4"}, self.policy
        )
        self.assertTrue(any("Forbidden retry/version branch name" in e for e in errors))

    def test_known_cleanup_debt_warns_but_does_not_fail(self) -> None:
        debt = self.policy["cleanup_debt"][0]
        errors, warnings = check_branches.evaluate({debt}, self.policy)
        self.assertEqual([], errors)
        self.assertEqual(1, len(warnings))
        self.assertIn(debt, warnings[0])

    def test_strict_cleanup_fails_while_debt_exists(self) -> None:
        debt = self.policy["cleanup_debt"][0]
        errors, _ = check_branches.evaluate(
            {debt}, self.policy, strict_cleanup=True
        )
        self.assertTrue(any("Cleanup debt still present" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
