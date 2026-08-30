# Phase 8A — Cemetery Depth & Delivery Design

## Goal
Convert corpse handling from a mostly linear prepare→bury loop into the central management decision of the vertical slice, connecting farming, economy, cooking, time, technology and infrastructure while keeping all fiction, characters, quests, maps and assets original.

## Design principles
- The benchmark game is structural reference only; no protected character, quest, dialogue, map or asset is copied.
- Reuse existing data-driven systems before creating new managers.
- `TimeManager` remains the only game clock.
- `SaveManager` continues aggregating local `save_provider` nodes; no new Autoload is introduced.
- Every mechanic must create a meaningful choice or remove an established friction through progression.
- Phase 8 remains active until its separate acceptance criteria are met.

## 1. Corpse decomposition
Each corpse stores decomposition canonically as integer `decay_percent` in the range `0..100` and age canonically as integer `age_minutes`. No legacy float-save compatibility is required because there are no player saves in circulation.

Readable states:
- Fresh: 0–24
- Fading: 25–49
- Decomposed: 50–74
- Rotten: 75–100

Decomposition accelerates with corpse age:
- first 24 in-game hours: slow;
- 24–48 hours: medium;
- 48–72 hours: fast;
- beyond 72 hours: very fast.

Sub-percent progression may use private integer accumulator units so large time jumps remain deterministic without exposing floating-point persistent state. Visible corpse quality decreases at state thresholds. Preparation may improve preparation quality but never rewinds corpse age or accumulated decomposition.

## 2. Preservation progression
Effective decomposition rate is derived from composable modifiers rather than hard-coded exceptions:

`effective_rate = age_rate × technology_modifier × facility_modifier × tool_modifier`

All modifiers default to 1.0. Preservation technologies, tools and facilities reduce the rate. Early progression must reduce pressure without granting complete immunity. The delivery ramp is logistics only and grants no preservation bonus.

## 3. Corpse decisions
The vertical slice expands corpse actions to four meaningful choices:
- **Prepare:** consumes time/energy/materials and can improve burial outcome; never resets decomposition.
- **Bury:** converts condition/preparation into cemetery rating/progression.
- **Cremate:** consumes the corpse for a different reward profile, with little or no cemetery rating.
- **Investigate:** consumes in-game time while decomposition continues and grants knowledge/technology progression or lore hooks.

`Reject` remains in the master-spec ceiling but is deferred until it has a meaningful consequence.

## 4. Funeral delivery service
An original funeral transport arrives at dusk; initial target time is **18:00** game time. Crossing 18:00 through normal play, sleep or a large time jump processes at most one delivery for that game day. Save/load must not duplicate a processed delivery.

During the introduction the service may deliver without payment. After its introductory quest, each delivery requires a cultivated fodder resource consumed from a dedicated feeder/supply container. Insufficient fodder suspends that day's delivery without negative inventory.

## 5. Delivery progression
- **Stage 1 — roadside drop:** the corpse is unloaded at a stable marker beside the road and begins decomposing from delivery time; the player must collect/manage it manually.
- **Stage 2 — supplied recurring service:** keeping the feeder stocked becomes a farming/economy logistics choice.
- **Stage 3 — delivery ramp:** quest + technology/construction unlocks an original ramp/chute routing future deliveries to the receiving/storage area. It changes destination only, not cost, frequency or preservation.

Infrastructure should automate friction the player has already experienced.

## 6. Minimal farming and fodder crop
Initial stable IDs: `fodder_turnip_seed` and `fodder_turnip`.

Loop: `seed → plant in plot → grow through TimeManager → harvest → inventory`.

Initial scope includes plots, planting, deterministic growth, harvest, seed/crop items and persistence only. Fertilizer, weather, irrigation simulation, seasons and crop-quality tiers are out of scope.

## 7. Fodder turnip as a multi-use resource
The same crop can be:
1. placed in the funeral-service feeder;
2. sold through the existing economy;
3. bought as a deliberately more expensive emergency option;
4. used in cooking recipes;
5. stored to reserve future deliveries.

Growing it should be economically preferable to buying it continuously.

## 8. Cooking integration
Cooking reuses existing `RecipeData`/crafting transaction semantics. Initial food recipes using fodder turnip restore energy and provide an alternative to immediately returning home to sleep. No hunger meter is introduced in Phase 8A.

## 9. Economy integration
Fodder seeds/crop receive base buy/sell values. Pricing should expose a future-ready multiplier pipeline:

`effective_price = base_price × global_modifier × merchant_modifier × relationship_modifier`

All modifiers begin at `1.0` unless a specific tested interaction requires otherwise. No simulated supply/demand market is introduced.

## 10. Feedback contract
Dusk arrival, successful delivery and suspended delivery must emit readable placeholder feedback through existing `EventBus`/`AudioManager` integration points. Final art/audio remains in the visual polish track.

## 11. Persistence
Save/load must preserve at minimum:
- corpse age, integer decomposition, quality/preparation and relevant action state;
- preservation state owned by the player;
- farming plots and growth state;
- feeder inventory;
- funeral-service state and per-day idempotency;
- ramp unlock/build state.

Loading must never grant duplicate corpses or erase elapsed decomposition/growth.

## 12. Acceptance scenarios
Phase 8A is not complete until automated tests demonstrate:
1. slow→medium→fast→very-fast corpse decomposition by age band;
2. readable state and effective-quality changes at thresholds;
3. deterministic equivalence between large and small time advances;
4. preservation modifiers reduce rate without rewinding decomposition;
5. exactly-once delivery when crossing 18:00, including sleep/time jumps/save-load;
6. insufficient fodder prevents supplied delivery;
7. fodder can be planted, grown, harvested and consumed by feeder;
8. fodder can also be bought, sold and cooked;
9. roadside delivery before ramp and receiving-area delivery after ramp;
10. investigate consumes time and grants progression while decomposition continues;
11. cremate and bury have intentionally different outcomes;
12. full save/load preserves the whole loop;
13. global quality gate, Godot 4.7.2 import, main-scene smoke and full headless suite remain green.

## 13. Scope boundaries
Not part of 8A: hunger/thirst, seasons/weather farming, complex irrigation/fertilizer, dynamic supply/demand, combat expansion, large new maps, final transport art/audio, or copying benchmark-specific donkey/carrot/dialogue/quest/layout content.
