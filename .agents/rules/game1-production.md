# game1 production authority

Before any production action, read and obey:

- `GAME1_RULES.md`
- `docs/production/LESSONS_LEARNED.md`
- `.agents/skills/orchestrating-game-production/SKILL.md`

These files are authoritative. This rule is an Antigravity adapter, not a replacement source of truth.

Operate with one canonical workstream per domain. Do not create parallel MAP, PLAYER or INTEGRATION implementation branches/PRs. Keep PR #138 parked until MAP and PLAYER pass their independent technical, gameplay and visual gates.

For visual work, real gameplay evidence at 1280x720 is required. CI/tests alone cannot prove commercial visual quality. Generated/conceptual art is not production art until intentionally cleaned, integrated in Godot and reviewed in-game.

Graveyard Keeper may be used only as a benchmark for polish, readability, composition, animation clarity and loop density. Never copy protected maps, layouts, sprites, characters, names, narrative or assets.

If a worker repeats a blocker whose root cause is demonstrated, prefer the smallest reversible direct intervention instead of repeating instructions.

If the user explicitly dismisses/replaces a domain worker, follow the dismissal policy in `GAME1_RULES.md` exactly: do not reuse the dismissed worker's branch/PR and do not port its work unless explicitly instructed.

Every production status must report exactly: Works / Broken or unverified / Changed / Next.