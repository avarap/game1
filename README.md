# game1

RPG 2D de gestión, crafting, exploración y simulación construido con **Godot 4.7.2 + GDScript**.

El objetivo es un vertical slice original y pulido. Las fuentes de verdad son `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`, `ROADMAP.md`, `DEV_MEMORY.md`, `ART_DIRECTION.md` y las issues activas.

## Estado

- Fases **0–7 completadas**.
- Fase 8 — Polish está **activa**.
- HEAD de referencia: `a0a54f5ede3d37602bed5594957305b92577bb96`.
- CI de `main`: run `33400411975`, **success**.
- Gate P0 histórico #82/#83: **superado**.
- Godot objetivo de runtime/CI: **4.7.2**.
- #70 es el único gate autorizado para cerrar Fase 8.

## Ejecutar

1. Instala Godot 4.7.2.
2. Clona el repositorio.
3. Abre `project.godot`.
4. Ejecuta la escena principal con F5.

## Controles base

- Movimiento: WASD
- Interactuar: E
- Acción primaria/secundaria: ratón
- Inventario: I
- Mapa: M
- Pausa: Esc
- Panel debug: F12

## Loop jugable integrado

La build integrada incluye movimiento, recolección, inventario, energía, crafting/producción, cementerio, tiempo/día-noche, sueño, NPC con navegación/horarios persistentes, diálogo EN/ES, relaciones, quests, economía/comercio, tecnologías y mundo modular con cementerio/propiedad, bosque, pueblo, interiores y mina.

Track 8A tiene integrados deterioro/conservación, agricultura mínima, `fodder_turnip`, servicio funerario 18:00, logística progresiva, decisiones terminales de cadáver y feedback hooks exactly-once. La aceptación integral #66 está activa mediante #115 / PR #121.

El RED de #121 descubrió una regresión real en la integración WORLD de decisiones terminales. Ya existe una corrección mínima y el head `e37dc433...` está completamente verde en CI `33404377011`, incluyendo `Phase8AAcceptance`. El PR permanece sin integrar únicamente porque sigue marcado draft y la transición automática a ready está bloqueada por un fallo del conector GitHub; no se fuerza el merge.

## Reset visual obligatorio

Los screenshots existentes en `docs/` son la referencia oficial de calidad percibida. El estado visual actual se considera insuficiente hasta demostrar comparabilidad in-game.

No existe una restricción heredada de tamaño: `32x48` no es contrato obligatorio. Si hace falta aumentar resolución/escala de personajes, NPCs, edificios, tiles, props, vegetación o VFX, o ajustar cámara/zoom, debe hacerse de forma planificada.

Quality bar: pixel-art oscuro de alto detalle, siluetas claras, ocho direcciones realmente coherentes, cara/ropa/equipamiento/materiales legibles, arquitectura con personalidad, entorno denso y artesanal, iluminación cálida localizada, sombras profundas y acabado profesional.

PR #107 integró la recomendación arquitectónica de usar **64x96 nativo** para player/key NPCs y desacoplar canvas visual de colisión/navegación. PR #118 integró la política de prompts de producción y hace obligatorio usar `docs/` como benchmark sin copiar contenido protegido.

`ART_DIRECTION.md` conserva temporalmente el contrato histórico 32x48/1.5x hasta que #94 quede validada con evidencia real de #109; solo entonces el supervisor actualizará el contrato.

## Trabajo visual activo

- **CHARACTERS #109 / PR #114:** sincronizado con `main`, mergeable y CI `33405431151` verde. El candidato visual actual está **rechazado**: aún lee como placeholder ampliado. Debe rehacerse/mejorarse y aportar capturas #96 comparadas contra `docs/`.
- **WORLD #113 / PR #116:** sincronizado con `main`, mergeable y CI `33403543515` verde. Sigue bloqueado por aceptación perceptual y capturas #96; si SVG limita el acabado deberá migrarse a raster/layers.
- **QA #119:** completada. PR #120 se cerró sin merge después de generar el gameplay MP4 solicitado del baseline `98045f4...`.
- **ARCH #94:** abierta y bloqueada por la evidencia perceptual de #109.
- **AUDIO #93 / PR #122:** import, smoke y suite pasan, pero `gdformat --check` falla en el head actual; no es integrable todavía.

CI verde por sí solo no acepta ningún PR visual.

## UI

PR #78 integró theme/HUD/pause-settings EN/ES y PR #91 los paneles core. #68 sigue abierta hasta completar aceptación UI/visual.

## Arquitectura

Los Autoloads se limitan a `EventBus`, `GameManager`, `TimeManager`, `SaveManager` y `AudioManager`. Los sistemas RPG permanecen locales/contextuales y usan Resources tipados. UI observa modelos/controladores y emite intents; no contiene reglas de negocio. `SaveManager` agrega providers del grupo `save_provider`; `world/world.tscn` es el shell persistente y carga una zona activa bajo `ZoneContainer`.

## Calidad y tests

El CI ejecuta:

- `gdlint` global;
- `gdformat --check` global;
- Godot 4.7.2 import/validation;
- main-scene smoke;
- suite headless completa.

```bash
godot --headless --path . --script res://tests/run_tests.gd
```

## Cola autónoma

- GAMEPLAY: #115 / PR #121 — P0 técnicamente verde; pendiente readiness/integración supervisada.
- CHARACTERS: #109 / PR #114 — rework visual + evidencia #96.
- WORLD: #113 / PR #116 — evidencia perceptual #96.
- AUDIO: #93 / PR #122 — corregir `gdformat --check` y revalidar.
- ARCH: #94 bloqueada por #109.
- UI/POLISH: sin nuevo slot mientras estas cuatro unidades ocupen capacidad.

No se prepara una segunda tarea por carril mientras exista una issue preparada o PR activo.

## Documentación

- `MASTER_SPEC_RPG_Godot4_Graveyard_Inspired.md`: fuente funcional y arquitectónica.
- `ROADMAP.md`: fases, dependencias, gates y cola.
- `DEV_MEMORY.md`: memoria operativa.
- `ART_DIRECTION.md`: contrato visual pendiente de actualización tras #94.
- `art/PROMPT_POLICY.md` + `art/**/PROMPT.md`: contrato de generación/producción visual.
- `CHANGELOG.md`: historial técnico.
- `HISTORIA_PRINCIPAL.md`: narrativa.
- `LOCALIZATION.md`: política EN/ES.

## Post-MVP

Se conserva fuera del vertical slice la automatización avanzada con trabajadores originales de `game1` y tareas `HARVEST`, `MINE`, `CHOP`, `TRANSPORT` y `PROCESS`, evolucionando de trabajo manual a cadenas automatizadas mediante infraestructura, rutas y almacenamiento.
