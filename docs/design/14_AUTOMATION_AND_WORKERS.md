# 14 — Automatización y trabajadores

## Estado
POST-MVP. No implementar antes de que producción, storage, rutas y estaciones sean robustos.

## Fantasía propia
Trabajadores no-muertos/constructos/espíritus vinculados originales del universo de `game1`; no copiar zombies, nombres, apariencia ni reglas específicas del referente.

## Tareas
`HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`.

## Arquitectura
`WorkerData` + `WorkerTaskData` + capacidades/tags. Las estaciones aceptan `worker` abstracto para jugador o automatización.

## Límites
Infraestructura, rutas, capacidad de carga, almacenamiento destino, mantenimiento/energía y productividad. Evitar generadores mágicos de recursos.

## Progresión
Manual → herramientas/mejor storage → carro/logística → trabajador individual → red parcial → cadenas completas.

## Valor jugable
Automatización elimina tareas dominadas y mueve la diversión desde ejecución repetitiva a diseño de red productiva.