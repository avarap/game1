# Environment props — Phase 8 #28

Original presentation-only assets for the vertical slice. SVG canvases use crisp integer geometry and are intended to be imported with nearest-style sampling consistent with `ART_DIRECTION.md`.

| Asset | Canvas | Suggested ground pivot | Intended role |
|---|---:|---:|---|
| `tree.svg` | 64×96 | (32, 84) | tree/resource visual |
| `rock.svg` | 48×40 | (24, 34) | rock/mineral visual |
| `workbench.svg` | 64×48 | (32, 42) | workbench visual |
| `storage_chest.svg` | 48×40 | (24, 34) | storage visual |
| `bed.svg` | 64×64 | (32, 56) | sleep spot visual |
| `sign.svg` | 32×48 | (16, 42) | generic interactable/sign |

Collision, interaction areas and gameplay state remain outside these assets so existing scenes can preserve their functional footprints when visuals are swapped in.