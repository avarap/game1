# Cemetery Commercial Art Direction

## Visual target
Original high-quality 3/4 top-down pixel art for a decaying rural medieval cemetery. The mood is melancholic but welcoming: cool vegetation and stone dominate, while windows, lanterns, flowers and interaction focal points provide restrained warm accents.

The current generated/prototype atlas is not a quality reference. Existing gameplay systems may remain, but final environment art must conform to this document.

## Master palette
Core darks: `#171A18`, `#232721`, `#30352E`, `#3D4337`.
Soils: `#3C3028`, `#554235`, `#705541`, `#8A6848`.
Vegetation: `#26372C`, `#354A35`, `#4B6040`, `#68734B`, `#85805A`.
Stone: `#454847`, `#5B605C`, `#747872`, `#92938A`, `#B1AA96`.
Wood/rust: `#4A3026`, `#68412D`, `#855638`, `#88473A`.
Warm accents: `#B57A3F`, `#D39A51`, `#E1B86C`.
Cool atmospheric accents: `#46545A`, `#627078`, `#839092`.
Floral accents are sparse and local: muted wine, ochre, dusty violet and bone white.

## Lighting
Key light always comes from upper-left. Forms use a cool/dark lower-right occlusion side and a restrained upper-left highlight. Important objects receive a readable contact shadow. Do not bake contradictory light directions into neighboring assets.

## Scale and grid
Logical grid remains 32x32. Ground transitions may occupy 1x1 cells, but important props should escape the grid visually. Preferred production sizes: 64x64 shrubs/graves, 96x96 small structures, 96x128 trees, 128x96 gates/walls, and larger bespoke landmarks. Character target remains approximately 64x96.

## Ground families
Minimum eight authored base families: healthy grass, dry grass, mud, compact soil, disturbed soil, moss, wet ground, eroded/stony ground. Each family needs intentional material features rather than uniform pixel noise. Decals provide stones, roots, leaves, flowers and erosion without changing the base material identity.

## Paths
Paths are terrain systems, not painted strips. Required pieces include straight segments, soft bends, hard bends, inner/outer corners, T junctions, crossroads, endings, grass/soil transitions, broken edges, embedded stones and occasional puddles. Width must vary visually even where the navigation corridor remains constant.

## Vegetation
Use clustered ecological families: short grass, tall grass, ferns, shrubs, dry plants, flowers, brambles, exposed roots and leaf litter. Clusters should have a dominant silhouette plus satellites; never distribute one sprite uniformly across the map.

## Trees
At least three mature silhouettes plus young, dead, twisted and moss-covered variants. Mature trees require a clear trunk, irregular crown, contact shadow and enough transparent negative space that the player remains readable near them. Tree crowns may enter foreground while trunks remain y-sorted gameplay objects.

## Cemetery language
Graves communicate age and social status through silhouette. Required families: poor markers, ordinary stones, old carved stones, broken/abandoned graves, crosses, small mausoleums, ruined wall modules, pillars, gates, statues, benches, lanterns, fresh soil and funeral flowers. Avoid long regular rows; graves form family clusters separated by paths, trees and negative space.

## Props
Barrels, crates, planks, tools, wheelbarrows, sacks, logs, stones, signs, posts, buckets, ropes and wood piles must use the same light direction and palette. Props should tell local stories: work items near the workshop, funeral tools near preparation space, maintenance clutter near walls/gates.

## Landmark identities
- Workshop/home: warm timber light, work clutter, chimney silhouette, worn apron of compact soil.
- Cemetery entrance: masonry pillars, iron gate, lantern accent, compressed vegetation framing the opening.
- Main plaza: broader negative space, circular or asymmetric stone focal feature, seating and warm light.
- Grave field: cool stone rhythm broken by old trees, family clusters and overgrowth.
- Forest road: narrowing path, stronger foreground occlusion, denser vegetation and cooler values.

## Layer contract
Background: terrain, broad material transitions and low decals.
Gameplay: character, graves, trunks, walls, buildings, props and interactables using y-sort where appropriate.
Foreground: crowns, branches, tall vegetation and framing elements that may overlap the player without obscuring navigation-critical information.

## Rejection criteria
Reject assets that read as primitives, flat rectangles, procedural noise, simple recolors, nearly identical variants, one-tile landmarks, uniform rows, repeated equidistant trees, constant-width painted paths, contradictory shadows or placeholder geometry.

## Production reference
The generated art-direction board produced for this pass is the mood/shape reference only. It is not a directly importable spritesheet: individual gameplay assets must be deliberately separated, cleaned, aligned to 32 px logic, given transparent backgrounds where needed, and validated in actual 1280x720 gameplay captures before acceptance.
