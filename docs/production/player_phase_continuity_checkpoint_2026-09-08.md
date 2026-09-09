# PLAYER — continuidad del paso (actualizado 2026-09-09)

Estado: corrección funcional de giros verificada localmente; aceptación visual de PLAYER pendiente.
Rama canónica: `character/player-controller-polish-20260902`, [PR #141](https://github.com/avarap/game1/pull/141).
Base de esta entrega: `8577b4c8dea01bc73c7e05480dc9dc7afd38f0d8`.

## Cambio y alcance

`PlayerVisual` conserva el frame y su progreso fraccional al girar dentro de walk o run.
Cambiar de acción reinicia su animación, como antes. Se conservan los ciclos authored
distintos (walk: seis frames a 10 FPS; run: seis a 12 FPS), las ocho direcciones,
idle e interact. No se modifican atlas, escala, pivote, sombra, colisiones,
velocidades, NPC ni archivos del mapa.

La causa era `play(target)`: seleccionar la vista de otra dirección reiniciaba
el paso. La prueba de regresión cubre 48 giros (dos acciones, tres fases, ocho
direcciones) y ocho cambios de acción. Al retirar temporalmente la corrección,
las 48 comprobaciones fallan; restaurándola, pasan.

## Prueba real y evidencia reproducible

`tests/test_player_phase_runtime.gd` carga `res://main.tscn`, sin teletransportar
al jugador ni posar su sprite. Inyecta movimiento a través de Input y observa
física antes/después del controlador real. Comprueba 16 giros, dos inicios de
acción, desplazamiento, contacto con obstáculos y parada en `idle_e`.
La interacción usa `Input.parse_input_event`, no una llamada directa al handler.

Verificado localmente con Godot `4.7.2.stable.official.ed1daf0bf`:

- Import, smoke y 62 suites core: exit 0.
- Lint y formato: 181 GDScript; sin incidencias de estas herramientas.
- Runtime headless a tiempo real y fixed-fps 30: 16 giros, dos inicios de acción,
  1496,28 px recorridos, 27 ticks con colisión, velocidad máxima 319 px/s y
  reposo final sin fallos. Estas cifras describen el recorrido, no rendimiento.
- Control negativo: sin la corrección fallan los 16 giros reales.
- Persisten los avisos previos de cierre: 55 instancias ObjectDB y 19 recursos
  en core; cuatro instancias en smoke/runtime. No se declaran resueltos.

CI ejecuta esa prueba y fija todos los checkouts al HEAD de la PR. El artefacto
`player-motion-video` contiene MP4 1280×720, log, metadatos del commit ejecutado
y verificación de decodificación/duración. El grabador exige que FFmpeg sobreviva
hasta terminar el juego y cierre correctamente; un archivo no vacío no basta.
La captura usa tiempo real, porque `--fixed-fps` desactiva la sincronización
temporal. Los PNG existentes se conservan en `cemetery-visual-captures`.
La CI de esta entrega valida el HEAD, no una futura combinación con main;
antes de cualquier fusión deberá ejecutarse también el core del resultado integrado.

## Límites y coordinación

- El cofre recibe exactamente una interacción, cambia su texto y activa
  `interact_s`, pero `feedback_visible=false` en esta rama: el mapa oculta
  `FeedbackLabel`. La prueba informa de ello sin presentarlo como efecto visible
  aceptado. La corrección ya existe en la prueba conjunta #147; no se copia aquí
  código de otro dominio. Supervisión debe verificarla al combinar los HEAD.
- Se inspeccionó el atlas actual: PLAYER tiene alturas opacas de 42–48 px;
  Aldren, 77–78 px. El contrato pide 44–48 px, variación adulta ±4 px y pies en
  y=0. No se agranda PLAYER para compensar al NPC. El trabajo NPC tiene su
  superficie propia en #148; su existencia no demuestra aceptación.
- Esta evidencia usa el mapa real contenido en #141, no combina automáticamente
  el último #142 ni el candidato NPC. Escala conjunta, contraste con el terreno,
  fluidez visual y resultado visible de interacción siguen siendo gates separados.
- #138 permanece cerrada; #147 nunca se fusiona con main.

Siguiente paso: inspeccionar el vídeo del commit publicado y repetir el recorrido
con los HEAD actuales de MAP y del candidato Aldren en la prueba conjunta, para
medir lectura/escala sin alterar las poses del jugador ni ocultar el problema
del feedback. Si el contraste sigue insuficiente, delimitar una limpieza intencional
de silueta/valores del protagonista, no un simple recolor o upscale.
