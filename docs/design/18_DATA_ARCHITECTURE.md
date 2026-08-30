# 18 — Arquitectura data-driven

## Objetivo
Añadir/modificar contenido sin editar lógica central.

## Recursos sugeridos
- `ItemData`: id, nombre localizado, category, tags, stack, base value, sellable, icon.
- `RecipeData`: inputs[], outputs[], station tags, tech, time, fuel/energy.
- `CropData`: seed, produce, stages, duration, yield.
- `TechnologyData`: prerequisites[], costs, unlocks[].
- `MerchantProfile`: accept tags/categories, offers, multipliers, quotas.
- `BuildingDefinition`: footprint, costs, zones, upgrades, station tags.
- `WorldActionData`: requirements, costs, persistent consequence.
- `WorkerData`/`WorkerTaskData`: capabilities y restricciones.

## Registro
Un registry/catálogo debe resolver IDs y validar duplicados/referencias rotas.

## Validaciones automáticas
- IDs únicos.
- Recipe inputs/outputs existentes.
- Cultivos referencian seed/produce válidos.
- Tecnologías no tienen ciclos imposibles.
- Todo item vendible tiene comprador.
- Building costs referencian items válidos.
- Unlocks apuntan a IDs existentes.

## Compatibilidad
Persistencia guarda stable IDs y estado mínimo, no referencias de nodo frágiles.

## Acoplamiento
Sistemas operan con contratos/tags; evitar `if item_id == ...` repartidos por scripts.