# 20 — Prompts de elaboración e implementación

Estos prompts son plantillas. Antes de ejecutarlos: revisar `DEV_MEMORY.md`, `ROADMAP.md`, último CI y dependencias. No saltar fase activa.

## P-RES-01 — Catálogo de recursos
> Analiza `ItemData`, inventario, crafting, economía y assets actuales. Diseña e implementa un catálogo data-driven con stable IDs, categorías y tags, sin romper saves ni contratos existentes. Añade validación de IDs duplicados y referencias. Empieza con el mínimo de items necesarios para las cadenas aprobadas. TDD, smoke y CI.

## P-CRAFT-01 — Recetas N→N
> Evoluciona `RecipeData` para soportar múltiples inputs y outputs/subproductos de forma atómica y data-driven. Mantén compatibilidad con recetas actuales o migra explícitamente si no hay saves externos. Prueba receta simple, multi-input, multi-output, rollback por falta de materiales y persistencia.

## P-CHAIN-01 — Cadena de madera
> Implementa una cadena jugable corta de madera usando datos: recolección → procesado → producto compuesto, incluyendo al menos un subproducto reutilizable. Evita añadir sistemas no necesarios. Integra crafting, storage, tecnología y venta si sus dependencias están listas.

## P-CHAIN-02 — Metalurgia
> Implementa `iron_ore + coal → iron_ingot + slag` y una receta posterior que combine metal con otro material. Define estación/requisito tecnológico solo si el roadmap lo permite. Valida atomicidad, tags, economía y save/load.

## P-TECH-01 — Grafo tecnológico
> Audita el sistema de tecnología existente y conviértelo, si procede, en un grafo data-driven con prerequisites y unlocks de recetas/estaciones/world actions. Detecta ciclos y referencias rotas. No copies árboles tecnológicos externos.

## P-ECON-01 — Comerciantes por profesión
> Implementa `MerchantProfile` data-driven. No todos los NPC comercian. Los comerciantes aceptan items por tags/categorías; el herrero acepta hierro/mineral/piezas/herramientas. Añade comerciante general de peor precio solo si aporta salida económica. Crea validación que falle si un item vendible no tiene comprador.

## P-FARM-01 — Agricultura extensible
> Partiendo de 8A.3, extrae/valida un `CropData` genérico para añadir nuevos cultivos sin lógica específica. Añade un segundo cultivo únicamente después de cerrar el loop del nabo. Prueba crecimiento por TimeManager, saltos de tiempo, cosecha y save/load.

## P-BUILD-01 — Construcción limitada
> Diseña la mínima construcción modular útil para el taller: `BuildingDefinition`, footprint, costes, zonas permitidas, preview válido/inválido y persistencia. Prioriza sockets/áreas acotadas antes que un editor libre si reduce complejidad.

## P-WORLD-01 — Restauración persistente
> Añade `WorldActionData` para reparar o desbloquear una pieza concreta del mundo mediante materiales + tecnología/quest. Debe cambiar visual/colisión/navegación de forma persistente y no romper transiciones de zona.

## P-LOG-01 — Transporte pesado
> Diseña un recurso voluminoso/carryable que no use el inventario normal. Implementa solo un caso de prueba y una mejora logística que reduzca la fricción. No conviertas todos los recursos en objetos físicos.

## P-CEM-01 — Cementerio evolutivo
> Conecta rating y decisiones funerarias con una mejora visible/persistente del cementerio. Evita bonus numéricos aislados: la mejora debe abrir función, capacidad o feedback visible.

## P-UI-01 — HUD contextual
> Audita el HUD y reduce información permanente. Diseña prompts contextuales, quick slots y paneles dedicados para tecnología/comercio/construcción, respetando localización y control gamepad/teclado.

## P-ART-01 — Densidad exterior
> Usando `ART_DIRECTION.md`, mejora una zona existente con variaciones originales de terreno, vegetación, props y landmarks sin cambiar gameplay. Mide legibilidad, colisiones y coste de render. No reproduzcas composiciones de referencias.

## P-LIGHT-01 — Atmósfera
> Implementa una capa mínima de iluminación/partículas para una zona e interior. Debe responder al ciclo temporal existente cuando proceda y mantener legibilidad. Añade presupuesto de rendimiento y fallback.

## P-WEATHER-01 — Clima visual
> Diseña clima data-driven inicialmente cosmético/contextual: lluvia y niebla. Integra eventos y persistencia sin afectar farming. Solo después evalúa efectos de gameplay.

## P-FISH-01 — Pesca post-MVP
> Diseña un sistema de pesca original con spots, catálogo de peces, cebo/herramienta, tiempo y outputs conectados a cocina/comercio. Construye primero un prototipo de un spot y 2–3 peces; evita copiar minijuegos externos.

## P-AUTO-01 — Contrato de trabajadores
> Sin automatizar aún, audita estaciones, storage y producción para definir una interfaz `worker/task` neutral que pueda usar jugador o futuro trabajador. No introducir dependencias prematuras.

## P-AUTO-02 — Primer trabajador automatizado
> Solo cuando producción, storage y rutas sean estables: implementa un trabajador original capaz de una tarea (`TRANSPORT` o `PROCESS`) con límites de capacidad/ruta/energía. Prueba bloqueo, recuperación y save/load antes de añadir más tipos.

## P-AUTO-03 — Red productiva
> Expande automatización desde un trabajador probado a una cadena extracción → transporte → almacenamiento → procesado. Añade observabilidad/debug y evita generación de recursos sin fuente física.

## P-BAL-01 — Evaluación del MVP
> Revisa telemetría manual/tests del loop: tiempo por tarea, viajes, recursos sin uso, recetas con demasiados pasos y desbloqueos irrelevantes. Propón qué cortar, simplificar o profundizar antes de aumentar contenido.

## Prompt maestro de ejecución
> Continúa `avarap/game1` siguiendo las fuentes de verdad. Revisa estado y último CI. Selecciona únicamente el siguiente bloque permitido por `ROADMAP.md`. Consulta `docs/design/` como dirección secundaria, nunca como permiso para adelantar alcance. Implementa con TDD cuando cambie comportamiento, conserva ejecución, valida quality/import/smoke/suite, actualiza `DEV_MEMORY.md`, `ROADMAP.md`, `CHANGELOG.md` y persiste en GitHub. No marques fases completas sin criterios de aceptación.