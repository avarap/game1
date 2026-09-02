# Player Authored Action Atlas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development and verification-before-completion. Execute only on canonical PLAYER PR #140.

**Goal:** Replace synthetic run/interact visuals with authored, distinct 8-direction animation frames while preserving player gameplay contracts.

**Architecture:** Keep `PlayerController` state selection unchanged. `PlayerVisual` owns animation construction from one production action atlas containing dedicated idle/walk/run/interact frame regions. The scene keeps the existing feet pivot, collision capsule, interaction area, camera, inventory and energy components.

**Tech Stack:** Godot 4.x, GDScript, `AnimatedSprite2D`, `SpriteFrames`, `AtlasTexture`, PNG pixel-art atlas.

**Spec:** `GAME1_RULES.md`, `ART_DIRECTION.md`, `art/characters/player/PROMPT.md`.

## Global Constraints

- Canonical workstream: PR #140 / `character/player-controller-polish-20260902` only.
- Eight directions: N, NE, E, SE, S, SW, W, NW.
- Dedicated production-quality idle/walk/run/interact behavior.
- Run must not be accelerated walk; interact must not fall back to idle.
- Preserve 20x28 collision footprint, feet-centered Y-sort contract and directional interaction behavior.
- Pixel art uses nearest filtering and muted Valdeniebla palette.

### Task 1: Add regression gate for authored action frames

**Files:**
- Modify: `tests/test_walking_prototype.gd`

- [ ] Require production frame counts for run/interact in every direction.
- [ ] Assert the first run frame does not reuse the first walk AtlasTexture region.
- [ ] Assert an interaction reach frame does not reuse the idle AtlasTexture region.
- [ ] Run CI and confirm the bootstrap gate fails for the current synthetic implementation.

### Task 2: Add dedicated action atlas and animation builder

**Files:**
- Create: `art/characters/player/player_actions_32x48.png`
- Modify: `player/player_visual.gd`
- Modify: `player/player.tscn`

- [ ] Add a 32x48-per-frame atlas with authored idle/walk/run/interact poses for all eight directions.
- [ ] Build directional SpriteFrames from distinct atlas regions.
- [ ] Remove walk-copy and idle/walk-derived interaction synthesis.
- [ ] Preserve state API: `set_locomotion_state(state, facing_vector)`.
- [ ] Re-run bootstrap tests and lint.

### Task 3: Verify canonical branch

- [ ] Verify Godot import succeeds.
- [ ] Verify main-scene smoke succeeds.
- [ ] Verify relevant bootstrap tests pass or identify unrelated baseline failures precisely.
- [ ] Inspect CI result for the new head.
- [ ] Delete superseded PLAYER branch refs once verified to contain no unique work; repointing/neutralizing refs is containment only and does not satisfy cleanup.
