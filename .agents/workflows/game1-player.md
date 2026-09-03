---
description: Run the canonical PLAYER production loop with root-cause debugging and gameplay/visual verification.
---

1. Read the authoritative game1 production rules and the `game1-player` agent definition.
2. Confirm work is on the canonical PLAYER branch and there is no competing PLAYER implementation PR.
3. Identify the earliest failing player component; fix root causes before downstream cascades.
4. Validate binary assets independently before Godot import.
5. Implement only PLAYER-owned changes; never weaken tests to hide asset/import/controller failures.
6. Run Godot import/build, smoke, relevant tests, lint and format checks.
7. Run the player on the rebuilt map and verify movement, facing, collisions and directional interaction.
8. Capture real 1280x720 gameplay evidence tied to the current SHA.
9. Review silhouette, scale, idle/walk/run/interact distinction, transitions and animation readability.
10. Commit only verified PLAYER work and report technical/gameplay/visual gate status.