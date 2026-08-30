# 07 — Construcción y taller

## Objetivo
Que el taller crezca físicamente con el jugador.

## `BuildingDefinition`
Campos previstos: `id`, `category`, `footprint`, `build_cost[]`, `required_technology[]`, `allowed_zones[]`, `scene`, `rotations`, `upgrade_chain[]`, `station_tags[]`.

## MVP
No hace falta construcción libre completa. Bastan sockets/áreas predefinidas o placement limitado si reduce riesgo.

## Evolución
Banco básico → serrería → cantería → horno → herrería → estaciones especializadas → producción avanzada.

## Upgrades
Preferir mejorar una estación existente cuando evita clutter; upgrades pueden cambiar velocidad, recetas, colas, almacenamiento o compatibilidad con automatización.

## Reglas de colocación
Validar footprint, colisión, navegación, zona permitida y persistencia. El placement debe dar feedback válido/inválido.

## Principio de legibilidad
El taller debe parecer un lugar funcional, no una cuadrícula saturada. Mantener pasillos y espacios de interacción.