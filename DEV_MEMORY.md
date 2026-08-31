# DEV MEMORY

Memoria operativa del proyecto. Leer antes de continuar y actualizar después de cada bloque significativo.

## Estado actual

- Repositorio: `avarap/game1`.
- Rama principal: `main`.
- Runtime/CI objetivo: **Godot 4.7.2**.
- Fases 0–7: **COMPLETADAS**.
- Fase 8 — Polish: **ACTIVA**.
- #25 — Tileset exterior: completado en PR #56; run `33333578933`, success.
- #28 — Props/edificios/cementerio: integrado en PR #79; main run `33340142216`, success.
- Track **8A — Gameplay Depth & Feel**: diseño aprobado y en implementación.
- **8A.1 — Descomposición acelerada:** implementado en PR #57.
- **8A.2 — Conservación:** implementado en PR #59; CI funcional `33336387360`, success.
- **8A.3 — Agricultura mínima:** integrado en PR #76; merge `b10146d12d5c6f0251b61ec779f4ecc7351e9257`; main run `33342619691`, success.
- Diseño 8A: `docs/superpowers/specs/2026-08-30-phase8a-cemetery-depth-design.md`.
- Biblioteca de ideas/diseño: `docs/design/`.
- Próximo bloque del track de profundidad: **8A.4 — recurso multiuso** (#61).
- PRs abiertos observados por integrador: #75 (#26), #80 (#29) y #78 (#68); todos requieren resincronización con el HEAD actual antes de integrar. #78 además es solo un incremento parcial de #68.

## Fuentes de verdad

- Funcional/arquitectónica: `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`.
- Diseño jugable: `GAME_DESIGN.md` + spec 8A.
- Planificación: `ROADMAP.md` + issues activas.
- Contrato visual: `ART_DIRECTION.md`.
- Narrativa: `HISTORIA_PRINCIPAL.md` — **El Cementerio de Valdeniebla**.
- Idiomas: `LOCALIZATION.md`.
- `docs/design/` es dirección secundaria/backlog; nunca permite adelantar una fase ni sustituye criterios de aceptación.

## Fases completadas

- Fase 0 — Bootstrap: run `33278173612`.
- Fase 1 — Core: run `33280758441`.
- Fase 2 — Items: run `33285578050`.
- Fase 3 — Crafting: run `33292481990`.
- Fase 4 — Cementerio: run `33294286014`.
- Fase 5 — Simulación: run `33297774458`.
- Fase 6 — RPG: PR #39, run `33308814397`.
- Fase 7 — Mundo: PR #54, run `33331207740`.

## Arquitectura estable

- Exactamente cinco Autoloads: `EventBus`, `GameManager`, `TimeManager`, `SaveManager`, `AudioManager`.
- `TimeManager` es la única fuente de reloj/calendario.
- RPG permanece local/contextual: diálogo, relaciones, quests, economía y tecnología.
- `SaveManager` agrega providers del grupo `save_provider`.
- UI observa controllers/modelos y emite intents; no contiene lógica de negocio.
- Quality gate descubre todos los `*.gd` y ejecuta `gdlint` + `gdformat --check` globalmente.
- Runtime y CI usan Godot 4.7.2.

## Contrato de mundo estable tras Fase 7

`ART_DIRECTION.md` + #16 fijan proyección 2D ortográfica cenital 3/4, tile lógico `32 x 32 px`, seis `TileMapLayer`, pivote/Y-sort en pies, resolución `1280 x 720`, zoom base `1.5x` y gameplay fuera de tiles.

`world/world.tscn` es el shell persistente. `ZoneManager` mantiene una sola zona bajo `ZoneContainer` y conecta cementerio/propiedad, bosque, pueblo, dos interiores y mina. Player, controllers y Brother Aldren preservan identidad lógica durante viajes. `WorldLocationProvider` persiste zona/marker/posición, la cámara adopta bounds de la zona activa y comercio/NPC se activan según zona.

## Fase 8 — visual

- #25 introdujo el atlas exterior original `256 x 256`, 64 celdas de `32 x 32`, desacoplado de gameplay/colisión/navegación.
- #28 añadió props, fachadas y assets de cementerio desacoplados del gameplay.
- #26–#31 siguen su propio sub-track visual; pueden avanzar en trabajo independiente siempre que no pisen contratos de gameplay 8A.
- #29 ya tiene dependencias funcionales satisfechas (#25 y #28), pero su PR #80 debe sincronizarse con `main` y volver a pasar CI antes de integración.

## Fase 8A — decisiones aprobadas

### Cadáveres
- Estado canónico: `decay_percent: int` `0..100` y `age_minutes: int`.
- No existe obligación de compatibilidad con saves legacy porque aún no hay saves de jugadores en circulación.
- Estados visibles: Fresh `0–24`, Fading `25–49`, Decomposed `50–74`, Rotten `75–100`.
- Ritmo por edad: 0–24 h lento, 24–48 h medio, 48–72 h rápido, >72 h muy rápido.
- La implementación 8A.1 usa acumulador privado entero para conservar progreso subporcentual sin persistir floats.
- Calidad efectiva pierde 0/1/2/3 puntos según estado, con mínimo 0.
- Grandes saltos de tiempo producen el mismo resultado que avances equivalentes pequeños.
- Preparar no reduce edad ni descomposición.
- Objetivo posterior: preparar, enterrar, cremar e investigar con trade-offs distintos.

### Conservación — implementada en 8A.2
- `effective_rate = age_rate × technology_modifier × facility_modifier × tool_modifier`.
- `PreservationModifiers` usa basis points enteros (`10000 = 1.0`) para tecnología, instalación y utensilio.
- Los tres factores son neutrales por defecto, se normalizan a `1..10000` y se componen multiplicativamente.
- La conservación solo ralentiza deterioro futuro; nunca reduce `age_minutes`, `decay_percent`, unidades acumuladas ni el resto fraccional pendiente.
- `CorpseState` persiste los modificadores y `_preservation_remainder` para mantener determinismo y round-trip exacto.
- Cambiar de modificadores conserva el resto fraccional previo; descartarlo equivaldría a perdonar deterioro subporcentual.
- La rampa de entrega sigue siendo logística únicamente, sin bonus de conservación.

### Agricultura — implementada en 8A.3
- Stable IDs: `fodder_turnip_seed` y `fodder_turnip`.
- `CropData` y `FarmPlotState` son data-driven y deterministas.
- Plantar consume exactamente una semilla solo si la parcela acepta la acción.
- Crecimiento usa tiempo lógico de `TimeManager`; saltos grandes y refrescos pequeños son equivalentes.
- Cosecha concede una sola vez el item configurado, respeta capacidad y deja la parcela reutilizable.
- Snapshot/restore conserva cultivo, tiempo plantado y estado cosechable sin duplicación.
- Integración: PR #76; main run `33342619691` verde.

### Servicio funerario
- Entrega diaria determinista al atardecer; objetivo inicial **18:00**.
- Cruzar las 18:00 mediante juego normal, sueño o salto de tiempo procesa como máximo una entrega por día.
- Save/load no puede duplicar entregas.
- Introducción temporalmente gratuita; tras quest requiere alimento cultivable desde un comedero.
- Sin alimento suficiente: entrega suspendida, sin inventario negativo.
- Personaje/animal/quest/textos/assets serán originales.

### Recurso multiuso
- `fodder_turnip` debe conectarse ahora con inventory/storage, economía y crafting reutilizando APIs existentes.
- Debe ser comprable/vendible y tener al menos una receta útil sin introducir hambre ni supply/demand.
- Cultivar debe resultar más sostenible que depender de compra continua.

### Logística, economía y feedback
- Inicio: descarga junto al camino; progresión: rampa desbloqueable al área de recepción.
- Pipeline futuro de precios: base × global × merchant × relationship, neutral `1.0` por defecto; sin supply/demand complejo.
- Feedback placeholder reutiliza EventBus/AudioManager.

## Integración y coordinación actual

- Solo el integrador actualiza `ROADMAP.md`, `DEV_MEMORY.md`, `CHANGELOG.md` y `README.md` durante trabajo paralelo.
- No iniciar nuevas features desde el integrador.
- PR #75 (#26): scope correcto y CI previo verde, pero branch stale frente a `main`; se dejó diagnóstico para resincronizar y revalidar.
- PR #80 (#29): scope correcto y CI previo verde, pero draft/unmergeable y stale; requiere sync + CI nuevo.
- PR #78 (#68): incremento UI coherente pero no satisface toda #68; requiere sync y completar la issue o subdividir formalmente el trabajo restante.
- No marcar Fase 8 completa salvo cierre real de #70 sobre el HEAD final.

## Biblioteca de diseño (`docs/design/`)

- Captura todas las ideas discutidas a partir de referencias visuales y análisis del proyecto.
- Categorías: visión, orden de ejecución, loops, mundo, recursos, crafting, tecnología, construcción, economía, farming, NPCs, cementerio, tiempo/clima, exploración, automatización, UI, arte, progresión y arquitectura data-driven.
- `19_IDEA_BACKLOG.md` separa MVP/post-MVP/expansión.
- `20_IMPLEMENTATION_PROMPTS.md` contiene prompts listos para profundizar o ejecutar bloques futuros.
- Orden recomendado futuro: cerrar Fase 8/8A → consolidar items/recetas/cadenas → grafo tecnológico/economía profesional → construcción/restauración/logística → clima/pesca → automatización.
- Principios nuevos consolidados: densidad antes que tamaño, progreso visible en el mundo, fricción que luego pueda eliminarse, recetas N→N con subproductos, merchants por profesión y contenido extensible mediante Resources/stable IDs/tags.

## Expansiones post-MVP registradas

### Economía local por profesión
- Todo objeto producido que sea vendible debe tener al menos un comprador válido.
- No todos los aldeanos comercian; la capacidad de comerciar es explícita por NPC.
- Los compradores usan `MerchantProfile` data-driven con `accept_tags`/categorías por profesión, no condicionales hardcodeados por item.
- Ejemplo contractual: el herrero compra `iron`, `ore`, `metal_part` y `tool`, pero no acepta cultivos, comida o madera ajena a su oficio.
- Puede existir un comerciante general con mayor cobertura pero peor precio para dar salida económica a recursos comunes.
- La afinidad profesional puede afectar el precio y cada comerciante puede tener límites de demanda/cupo para impedir venta infinita.
- Excepciones explícitas a la obligación de comprador: `quest_only`, `key_item`, `non_sellable`.
- Debe existir validación automática que detecte cualquier `ItemData` vendible sin un `MerchantProfile` compatible.
- Añadir/modificar recursos y comerciantes debe ser principalmente configuración/contenido.

### Automatización avanzada
- Expansión posterior al primer vertical slice/MVP.
- Trabajadores originales del mundo de `game1`, sin copiar zombies del benchmark.
- Tareas previstas: `HARVEST`, `MINE`, `CHOP`, `TRANSPORT`, `PROCESS`.
- Evolución manual → automatización parcial → cadenas de producción completas.
- Requiere infraestructura, rutas, almacenamiento y mantenimiento/energía.

## Scope fuera de 8A

- Hambre/sed.
- Estaciones/clima agrícola.
- Riego/fertilizante complejo.
- Mercado supply/demand.
- Combate nuevo.
- Mapas grandes nuevos.
- Copiar elementos específicos/protegidos del benchmark.

## Próximo paso

1. Mantener `main` verde tras cada integración.
2. Siguiente issue funcional habilitada: **#61 — 8A.4 recurso multiuso**; el integrador no la implementa.
3. Esperar PRs workers actualizados para #26/#29/#68 y revisar uno a uno.
4. Mantener trackers #71/#72/#73 alineados con issues realmente cerradas.
5. No marcar Fase 8 ni Track 8A como completos antes de sus gates #70/#66.

## Regla de continuidad

Al retomar:
1. Leer `DEV_MEMORY.md`, `ROADMAP.md`, `GAME_DESIGN.md`, spec 8A, `ART_DIRECTION.md` y la issue/PR activo.
2. Revisar `main`, PRs abiertos y último CI.
3. Comprobar dependencias antes de iniciar trabajo nuevo.
4. El integrador no implementa features; revisa ownership/scope/dependencias/tests/CI y solo integra PRs conformes y actualizados.
5. Ejecutar o exigir quality gate, importación, smoke y suite headless sobre Godot 4.7.2.
6. Corregir errores críticos antes de avanzar.
7. Solo el integrador sincroniza documentación global durante trabajo paralelo.
8. No marcar una fase completada antes de cumplir todos sus criterios de aceptación.
