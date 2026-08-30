# 05 — Crafting y producción

## Contrato deseado
`RecipeData` debe soportar múltiples inputs, múltiples outputs y subproductos. Nada de asumir un único input/output.

## Ejemplos de prueba
- `wood → plank + sawdust`.
- `wood + resin → treated_plank + sawdust`.
- `iron_ore + coal → iron_ingot + slag`.
- `clay + fuel → brick + ash`.
- `wheat → flour`.
- `plank + iron_part → tool`.

## Campos futuros
`id`, `inputs[]`, `outputs[]`, `station_tags[]`, `required_technology[]`, `production_time`, `energy/fuel`, `quality_rules`, `automation_allowed`.

## Estaciones
Cada estación declara capacidades por tags, no recetas hardcodeadas en scripts. Ejemplo: `sawmill` procesa `woodworking`; `furnace` procesa `smelting`.

## Subproductos
Son items normales: pueden venderse, reciclarse, alimentar otra receta o convertirse en residuo. Esto crea economía circular.

## Prueba de profundidad
El MVP debe incluir al menos una receta simple, una multi-input, una multi-output y una cadena de 3 niveles.