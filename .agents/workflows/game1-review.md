---
description: Independently review current game1 technical, gameplay and visual evidence without implementing domain work.
---

1. Read `GAME1_RULES.md`, `docs/production/LESSONS_LEARNED.md`, `.agents/rules/game1-production.md`, and the `game1-visual-qa` agent definition.
2. Identify the exact SHA being reviewed and reject stale, fallback or mismatched evidence.
3. Verify technical evidence: import/build, smoke, relevant tests and static checks.
4. Verify gameplay evidence: intended movement/actions, collisions, navigation and interactions as applicable.
5. Verify real 1280x720 gameplay capture for every visual acceptance claim.
6. Review MAP and PLAYER independently against their production gates.
7. Return PASS, FAIL or NOT VERIFIED per gate with only observable reasons.
8. Do not silently implement fixes; route failures back to the owning domain.