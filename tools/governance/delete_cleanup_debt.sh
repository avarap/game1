#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
POLICY_FILE="$ROOT_DIR/tools/governance/branch_policy.json"
CHECKER="$ROOT_DIR/tools/governance/check_branches.py"
REMOTE="${1:-origin}"

cd "$ROOT_DIR"
git fetch "$REMOTE" --prune

mapfile -t DEBT_BRANCHES < <(
  python - "$POLICY_FILE" <<'PY'
import json
import sys
from pathlib import Path
policy = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
for branch in policy.get("cleanup_debt", []):
    print(branch)
PY
)

failed=0
for branch in "${DEBT_BRANCHES[@]}"; do
  remote_ref="refs/remotes/$REMOTE/$branch"

  if ! git show-ref --verify --quiet "$remote_ref"; then
    echo "already absent: $branch"
    continue
  fi

  if ! git merge-base --is-ancestor "$REMOTE/$branch" "$REMOTE/main"; then
    echo "REFUSE: $branch is not fully merged into $REMOTE/main" >&2
    failed=1
    continue
  fi

  echo "deleting merged cleanup-debt branch: $branch"
  git push "$REMOTE" --delete "$branch"
done

if [[ "$failed" -ne 0 ]]; then
  echo "cleanup incomplete: at least one branch was not safe to delete" >&2
  exit 1
fi

git fetch "$REMOTE" --prune
python "$CHECKER" --remote "$REMOTE" --strict-cleanup
