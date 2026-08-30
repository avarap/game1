# Exterior tileset atlas

`exterior_tileset.svg` is the original exterior atlas for the vertical slice.

## Contract

- Native atlas size: `256 x 256 px`.
- Grid: `8 x 8` cells.
- Tile size: `32 x 32 px`.
- All geometry is aligned to integer pixels and rendered with `shape-rendering="crispEdges"`.
- Palette is derived exclusively from `ART_DIRECTION.md`.
- No asset, tile, palette, silhouette or composition is copied from Graveyard Keeper.
- Runtime filtering remains nearest/point according to the project visual contract.

## Cell layout

Coordinates are `(column,row)`, zero-based.

| Row | Cells | Purpose |
| --- | --- | --- |
| 0 | `(0..3,0)` | grass variants |
| 0 | `(4..7,0)` | soil variants |
| 1 | `(0..4,1)` | horizontal, vertical, corner and cross paths |
| 1 | `(5..7,1)` | grass/soil transitions and worn path |
| 2 | `(0..7,2)` | cemetery ground, dirt, moss, path, chips and worn variants |
| 3 | `(0..7,3)` | forest floor, leaves, roots, path, moss, dark and clearing variants |
| 4 | `(0..7,4)` | town cobble/plaza/dirt/border/worn variants |
| 5 | `(0..7,5)` | north/south/east/west terrain borders and four corners |
| 6 | `(0..7,6)` | low decorations: grass, flower, stones, leaves, moss, cracks, bones, rust |
| 7 | `(0..7,7)` | darker zone variants and restrained warm/mist/night accents |

## Usage constraints

This atlas is presentation-only. It must not encode gameplay, collisions, navigation or interactions. Map integration belongs to issue #29 and must preserve the six-layer `TileMapLayer` contract from `ART_DIRECTION.md`.
