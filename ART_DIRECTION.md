# ART DIRECTION — El Cementerio de Valdeniebla

Estado: contrato visual P0 para Fase 7 y producción visual posterior.

Este documento fija las métricas compartidas por mapas, personajes, props y edificios. Su objetivo es permitir que distintas tareas produzcan contenido compatible sin tomar decisiones locales de escala, pivote, paleta o capas.

## 1. Perspectiva y proyección

El vertical slice usa **2D ortográfica cenital 3/4**, no una cuadrícula isométrica de rombos.

- Ejes lógicos del mundo: X horizontal, Y vertical en coordenadas Godot.
- El suelo usa tiles cuadrados de `32 x 32 px`.
- Los personajes se dibujan en vista 3/4: se ve cabeza, torso y una porción limitada de hombros/espalda, manteniendo los pies como punto de anclaje visual.
- Los edificios pueden mostrar fachada y cubierta en falsa profundidad, pero su footprint de gameplay sigue siendo ortogonal a la cuadrícula.
- No se debe sesgar la navegación, las colisiones ni la lógica para simular una proyección isométrica real.
- La profundidad visual se resuelve con Y-sort, solapes y foreground/occlusion.

Esta decisión conserva el movimiento actual en ocho direcciones, las colisiones 2D y la navegación existente, y evita que arte y gameplay dependan de transformaciones isométricas adicionales.

## 2. Unidad lógica y escala

### Tile base

- Tile lógico: `32 x 32 px`.
- Medio tile: `16 px`.
- Cuarto de tile: `8 px`.
- Todos los pivotes y footprints principales deben alinearse a múltiplos de `8 px`, salvo detalles puramente decorativos.
- Props mayores de un tile se construyen en múltiplos enteros de 32 px siempre que el diseño lo permita.

### Resolución y cámara

- Resolución lógica de referencia: `1280 x 720`.
- Filtro de texturas: nearest/point, sin suavizado.
- Zoom base de gameplay: `1.5 x`, coincidiendo con la cámara actual del player.
- El arte se autoriza a resolución nativa; no se dibujan sprites preescalados a `1.5 x`.
- Cambios futuros de zoom deben mantener escalado entero o visualmente estable y no redefinir el tamaño de tile.

A `1.5 x`, un tile de 32 px ocupa 48 px de pantalla. Esto permite mostrar aproximadamente 26.6 tiles horizontales y 15 tiles verticales en la referencia de 1280x720.

## 3. Personajes

### Footprint de gameplay

El player actual utiliza una cápsula de `20 px` de ancho y `28 px` de alto. Ese footprint se conserva como referencia de colisión mientras Fase 7 no requiera un cambio explícito de gameplay.

Contrato de personaje humano estándar:

- Sprite canvas recomendado: `32 x 48 px` por frame.
- Altura visual objetivo: `44–48 px`.
- Anchura visual de cuerpo: `20–28 px`.
- Punto de origen del nodo: centro de los pies.
- Línea de pies: `y = 0` local.
- Sprite visible: se extiende principalmente hacia Y negativo desde el origen.
- Collision footprint objetivo: `20 x 28 px`, centrado alrededor de la parte baja del cuerpo; no debe crecer para cubrir sombreros, brazos, herramientas o ropa.
- Interacción: mantener el radio funcional existente salvo tarea de gameplay específica.

### Ejemplo de footprint

```text
Frame visual 32 x 48

       ┌──────────────┐  y=-48
       │    cabeza    │
       │              │
       │    torso     │
       │              │
       │    piernas   │
       └──────┬───────┘
              ●          y=0  <- pivot / pies / Y-sort

Collision aproximada:
       ancho 20 px
       alto  28 px
       situada en la zona inferior del cuerpo
```

El sprite puede sobresalir por encima de la colisión. El Y-sort siempre compara la posición de los pies, no el centro visual del frame.

### Player y NPCs

- Player y Brother Aldren comparten escala corporal base.
- Variaciones de altura entre adultos: máximo `±4 px` sobre la altura visual estándar, salvo personaje cuya silueta excepcional sea parte del diseño.
- Niños o criaturas pueden usar otra altura, pero conservan el mismo sistema de pivote.
- Accesorios altos no cambian el pivot ni el footprint de colisión.

## 4. Direcciones y spritesheets

Animación mínima compatible con movimiento en ocho direcciones:

- Direcciones visuales base: `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`.
- Se permite espejar `E/W`, `NE/NW` y `SE/SW` si el diseño no contiene elementos asimétricos que lo impidan.
- Idle: mínimo 1 frame por dirección utilizada.
- Walk: objetivo 6 frames por ciclo; mínimo aceptable 4.
- Duración objetivo de walk: `0.6 s` por ciclo completo.
- Herramientas o acciones se añaden en sheets separados si su tamaño rompe el canvas base.

Convención de sheet:

```text
<character>_<action>_<direction>_<frame>.png
player_walk_s_00.png
player_walk_s_01.png
aldren_idle_ne_00.png
```

Si se usa atlas único:

```text
art/characters/player/player_walk.png
art/characters/aldren/aldren_walk.png
```

El import debe conservar píxel nítido y evitar filtering lineal.

## 5. Y-sort, pivotes y oclusión

Regla principal: **la base física que toca el suelo define la profundidad**.

- Personajes: pivot en centro de pies.
- Árboles: pivot en centro de la base del tronco.
- Tumbas: pivot en centro inferior del footprint que toca el suelo.
- Barriles/cajas: pivot en centro de su base.
- Edificios: la parte transitable/puerta define la relación de profundidad; cubiertas altas pueden separarse a foreground.
- Objetos bajos que nunca deben tapar al jugador pueden permanecer en `decoration_low` sin Y-sort.

### Ejemplo de objeto Y-sorted

Árbol visual `64 x 96 px` sobre footprint lógico `32 x 24 px`:

```text
        copa 64 x 72
      ┌──────────┐
      │          │
      │          │
      └────┬─────┘
           │ tronco
       ┌───●───┐       <- pivot/Y-sort en base del tronco
       │32x24  │       <- footprint de colisión
       └───────┘
```

La copa puede cubrir al player cuando sus pies estén por encima del pivot del árbol. Si la oclusión bloquea información crítica, se usa una capa de foreground separada o fade de presentación; no se altera la colisión para solucionar un problema visual.

## 6. Contrato de capas de mapa

Cada mapa exterior debe poder representar estas capas conceptuales, preferentemente mediante `TileMapLayer` cuando sean tile-based:

1. `ground`
   - terreno base;
   - siempre por debajo del gameplay;
   - sin colisión.

2. `paths`
   - caminos, tierra pisada, bordes y transiciones;
   - sobre `ground`;
   - sin lógica de gameplay salvo metadatos explícitos futuros.

3. `decoration_low`
   - hierba corta, flores, piedras pequeñas, manchas, hojas;
   - no tapa pies ni interacciones;
   - sin Y-sort obligatorio.

4. `collision`
   - capa técnica invisible o visualizable solo en debug;
   - define obstáculos tile-based;
   - nunca contiene arte principal.

5. `objects_y_sorted`
   - árboles, tumbas, vallas altas, props grandes, fachadas con profundidad;
   - pivote en contacto con suelo;
   - comparte reglas Y-sort con personajes.

6. `foreground_occlusion`
   - copas altas, cubiertas, dinteles o elementos que pueden pasar delante de cámara/player;
   - debe usarse con moderación;
   - no contiene colisión por defecto.

Orden base de render:

```text
ground
paths
decoration_low
objects_y_sorted + characters
foreground_occlusion
UI
```

## 7. Paleta y valores

La dirección cromática es cálida, terrosa y ligeramente desaturada. No se copia ninguna paleta propietaria de juegos de referencia.

### Paleta base

| Rol | Hex | Uso principal |
| --- | --- | --- |
| Ink dark | `#24231F` | contorno profundo, huecos |
| Soil dark | `#4A3B32` | tierra húmeda, madera oscura |
| Soil | `#715845` | caminos, madera media |
| Ochre | `#A77B45` | paja, luces cálidas, tierra seca |
| Moss dark | `#344536` | bosque/cementerio oscuro |
| Moss | `#566B45` | vegetación base |
| Grass | `#75835A` | vegetación iluminada |
| Bone | `#C9BE9B` | piedra clara, hueso, UI diegética |
| Warm light | `#E0B66C` | lámparas, ventanas, highlights |
| Mist | `#8A9290` | niebla/fríos atmosféricos |
| Night blue | `#303947` | noche y sombras frías |
| Accent rust | `#9A5140` | telas, señalética, acentos |

Los sprites pueden introducir tonos derivados, pero deben mantenerse cerca de estas familias y no competir con los puntos interactivos.

### Rangos por zona

- **Cementerio:** valor medio `25–60%`; verdes grisáceos, piedra fría, suelo oscuro; acentos cálidos reservados a velas, taller y puntos importantes.
- **Bosque:** valor medio `30–70%`; verdes musgo, marrones y ocres; mayor contraste local en senderos y recursos recolectables.
- **Pueblo:** valor medio `40–80%`; piedra cálida, madera, tejas y telas; es la zona exterior más luminosa y cromáticamente acogedora.
- **Interiores:** valor medio `35–85%`; fondos más oscuros y luz cálida focal; objetos interactivos deben separarse del fondo por valor o borde.

Regla de legibilidad: personaje y elementos interactivos deben mantener al menos un salto perceptible de valor respecto al suelo inmediato; evitar siluetas que desaparezcan en fondos del mismo valor.

## 8. Luz y sombras

Dirección de luz diurna estándar:

- Luz principal imaginaria desde **arriba-izquierda**, vector visual aproximado `(-1, -1)`.
- Highlights principales en bordes superior e izquierdo.
- Sombras proyectadas hacia abajo-derecha.
- Longitud de sombra de props pequeños al mediodía: `6–10 px`.
- Sombras de árboles/edificios pueden ser mayores, pero no deben ocultar rutas ni interacciones.
- Sombras usan colores teñidos, no negro puro; referencia inicial `#30312D` con opacidad visual equivalente a `35–55%` según zona.

El ciclo día/noche existente sigue siendo la única autoridad temporal. Fase visual puede modular CanvasModulate, luces y materiales, pero no crear un segundo reloj.

## 9. Contornos, detalle y dithering

- Contorno exterior: `1 px` en sprites principales cuando mejore la silueta.
- No usar contorno negro puro universal; preferir `Ink dark` o una variante oscura del material.
- Contornos interiores: selectivos, no dibujar cada separación del sprite.
- Densidad de detalle: concentrar detalle en cara, manos, herramientas y puntos de lectura; superficies grandes usan clusters simples.
- Dithering: permitido solo como recurso puntual para transiciones de sombra, niebla o materiales; patrón máximo recomendado `2 x 2 px`.
- No usar anti-aliasing pintado.
- No mezclar pixel art nítido con ilustraciones suavizadas dentro de la misma escena de gameplay.

## 10. Props y edificios

### Footprints

- Prop pequeño: `16–32 px` de base.
- Prop medio: `32–64 px` de base.
- Prop grande/árbol: footprint físico objetivo de `32–64 px`, aunque el sprite visible sobresalga mucho más.
- Puerta exterior: abertura navegable mínima visual de `32 px`; si la colisión necesita más margen, resolverlo en la escena técnica sin escalar el arte completo.

### Edificios

- La cuadrícula estructural usa módulos de `32 px`.
- Fachadas deben poder alinearse con caminos y puertas de la cuadrícula.
- Tejados/cubiertas pueden sobrepasar el footprint entre `8 y 24 px` por lado.
- Las cubiertas que ocluyen al player deben separarse del cuerpo principal si se necesita fade/occlusion.

## 11. Convenciones de nombres y carpetas

Raíz de arte:

```text
art/
  characters/
    player/
    aldren/
    npcs/
  environment/
    tilesets/
    props/
    buildings/
    vegetation/
    cemetery/
    fx/
  ui/
```

Nombres:

- archivos y carpetas: `snake_case`;
- IDs lógicos: `snake_case` estable;
- texturas: `<subject>_<variant>_<state>.png`;
- spritesheets: `<character>_<action>.png`;
- tilesets: `tileset_<zone>_<family>.png`;
- props: `prop_<name>_<variant>.png`;
- edificios: `building_<name>_<state>.png`.

Ejemplos:

```text
art/environment/tilesets/tileset_graveyard_ground.png
art/environment/vegetation/prop_oak_mature.png
art/environment/cemetery/prop_gravestone_worn_01.png
art/characters/aldren/aldren_walk.png
```

## 12. Importación y consistencia técnica

- Texturas de pixel art: filtering nearest.
- Evitar compresión que introduzca halos o mezcla de píxeles.
- Mantener coordenadas enteras para sprites estáticos cuando sea posible.
- No escalar sprites individualmente para corregir incoherencias de tamaño; corregir el asset fuente.
- Si un asset necesita una excepción de escala, documentarla en la escena o recurso que lo consume.
- Ningún asset puede copiar o redibujar sprites, tiles, mapas o paletas propietarias de Graveyard Keeper. La referencia sirve solo para nivel de legibilidad, ritmo visual y densidad general.

## 13. Checklist para producción independiente

Antes de aceptar un asset o mapa nuevo:

- [ ] Usa tile base de 32 px o un múltiplo documentado.
- [ ] Respeta resolución 1280x720 y zoom base 1.5x como referencia de lectura.
- [ ] Personajes usan pivot en pies y escala corporal compatible con 32x48 px.
- [ ] Colisión describe el footprint físico, no la silueta completa.
- [ ] Objetos altos usan Y-sort desde su base.
- [ ] El mapa respeta las seis capas conceptuales.
- [ ] Colores pertenecen a la familia de zona y mantienen legibilidad por valor.
- [ ] Luz principal llega desde arriba-izquierda y sombras caen abajo-derecha.
- [ ] Pixel art no contiene suavizado ni anti-aliasing pintado.
- [ ] Nombres y rutas siguen las convenciones de `art/`.
- [ ] El diseño es original y no reproduce assets protegidos.

## 14. Decisiones que este contrato NO toma

Quedan fuera de #17 y deben decidirse en sus tareas propietarias:

- contenido final de mapas;
- composición exacta de cementerio, bosque, pueblo, mina o interiores;
- gameplay, economía, quests o tecnología;
- nuevos Autoloads;
- UI final;
- cantidad final de frames de todas las acciones;
- shaders y partículas definitivos;
- audio.

Cualquier tarea posterior que necesite romper una métrica de este contrato debe justificar la excepción explícitamente en su PR en vez de introducir una escala alternativa de forma silenciosa.
