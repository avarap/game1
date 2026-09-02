# Cemetery Production Asset Manifest

This manifest is the acceptance checklist for replacing prototype art. An item is not `final` until it has been seen in an actual gameplay capture.

| Family | Minimum | Intended size | Layer | Status |
|---|---:|---|---|---|
| Ground base materials | 8 | 32x32 | background | required replacement |
| Ground decals | 16 | 32x32 / 64x32 | background | required replacement |
| Path topology pieces | 24 | 32x32 | background | required replacement |
| Short/tall grass | 8 | 32x32 / 64x64 | low | required replacement |
| Shrubs/ferns | 8 | 64x64 | y-sorted | required replacement |
| Dry/bramble/root clusters | 8 | 32x32 / 64x64 | low/y-sorted | required replacement |
| Mature trees | 3 | 96x128+ | split y-sort/foreground | required replacement |
| Young/dead/twisted/moss trees | 6 | 64x96+ | split y-sort/foreground | required replacement |
| Poor/ordinary/old graves | 9 | 32x48 / 64x64 | y-sorted | required replacement |
| Broken/abandoned graves | 4 | 32x48 / 64x64 | y-sorted | required replacement |
| Crosses/statues | 4 | 32x64 / 64x96 | y-sorted | required replacement |
| Mausoleum | 2 | 96x96+ | y-sorted | required replacement |
| Wall/pillar/gate modules | 10 | 32x64 / 64x96 / 128x96 | y-sorted | required replacement |
| Benches/lanterns/funeral flowers | 8 | 32x32 / 64x64 | y-sorted | required replacement |
| Work/funeral props | 16 | 32x32 / 64x64 | low/y-sorted | required replacement |
| Workshop/home landmark | 1 | 320x256+ | y-sorted | required replacement |
| Cemetery entrance landmark | 1 | 192x128+ | y-sorted | required replacement |
| Plaza focal composition | 1 | 192x160+ | mixed | required replacement |
| Grave-field composition kit | 1 | multi-asset | mixed | required replacement |
| Forest-road framing kit | 1 | multi-asset | mixed/foreground | required replacement |

## Capture gates

Final acceptance requires 1280x720 captures of workshop, plaza, cemetery overview, grave field and forest road. Each capture is reviewed for repeated silhouettes, rectangular composition, obvious tile boundaries, weak depth, scale conflicts, excessive noise and missing visual hierarchy.

## Current technical debt

The current `tileset_cemetery_32.png` and `building_workshop_exterior.png` remain connected so gameplay does not break while replacements are authored. They are transitional assets and must not be used as the visual-quality target. The previous generator has been converted to validation-only so it cannot overwrite future authored art with procedural prototype geometry.
