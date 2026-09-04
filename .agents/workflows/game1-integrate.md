---
description: Integrate accepted MAP and PLAYER work only after both domains pass all required gates.
---

1. Read the authoritative production rules and the `game1-integration` agent definition.
2. Confirm MAP is accepted for technical, gameplay and visual gates.
3. Confirm PLAYER is accepted for technical, gameplay and visual gates.
4. If either domain is not accepted, STOP and report the missing gate; do not use integration to finish domain debt.
5. Reopen/use PR #138 only as defined by `GAME1_RULES.md`; do not create a replacement integration workstream.
6. Resolve only cross-domain issues: camera, scale, layers/Y-sort, spawn/traversal, navigation, collisions, interactions, performance, capture tooling and combination regressions.
7. Preserve accepted canonical implementations during conflict resolution.
8. Run import/build, smoke, relevant tests/static checks and real integrated gameplay.
9. Capture current-SHA 1280x720 gameplay evidence and run independent VISUAL-QA.
10. Report Works / Broken or unverified / Changed / Next.