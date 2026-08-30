# 04 — Recursos y recolección

## Objetivo
Catálogo pequeño en MVP, extensible sin cambiar lógica central.

## Familias iniciales sugeridas
- Bosque: `wood`, `branch`, `resin`.
- Minería: `stone`, `iron_ore`, `coal`, `clay`.
- Agricultura: `fodder_turnip_seed`, `fodder_turnip`, después `wheat_seed`, `wheat`.
- Cementerio: `bone`, `fat` y materiales narrativamente apropiados.
- Procesados: `plank`, `treated_plank`, `stone_block`, `iron_ingot`, `brick`, `flour`.
- Subproductos: `sawdust`, `slag`, `ash`.

## Reglas
- Todo item tiene stable id y tags.
- Todo item vendible debe tener salida económica futura.
- Evitar items sin segunda función cuando sea razonable.
- Recurso raro debe tener razón geográfica/tecnológica.

## Tags ejemplo
`raw_material`, `forest_resource`, `ore`, `iron`, `crop`, `food`, `processed_material`, `fuel`, `byproduct`, `funerary`.

## Recolección
Los nodos deben declarar qué producen, herramienta/requisito, coste de energía, respawn/regeneración y feedback.

## Transporte pesado — post-MVP
Troncos, grandes bloques o cadáveres pueden ser `heavy/carryable`; objetivo: dar valor a logística, no castigar permanentemente al jugador.