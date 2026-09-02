# Visual Audit — 2026-09-02

Scope: canonical main-map PR #139 after the first real 1280x720 CI captures.

## Executive assessment

The branch contains meaningful technical restructuring, but the visual result is still prototype quality. The amount of code changed substantially overstates the perceptual improvement visible in-game.

## What actually improved

- The cemetery layout is no longer the original procedural/sine-based composition.
- Interactions, spawn points and exits were relocated to a new spatial arrangement.
- Authored route/collision/navigation tests were added.
- A real 1280x720 capture pipeline now runs successfully in CI.
- A commercial-art direction and asset manifest now exist.

## What did not materially improve yet

- The production cemetery tileset itself has not been replaced by commercial-quality authored art.
- Ground still reads as a repeated tile carpet with obvious 32 px seams.
- Paths still read as blocks/strips of repeated square tiles rather than organic terrain transitions.
- Graves are tiny, repeated and visually weak.
- Vegetation is effectively a repeating green texture rather than layered ecological clusters.
- Trees and foreground depth are not visually established in the captured views.
- Plaza has no strong focal landmark.
- Cemetery entrance is not visually legible as a distinct landmark.
- Grave field lacks social/age variety, sculptural silhouettes, walls, gates, overgrowth and storytelling props.
- Workshop is the only visually strong asset, creating a severe quality mismatch with the surrounding terrain.
- Empty space and grid structure dominate the scene.

## Capture-by-capture critique

### Workshop

The building itself is substantially above the terrain quality bar, but it floats in a repetitive green field. The apron is a rectangular block of repeated path cells. Interaction props appear as tiny symbols/placeholders. There is no coherent work-yard dressing, vegetation frame, contact-shadow language or foreground composition.

### Plaza

This does not currently read as a plaza. It is primarily crossing tile paths in open ground. There is no central focal element, enclosure, seating rhythm, lantern composition, masonry transition or visual hierarchy.

### Grave field

The grave zone remains unmistakably prototype-quality. Repeated tombstone sprites and isolated dirt ovals are distributed over obvious grid paths. There is little scale variation, no large funerary assets and insufficient vegetation/stone layering.

### Overall map

The rebuilt route graph is different, but visual authorship has not caught up with spatial authorship. Most of the scene is still composed from a tiny repeated atlas, so the player perceives the grid before the world.

## Root cause

Work was prioritized in the wrong order. Too much effort went into layout constants, tests, navigation, CI and documentation before replacing the visual primitives those systems arrange. This produced technical progress without corresponding visual progress.

## Correct next order

1. Replace ground and path art first with authored transition-capable terrain.
2. Replace vegetation with multi-size transparent clusters.
3. Replace graves with a large silhouette family and multi-tile funerary assets.
4. Add tree trunks/crowns split across gameplay and foreground layers.
5. Build the five required landmarks as bespoke compositions.
6. Redress the map using those assets; do not compensate with more procedural placement code.
7. Capture all five 1280x720 views again.
8. Reject the pass if tile seams, repeated silhouettes or rectangular path blocks remain visually dominant.

## Acceptance status

**NOT VISUALLY ACCEPTABLE. Do not merge #139 on the basis of current captures.**
