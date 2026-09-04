---
description: Run the canonical MAP production loop with technical and visual gates.
---

1. Read the authoritative game1 production rules and the `game1-map` agent definition.
2. Confirm work is on the canonical MAP branch and there is no competing MAP implementation PR.
3. Inspect the latest real gameplay capture and current technical baseline.
4. Choose one compact, high-value map improvement; do not expand broad coverage while visual quality is below target.
5. Implement only MAP-owned changes.
6. Run Godot import/build, smoke, relevant tests/static checks, navigation/collision/interaction checks.
7. Run real gameplay and capture 1280x720 evidence tied to the current SHA.
8. Review hierarchy, landmark strength, repetition, path organicity, clusters, depth, occlusion, scale and Y-sort.
9. Revise until the change is objectively better without breaking the technical baseline.
10. Commit only verified MAP work and report the gate status.