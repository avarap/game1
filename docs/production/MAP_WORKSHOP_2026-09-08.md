# MAP — workshop path checkpoint, 2026-09-08

Scope: `feat/main-map-rebuild-commercial-pass`, PR #142, based on
`92dcc26f907071ffdcb2fe72dd7b56dc5dffb385`. MAP remains visually unaccepted;
formal integration #138 stays parked.

## Change

The workshop apron used narrow four-way path tiles as a solid fill. Their
transparent corners repeated as holes and loops. Replace that fill with a
single authored route through the workshop, short approaches to the bed,
workbench and chest, and a connected exit to the stone plaza. This removes
39 path cells and adds 20 deliberately connected cells in the same zone.

Only the `paths` layer changes. Ground, collision cells, navigation, map
footprint, props, interaction positions, player and NPC files are unchanged.
The three CI checkouts now execute the PR head that capture metadata names,
so the images can be reviewed against the actual evaluated commit.

## Verification and acceptance boundary

- Godot `4.7.2.stable.official.ed1daf0bf`: import, main-scene smoke and the
  complete core suite pass locally, including cemetery traversal/navigation.
- Decoded scene comparison confirms all other node data is byte-identical.
- The local renderer cannot open a display socket. Visual acceptance is
  therefore pending inspection of this commit's CI artifact
  `cemetery-visual-captures`, especially `cemetery_workshop.png`,
  `cemetery_plaza.png` and the player/NPC contextual views.
- Passing tests do not establish visual acceptance, animation quality, or
  completion of the rest of the map. Existing shutdown resource warnings
  remain outside this path-only change.

## Next

Inspect the current head's captures first. If the workshop route reads
continuously without the former lattice, continue the same cleanup in the
grave aisles: eliminate repeated loop junctions while preserving the aisle
cells required by cemetery navigation. Repeated trees, unfinished signs and
the shared player/Aldren scale discrepancy remain separate open concerns.
