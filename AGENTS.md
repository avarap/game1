# GAME1 — Global Agent Rules

Project: Godot 4.7.2
Language: GDScript
Resolution: 1280x720
Logical tile: 32x32
Rendering: nearest filtering
Perspective: orthographic 3/4

Read before modifying visual content:
- `docs/art/ART_DIRECTION.md`
- `docs/architecture/ARCHITECTURE.md`
- `docs/design/GAME_DESIGN.md`
- `ROADMAP.md`
- `DEV_MEMORY.md`

Production/orchestration authority:
- `GAME1_RULES.md`
- `.agents/skills/orchestrating-game-production/SKILL.md`

## Global rules

- Never work directly on main.
- One task = one branch/worktree.
- Do not modify files outside the assigned scope.
- Do not merge your own work.
- Do not silently expand scope.
- Existing gameplay behaviour must not change for visual tasks.
- Run relevant tests before completion.
- Run gdlint and gdformat checks for GDScript changes.
- Godot project must import without errors.
- Visual work requires an in-game 1280x720 capture.
- CI green is necessary but does not imply visual approval.
- Never accept simple recolors, upscales or enlarged placeholders as production art.
- Preserve collision/navigation footprints unless the task explicitly authorizes changes.

## Visual quality criteria

Every visual change must improve:
- silhouette
- material readability
- volume
- lighting
- composition
- scale coherence
- environment integration
- pixel-art consistency

Prefer visible perceptual improvement over technical asset churn.
