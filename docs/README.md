# game1 Documentation

This directory contains long-form project documentation. Operational source-of-truth documents stay at repository root so agents and humans can find them immediately.

## Root operational documents

- `../README.md` — project entry point and current state.
- `../AGENTS.md` — global agent rules.
- `../GAME1_RULES.md` — production/orchestration source of truth.
- `../DEV_MEMORY.md` — operational state and recent decisions.
- `../ROADMAP.md` — active delivery plan.
- `../CHANGELOG.md` — material shipped changes.

## Long-form documentation

- Architecture: `architecture/ARCHITECTURE.md`
- Art direction: `art/ART_DIRECTION.md`
- Game design: `design/GAME_DESIGN.md`
- Master specification: `design/MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`
- Narrative direction: `narrative/HISTORIA_PRINCIPAL.md`
- Localization: `localization/LOCALIZATION.md`
- Production phase template: `production/PHASE_TEMPLATE.md`
- Production lessons: `production/LESSONS_LEARNED.md`
- Detailed specs/plans: `superpowers/`

## Documentation rule

Do not move root operational documents into `docs/` unless every automation, skill and worker that consumes them is migrated atomically. Long-form documents belong under `docs/`; root should remain a compact control surface.
