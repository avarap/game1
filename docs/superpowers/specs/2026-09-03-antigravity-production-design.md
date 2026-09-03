# Antigravity Production Layer Design

## Goal

Add an isolated Antigravity workspace configuration for `game1` that reuses the repository's existing production rules and skills while providing explicit specialist agents and repeatable workflows for ORCHESTRATOR, MAP, PLAYER, VISUAL-QA and INTEGRATION.

## Constraints

- The experiment starts from clean `main` on branch `experiment/antigravity-production`.
- Do not change MAP, PLAYER or INTEGRATION canonical branch identities.
- Do not reopen or repurpose PR #138.
- `GAME1_RULES.md`, `docs/production/LESSONS_LEARNED.md` and `.agents/skills/orchestrating-game-production/SKILL.md` remain authoritative.
- Antigravity-specific files must reference those sources instead of duplicating their full contents.
- Graveyard Keeper is only a benchmark for polish/readability/composition and never a source of protected content.
- Completion claims require appropriate technical, gameplay and visual evidence.

## Architecture

Use Antigravity's workspace customization surfaces:

- `.agents/rules/` for always-on project production constraints;
- `.agents/agents/<name>/agent.md` for specialist role definitions;
- existing `.agents/skills/` for reusable production knowledge;
- `.agents/workflows/*.md` for slash-command production loops.

The orchestrator owns prioritization and gates. MAP and PLAYER own only their domains. VISUAL-QA is read/review oriented and may reject but should not silently implement domain features. INTEGRATION activates only after MAP and PLAYER are accepted.

## Agents

### game1-orchestrator
Reads the authoritative project rules first, inspects Git/CI/evidence, chooses the critical-path bottleneck, dispatches specialists and reports Works / Broken or unverified / Changed / Next.

### game1-map
Owns rebuilt-map composition, terrain, props, navigation, collisions, interactions and 1280x720 visual evidence. It must preserve a green technical baseline during visual polish.

### game1-player
Owns protagonist assets, controller, authored animation, collisions, directional interaction and integrated gameplay evidence. It must fix root causes rather than weaken tests.

### game1-visual-qa
Independently reviews real gameplay captures against the commercial-quality gate. It rejects prototypes, repetition, weak hierarchy, inconsistent scale, placeholder art and misleading evidence.

### game1-integration
Owns only cross-domain issues after MAP and PLAYER acceptance: camera, scale, Y-sort/layers, spawn/traversal, collisions, navigation, interactions, performance and capture regressions.

## Workflows

- `/game1-start`: inspect rules, Git state, gates and choose one bottleneck.
- `/game1-map`: execute the MAP production loop on the canonical MAP workstream.
- `/game1-player`: execute the PLAYER production loop on the canonical PLAYER workstream.
- `/game1-review`: independently review current technical/gameplay/visual evidence.
- `/game1-integrate`: integrate only after both domains pass.

## Safety and isolation

Antigravity Teamwork may be used for independent workstreams, but file ownership must remain exclusive and repository governance still wins. A Teamwork scratch/project directory is not a canonical Git workstream. Canonical state remains GitHub branches, commits, PRs, CI and repository documentation.

## Acceptance

This configuration is ready for experiment when Antigravity can discover the rule, agents and workflows; each role references the authoritative sources; workflows cannot legally bypass domain ownership or #138 gating; and the branch diff contains no game-content changes.