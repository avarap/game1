# MASTER SPEC — RPG de gestión, crafting y exploración en Godot 4
Especificación consolidada para un vertical slice original inspirado estructuralmente en Graveyard Keeper
Documento maestro de diseño y desarrollo. El juego debe ser original en mundo, personajes, narrativa, arte, nombres, mapas, mecánicas específicas y assets. La obra de referencia se utiliza únicamente como benchmark de estructura jugable, ritmo, perspectiva, gestión, crafting, progresión, exploración, calendario, relaciones con NPCs, sensación de mundo vivo, humor oscuro y estética pixel-art/isométrica.
Objetivo: construir un vertical slice muy pulido y completamente jugable que pueda evolucionar posteriormente hacia un producto comercial de mayor escala, sin intentar crear de inicio un juego enorme e incompleto.
# 1. Regla fundamental y prioridades
No intentes compensar problemas estructurales añadiendo más contenido. Cada sistema debe sentirse terminado antes de ampliar el alcance.
```text
Arquitectura
↓
Gameplay
↓
Estabilidad
↓
UX
↓
Progresión
↓
Contenido
↓
Arte
↓
Polish
```
La arquitectura debe permitir crecer sin reescribir los sistemas principales, pero no debe caer en sobreingeniería prematura. Diseña interfaces y datos extensibles, implementa solo lo necesario para el vertical slice y valida cada decisión mediante gameplay real.
# 2. Contrato de ejecución
Este documento define la arquitectura objetivo y el alcance máximo del vertical slice. No debe interpretarse como una orden para implementar simultáneamente todas las funcionalidades.
1. Empezar exclusivamente por la fase activa. No desarrollar fases posteriores salvo interfaces mínimas necesarias para evitar decisiones arquitectónicas incorrectas.
1. Cada fase debe producir una versión ejecutable y jugable.
1. El proyecto debe poder abrirse y ejecutarse después de cada cambio importante.
1. No generar código placeholder haciéndolo pasar por una funcionalidad terminada.
1. No marcar una funcionalidad como completada sin probarla.
1. Si una decisión arquitectónica dificulta las fases futuras, refactorizar antes de continuar.
1. No aumentar contenido para ocultar problemas de sistemas existentes.
1. Evitar archivos gigantes: preferiblemente menos de 300 líneas y excepcionalmente menos de 500.
1. Evitar managers omnipotentes.
1. Favorecer composición frente a herencia profunda.
1. Toda lógica que pueda existir sin Node debe ser testeable de forma aislada.
1. Las escenas se encargan principalmente de presentación, composición y lifecycle.
1. Los datos de gameplay no deben estar codificados en scripts cuando puedan representarse mediante Resources.
1. Antes de cada fase: analizar requisitos, dependencias y criterios de aceptación.
1. Después de cada fase: ejecutar tests, ejecutar el juego, revisar errores, UX, rendimiento y regresiones, documentar problemas y corregir los críticos antes de continuar.
# 3. Tecnología obligatoria
- Godot 4.x.
- GDScript.
- Renderizado 2D.
- TileMapLayer.
- CharacterBody2D.
- NavigationAgent2D.
- AnimationPlayer y/o AnimationTree.
- Resources personalizados y tipados.
- Signals.
- Autoloads limitados a responsabilidades realmente globales.
- Sistema de guardado local versionado.
No utilizar Python, Phaser o Three.js salvo justificación técnica excepcional y explícita. El runtime y los sistemas del juego deben ser nativos de Godot.
# 4. Objetivos de arquitectura
- Añadir objetos sin modificar código central.
- Añadir NPCs mediante datos.
- Añadir recetas mediante datos.
- Añadir misiones mediante datos.
- Añadir tecnologías mediante datos.
- Mantener sistemas desacoplados.
- Permitir testing modular.
- Guardar y cargar todo el estado relevante del mundo.
- Separar lógica, datos, presentación y persistencia.
- Evitar dependencias circulares.
## 4.1 Autoloads
Los Autoloads deben ser pocos y representar servicios globales verdaderos.

| Autoload | Responsabilidad |
| --- | --- |
| EventBus | Comunicación global desacoplada mediante señales. |
| GameManager | Lifecycle de partida, coordinación de escenas y estado global mínimo. |
| TimeManager | Reloj, calendario y eventos temporales. |
| SaveManager | Serialización, versionado, migraciones, autosave y carga. |
| AudioManager | Buses, música, ambiente y SFX. |

Inventory, Crafting, Cemetery, Quests, Economy y sistemas similares no deben convertirse automáticamente en Autoloads. Preferir servicios/componentes pertenecientes a la partida o a contextos concretos.
## 4.2 Componentes reutilizables
```text
components/
  health_component.gd
  energy_component.gd
  inventory_component.gd
  interaction_component.gd
  hitbox_component.gd
  hurtbox_component.gd
  resource_source_component.gd
  durability_component.gd
  relationship_component.gd
```
Ejemplo de composición de un árbol:
```text
Tree
├── Sprite2D
├── CollisionShape2D
├── InteractionArea
└── ResourceSourceComponent
```
La misma infraestructura debe poder reutilizarse en roca, mineral, hierba u otros nodos sin duplicar lógica.
# 5. Género, perspectiva y dirección artística
Género: RPG de gestión + crafting + exploración + simulación.
Perspectiva: vista cenital/isométrica 2D. El mapa debe transmitir profundidad mediante capas, sorting por Y, sombras, decoración, iluminación, oclusión y alturas visuales.
- Pixel art estilizado.
- Tonos cálidos y terrosos.
- Iluminación atmosférica.
- Ciclo día/noche.
- Partículas discretas.
- Vegetación animada.
- Sombras suaves.
- Interiores acogedores.
- Cementerio lúgubre pero visualmente atractivo.
- Contraste entre humor y temática macabra.
Todos los assets deben compartir escala, paleta, iluminación y densidad visual coherentes.
# 6. Premisa y tono narrativo
El jugador hereda un antiguo cementerio y una propiedad abandonada en las afueras de un pequeño pueblo medieval. Debe restaurar el cementerio, gestionar entierros, obtener recursos, fabricar herramientas, construir instalaciones, mejorar su propiedad, conocer habitantes, cumplir encargos y descubrir secretos sobre el pueblo.
- Misterio.
- Humor negro.
- Personajes excéntricos.
- Situaciones absurdas.
- Dilemas morales ligeros.
# 7. Gameplay loop
```text
Explorar
↓
Recolectar recursos
↓
Procesar materiales
↓
Fabricar objetos
↓
Completar encargos
↓
Mejorar instalaciones
↓
Desbloquear tecnologías
↓
Acceder a nuevas zonas
↓
Conocer NPCs
↓
Descubrir nuevas historias
```
El jugador debe recibir feedback frecuente de progreso: cambios visibles en el mundo, sonidos, animaciones, desbloqueos, rating, recursos, quests, relaciones y nuevas posibilidades.
# 8. Estructura del proyecto
```text
res://
  autoload/
    game_manager.gd
    event_bus.gd
    save_manager.gd
    time_manager.gd
    audio_manager.gd
  core/
    state/
    utils/
    persistence/
    components/
  player/
    player.tscn
    player.gd
    player_controller.gd
    player_stats.gd
  world/
    world.tscn
    maps/
    interactables/
    resources/
    buildings/
  npcs/
    npc_base.tscn
    npc_base.gd
    schedules/
    dialogue/
  systems/
    inventory/
    crafting/
    quests/
    economy/
    reputation/
    cemetery/
    technology/
    farming/
    combat/
  items/
    resources/
    definitions/
  ui/
    hud/
    inventory/
    crafting/
    quests/
    technologies/
    dialogue/
    debug/
  data/
    items/
    recipes/
    quests/
    npcs/
    technologies/
    dialogues/
    schedules/
  audio/
  art/
  shaders/
  tests/
```
# 9. Arquitectura basada en datos
Preferir Resources tipados para datos internos de gameplay. JSON se reserva principalmente para guardados, configuraciones externas o contenido que resulte más natural de editar fuera de Godot. CSV es adecuado para localización o importación masiva.

| Tipo de información | Formato preferido |
| --- | --- |
| Items | .tres / Resource tipado |
| Recetas | Resource tipado |
| Tecnologías | Resource tipado |
| NPCs | Resource tipado |
| Quests | Resource tipado |
| Diálogos | Resource tipado o JSON |
| Schedules | Resource tipado |
| Configuración | Resource tipado |
| Saves | JSON o binario versionado |
| Localización | CSV |
| Datos masivos | CSV importado/convertido a Resource |

```text
class_name ItemData
extends Resource

@export var id: StringName
@export var display_name: String
@export var description: String
@export var max_stack: int = 99
@export var value: int = 0
@export var icon: Texture2D
```
# 10. Event Bus y comunicación
```text
signal item_added(item_id, amount)
signal quest_completed(quest_id)
signal day_changed(day)
signal cemetery_rating_changed(value)
```
Usar señales cuando desacoplen sistemas de forma real. No convertir EventBus en un vertedero de eventos. Para relaciones locales o jerárquicas, preferir señales directas entre nodos/componentes.
# 11. Jugador
El jugador utiliza CharacterBody2D.
- Movimiento en 8 direcciones.
- Aceleración y desaceleración.
- Interacción.
- Herramientas.
- Idle.
- Caminar.
- Correr.
- Usar herramientas.
- Recibir daño.
- Movimiento independiente del framerate.
# 12. Cámara
- Camera2D.
- Seguimiento suave.
- Límites del mapa.
- Interpolación.
- Zoom configurable.
- Pequeños efectos de cámara.
- Shake moderado para acciones de impacto.
# 13. Sistema genérico de interacción
```text
class_name Interactable
extends Area2D

func interact(player):
    pass
```
La misma interfaz debe funcionar para puertas, NPCs, estaciones, cofres, cadáveres, tumbas, objetos, interruptores y otros elementos interactivos.
# 14. Mundo
Zonas objetivo del vertical slice:
- Casa.
- Cementerio.
- Taller.
- Bosque.
- Pueblo.
- Granja abandonada.
- Mina.
- Iglesia.
- Taberna.
- Río.
- Zona misteriosa bloqueada.
No diseñar mapas enormes. Priorizar densidad, utilidad y legibilidad. Cada zona debe tener recursos, NPCs o interacciones, secretos, rutas alternativas y elementos visuales propios.
## 14.1 Tilemaps y capas
```text
Ground
Terrain
Decoration
Collision
Foreground
Navigation
```
No mezclar la lógica del mundo directamente con TileMapLayer.
## 14.2 Sorting
Implementar Y-sorting correcto. Árboles, NPCs, edificios y objetos deben ocultar al jugador de forma coherente cuando pase detrás.
## 14.3 Iluminación
- CanvasModulate.
- PointLight2D.
- LightOccluder2D.
- Shaders 2D cuando aporten valor.
El ciclo día/noche debe modificar gradualmente color, intensidad, luces interiores, farolas y ambiente. Referencias horarias: 06:00 amanecer, 12:00 mediodía, 18:00 atardecer, 22:00 noche.
# 15. Cementerio
El cementerio es un sistema central.
- Limpiar.
- Retirar escombros.
- Colocar tumbas.
- Fabricar lápidas.
- Fabricar cercas.
- Enterrar cadáveres.
- Mejorar tumbas.
- Decorar.
Ejemplo de puntuación base:

| Elemento | Puntos |
| --- | --- |
| Cadáver | +2 |
| Lápida | +3 |
| Valla | +2 |
| Decoración | +1 |

El rating global desbloquea recompensas, edificios, eventos y misiones. La fórmula debe estar encapsulada y ser configurable mediante datos, no dispersa por escenas.
# 16. Cadáveres
```text
class_name CorpseData
extends Resource

@export var quality: int
@export var decay: float
@export var preparation_level: int
@export var burial_value: int
```
Debe existir descomposición progresiva. Acciones disponibles: preparar, enterrar, cremar, investigar y rechazar.
# 17. Recursos
## 17.1 Básicos
Madera · Piedra · Hierro · Carbón · Hierbas · Arcilla · Agua · Comida
## 17.2 Procesados
Tablas · Vigas · Bloques · Clavos · Lingotes · Cristal · Cuerda · Papel
## 17.3 Resource Nodes
```text
ResourceNode
├── Tree
├── Rock
├── Ore
└── Herb
```
Cada nodo define vida, herramienta requerida, loot y respawn mediante datos/componentes reutilizables.
# 18. Inventario
El inventario debe ser independiente de su representación visual.
- Stacks.
- Split.
- Transferencias.
- Añadir.
- Eliminar.
- Comprobar cantidades.
- Categorías.
```text
InventoryModel
      ↓
InventoryService
      ↓
signals
      ↓
InventoryUI
```
La UI representa el estado, no lo posee. El mismo modelo debe servir para jugador, cofres, comerciantes, estaciones, loot y otros contenedores.
# 19. Crafting
Estaciones:
Banco · Sierra · Horno · Yunque · Mesa de alquimia · Prensa · Mesa de escritura · Cocina
Cada receta debe ser data-driven.
```text
RecipeData
  id
  station
  inputs
  outputs
  duration
  requirements
```
Las estaciones deben soportar producción instantánea, temporizada y colas. La arquitectura debe permitir automatización futura sin implementar una fábrica compleja en el slice inicial.
# 20. StorageNetwork
Las estaciones pueden consultar materiales disponibles en inventarios compatibles sin obligar al jugador a moverlos manualmente.
```text
StorageProvider
      ↑
PlayerInventory
ChestInventory
StationInventory

        ↓

StorageNetwork

has_item()
get_available_amount()
consume()
deposit()
find_sources()
```
Crafting conoce la interfaz de StorageNetwork, no la implementación concreta de los cofres. El alcance espacial del almacenamiento puede configurarse por zona o distancia.
# 21. Tecnología
Categorías:
Construcción · Agricultura · Metalurgia · Teología · Naturaleza · Alquimia · Investigación
Puntos de progreso:
Rojo · Verde · Azul
Las tecnologías desbloquean recetas, herramientas, estaciones, edificios y mejoras.
# 22. Herramientas
Hacha · Pico · Martillo · Pala · Espada · Hoz
Datos: durabilidad, daño, velocidad, nivel y eficiencia.
```text
Básica
↓
Hierro
↓
Acero
↓
Avanzada
```
# 23. Energía
Cada acción consume energía. Valores iniciales orientativos:

| Acción | Coste |
| --- | --- |
| Cortar árbol | -4 |
| Romper piedra | -5 |
| Cavar | -3 |
| Crafting | -2 |

Recuperación mediante comida, descanso y sueño. El balance debe validarse mediante gameplay y no fijarse rígidamente por esta tabla.
# 24. Tiempo y calendario
TimeManager controla minuto, hora, día, semana y una estación futura.
Semana ficticia:
Día del Sol · Día de la Luna · Día del Hierro · Día del Bosque · Día del Espíritu · Día del Comercio
Eventos y rutinas de NPCs pueden depender de día y hora.
# 25. NPCs
Objetivo final del vertical slice: 8-10 NPCs originales. Para validar la arquitectura, comenzar con 4 NPCs completamente funcionales y ampliar solo cuando sus sistemas estén estables.

| NPC inicial | Rol |
| --- | --- |
| Hermano Aldren | Sacerdote excéntrico |
| Mara Vell | Tabernera |
| Oren Brask | Herrero |
| Silas Crow | Enterrador/mensajero de cadáveres |

Roles adicionales posibles: mercader, bruja, carpintero, granjero, investigador, guardia y personaje misterioso.
## 25.1 Datos de NPC
```text
NPCData
ScheduleData
DialogueData
QuestData
RelationshipData
```
La lógica del NPC no debe contener directamente todos sus diálogos, horarios ni misiones.
## 25.2 Rutinas
Utilizar NavigationAgent2D. Los NPCs deben caminar, trabajar, dormir, visitar lugares y cambiar comportamiento según hora y día.
## 25.3 Máquina de estados
Idle · Walking · Working · Talking · Sleeping · SpecialEvent
Evitar bloques gigantes if/else. Los estados deben ser explícitos, pequeños y testeables cuando sea posible.
# 26. Relaciones
Rango 0-100. Las relaciones pueden desbloquear diálogos, objetos, recetas, misiones y secretos. Las condiciones deben estar definidas por datos.
# 27. Diálogos
Sistema desacoplado con soporte para:
- Texto.
- Opciones.
- Condiciones.
- Variables.
- Reputación.
- Triggers de quests.
# 28. Misiones
Cada misión debe contener id, NPC, objetivos, requisitos, recompensas, estado y dependencias.
Tipos iniciales:
Recolectar · Fabricar · Entregar · Explorar · Investigar · Hablar
# 29. Economía
Monedas:
```text
100 cobre = 1 plata
100 plata = 1 oro
```
- Compra.
- Venta.
- Precios.
- Inventarios de comerciantes.
- Arquitectura preparada para fluctuaciones futuras.
# 30. Construcción
Modo construcción para colocar:
Cofres · Bancos · Hornos · Tumbas · Decoraciones · Jardines
Validar colisiones, espacio, recursos y terreno.
# 31. Combate
Sistema secundario, no dominante. Utilizar hitboxes, hurtboxes, estados y cooldowns.
Ataque · Esquiva · Daño · Enemigos · Loot · Muerte
# 32. Exploración
Añadir gradualmente:
Cuevas · Ruinas · Catacumbas · Bosques · Pasajes
Algunas áreas deben requerir herramientas, tecnologías, quests o reputación.
# 33. UI/UX
Utilizar Control y contenedores adaptables a varias resoluciones.
## 33.1 HUD
Vida · Energía · Hora · Día · Dinero · Herramienta · Objeto seleccionado
## 33.2 Menús
Inventario · Crafting · Tecnologías · Misiones · Mapa · Relaciones
La UI no debe contener lógica de negocio. Debe observar modelos/servicios y emitir intents o comandos.
# 34. Input
Utilizar InputMap. Nunca hardcodear teclas directamente.
```text
move_up
move_down
move_left
move_right
interact
primary_action
secondary_action
inventory
map
pause
```
# 35. Audio
AudioManager con buses:
Master · Music · Ambient · SFX · UI
Añadir audio ambiental por zona y momento del día. El sistema debe permitir transiciones suaves entre ambientes.
# 36. Persistencia
El guardado debe ser versionado y preparado para migraciones.
```text
{
  "save_version": 1,
  "player": {},
  "world": {},
  "quests": {}
}
```
Guardar: posición del jugador, stats, inventario, hora, día, quests, relaciones, tecnologías, dinero, cementerio, edificios, recursos, cofres, NPCs y estado del mundo.
## 36.1 Autosave
- Cada 5 minutos.
- Al dormir.
- Al cambiar de zona.
- Antes de salir.
Las migraciones deben estar centralizadas en SaveManager o en una capa de persistence dedicada.
# 37. Rendimiento
Objetivo: 60 FPS en hardware objetivo.
- Evitar crear/destruir nodos constantemente.
- Object pooling cuando aporte beneficio real.
- Caching.
- Visibility ranges.
- Batching.
- Atlas textures.
- Lazy loading.
- No optimizar prematuramente sin medición.
# 38. Testing
Priorizar tests de lógica pura para:
Inventario · Crafting · Economía · Quests · Save/Load · Tiempo · Cementerio
Separar lógica pura de escenas siempre que sea posible. Añadir tests de integración para los flujos que dependen de escenas o señales.
# 39. Panel de debugging
Obligatorio para acelerar QA.
```text
Cambiar hora
Cambiar día
Añadir dinero
Añadir objetos
Teletransportarse
Completar quest
Cambiar reputación
Mostrar FPS
Mostrar colisiones
```
Debe existir una forma clara de habilitar/deshabilitar el panel para builds de desarrollo.
# 40. Agentes / división de responsabilidades
Si el entorno soporta subagentes, dividir responsabilidades de forma aproximada:

| Agente | Responsabilidad |
| --- | --- |
| 1 — Game Director | Gameplay, alcance y progresión. |
| 2 — Godot Architect | Arquitectura, escenas, Resources, señales y Autoloads. |
| 3 — Gameplay Engineer | Jugador, controles, herramientas e interacción. |
| 4 — Simulation Engineer | Tiempo, calendario, NPCs y rutinas. |
| 5 — Economy & Crafting | Inventario, crafting, economía y tecnología. |
| 6 — World Designer | Mapas, navegación, zonas y construcción. |
| 7 — Narrative Designer | NPCs, diálogos, misiones e historia. |
| 8 — UI/UX | HUD y menús. |
| 9 — Art Director | Revisión visual independiente. |
| 10 — QA | Bugs, regresiones, rendimiento y softlocks. |

QA no debe implementar directamente las funcionalidades que evalúa. Art Direction debe revisar el juego ejecutado mediante screenshots o gameplay y no basarse únicamente en el código.
# 41. Vertical slice obligatorio
Antes de ampliar contenido, debe poder completarse de principio a fin el siguiente recorrido:
```text
Despertar
↓
Salir de casa
↓
Recoger recursos
↓
Recibir cadáver
↓
Prepararlo
↓
Construir tumba
↓
Enterrarlo
↓
Mejorar cementerio
↓
Hablar con NPC
↓
Recibir misión
↓
Fabricar objeto
↓
Completar misión
↓
Obtener puntos
↓
Desbloquear tecnología
↓
Dormir
↓
Guardar
↓
Cerrar
↓
Cargar partida
↓
Todo el estado permanece
```
Una versión aún más concreta para el primer loop jugable:
```text
Casa
↓
Cementerio
↓
Bosque pequeño
↓
Recolectar madera/piedra
↓
Fabricar tablas + clavos
↓
Reparar mesa de trabajo
↓
Llega un cadáver
↓
Prepararlo
↓
Crear lápida
↓
Crear valla
↓
Enterrar cadáver
↓
Rating del cementerio aumenta
↓
Hermano Aldren aparece
↓
Quest
↓
Fabricar objeto
↓
Completar quest
↓
Recibir puntos tecnológicos
↓
Desbloquear tecnología
↓
Dormir
↓
Autosave
↓
Cerrar y cargar
↓
Estado restaurado
```
# 42. Alcance máximo inicial
```text
1 pueblo
1 cementerio
1 bosque
1 mina
1 casa
1 taller
3 interiores adicionales
8-10 NPCs
30-40 objetos
15-20 recetas
10-15 tecnologías
10 quests
```
No ampliar más allá de este alcance hasta que todos los sistemas estén sólidos. Durante las primeras iteraciones, usar alrededor de 15 objetos y 4 NPCs funcionales para validar el loop y la arquitectura antes de escalar contenido.
# 43. Fases de desarrollo
## Fase 0 — Bootstrap
project.godot · carpetas · Autoloads · InputMap · logging · debug · tests · CI
## Fase 1 — Core / Walking Prototype
arquitectura · EventBus · GameManager · mapa · jugador · movimiento · cámara · colisiones · interacciones
## Fase 2 — Items / Resource Loop
ItemData · inventario · recursos · herramientas · loot · energía · UI inventario
## Fase 3 — Crafting / Production Loop
```text
RecipeData · estaciones · crafting · cofres · StorageNetwork
```
## Fase 4 — Cementerio / Graveyard Loop
cadáveres · tumbas · preparación · entierro · rating · mejoras
## Fase 5 — Simulación
tiempo · día/noche · calendario · NPCs · rutinas · navegación
## Fase 6 — RPG
diálogo · relaciones · quests · economía · tecnologías
## Fase 7 — Mundo
pueblo · bosque · mina · interiores · exploración · secretos
## Fase 8 — Polish
arte · animaciones · shaders · partículas · audio · feedback · UI final · optimización
# 44. Criterios de aceptación por fase
## 44.1 Fase 0 — Bootstrap
- Godot abre el proyecto sin errores.
- La escena raíz puede ejecutarse.
- La estructura de carpetas existe y es coherente.
- Autoloads mínimos registrados.
- InputMap configurado.
- Logging y panel debug mínimo disponibles.
- Existe infraestructura de tests.
## 44.2 Fase 1 — Core
- Godot abre el proyecto sin errores.
- La escena principal arranca.
- El jugador aparece correctamente.
- WASD / InputMap permite movimiento 8-direccional.
- Movimiento independiente del FPS.
- Colisiones funcionan.
- La cámara sigue suavemente.
- Y-sort funciona.
- Existe al menos un Interactable funcional.
- Cambiar InputMap no requiere modificar scripts.
- EventBus transmite eventos correctamente.
- No existen errores relevantes en debugger.
- FPS >= 60 en hardware objetivo.
- Existe al menos un test de la lógica creada.
## 44.3 Fase 2 — Items
- Se pueden recoger recursos.
- Los stacks funcionan.
- Añadir/eliminar/comprobar cantidades funciona.
- La UI refleja cambios sin poseer la lógica.
- Las herramientas consumen energía y afectan recursos.
- Loot y durabilidad no provocan estados inválidos.
- Tests críticos del inventario pasan.
## 44.4 Fase 3 — Crafting
- Las recetas se cargan desde datos.
- Una estación puede fabricar una receta válida.
- Los materiales se consumen exactamente una vez.
- Las recetas inválidas no consumen materiales.
- StorageNetwork encuentra y consume recursos autorizados.
- Crafting instantáneo y temporizado funcionan.
- Las colas no se corrompen tras guardar/cargar.
## 44.5 Fase 4 — Cementerio
- Se puede preparar y enterrar un cadáver.
- Se puede construir una tumba válida.
- La puntuación individual y global es reproducible.
- El rating reacciona correctamente a mejoras.
- La descomposición progresa con el tiempo.
- El estado sobrevive save/load.
## 44.6 Fase 5 — Simulación
- El reloj progresa de forma estable.
- Día/noche cambia gradualmente.
- Los NPCs siguen rutinas horarias.
- NavigationAgent2D no bloquea el gameplay.
- Dormir avanza el tiempo correctamente.
- El estado temporal y de NPCs sobrevive save/load.
## 44.7 Fase 6 — RPG
- Diálogos, condiciones y opciones funcionan desde datos.
- Relaciones cambian y desbloquean contenido.
- Las quests pueden iniciarse, progresar y completarse.
- Las recompensas se conceden una sola vez.
- La economía compra/vende correctamente.
- Las tecnologías consumen puntos y desbloquean contenido.
## 44.8 Fases 7-8 — Mundo y Polish
- Todas las zonas necesarias son navegables sin softlocks.
- Los bloqueos de progreso comunican claramente sus requisitos.
- La dirección visual es coherente.
- Audio, partículas y feedback refuerzan acciones sin saturar.
- El vertical slice completo puede terminarse de principio a fin.
- No hay regresiones críticas ni categorías de evaluación por debajo del mínimo.
# 45. QA loop
```text
Implementar
↓
Ejecutar
↓
Jugar
↓
Probar edge cases
↓
Capturar screenshots
↓
Medir rendimiento
↓
Revisar visualmente
↓
Crear lista de problemas
↓
Corregir
↓
Ejecutar tests
↓
Volver a jugar
```
Después de cada fase se debe ejecutar el loop completo. No confiar únicamente en que el código compile o en tests unitarios.
# 46. Definition of Done
Una funcionalidad NO está terminada simplemente porque compile.
- Funciona dentro del gameplay.
- Tiene estados de error controlados.
- No produce warnings significativos.
- Puede persistirse si afecta al mundo.
- Se integra con UI cuando corresponda.
- Emite señales apropiadas.
- No introduce dependencias circulares.
- Tiene tests cuando contiene lógica crítica.
- Puede verificarse mediante el panel debug.
- Sobrevive save/load cuando corresponda.
- Ha sido probada jugando.
- No degrada de forma significativa el rendimiento.
# 47. Evaluación de cada versión

| Categoría | Objetivo mínimo |
| --- | --- |
| Gameplay | 8/10 |
| Controles | 8/10 |
| Progresión | 8/10 |
| Crafting | 8/10 |
| Simulación | 8/10 |
| NPCs | 8/10 |
| Misiones | 8/10 |
| UI | 8/10 |
| Dirección artística | 8/10 |
| Audio | 8/10 |
| Rendimiento | 8/10 |
| Estabilidad | 8/10 |
| Arquitectura | 8/10 |

Ninguna categoría debe estar por debajo de 8/10 antes de considerar el vertical slice listo para expandirse.
# 48. Arquitectura conceptual
```text
                    ┌──────────────┐
                    │   GameData   │
                    │  Resources   │
                    └──────┬───────┘
                           │
                           ▼
Player ───────┐       Gameplay Services
NPC ──────────┤
World ────────┤       Inventory
Stations ─────┼─────► Crafting
Cemetery ─────┤       Economy
Quests ───────┤       Technology
              │       Quests
              │
              ▼
          EventBus
              │
       ┌──────┼──────┐
       ▼      ▼      ▼
      UI     Audio   FX
              │
        Persistence
              │
              ▼
           SaveData
```
GameManager coordina lifecycle y contexto. No debe contener toda la lógica del juego.
# 49. Entrega
El proyecto final debe poder abrirse directamente con Godot 4 e incluir:
```text
project.godot
README.md
GAME_DESIGN.md
ARCHITECTURE.md
ROADMAP.md
CHANGELOG.md
res://
```
El README debe explicar versión de Godot, controles, arquitectura, escenas principales, Autoloads, formato de datos, sistema de guardado, ejecución, estructura de carpetas y debugging.
# 50. Resultado esperado
El objetivo no es construir inmediatamente un clon enorme de Graveyard Keeper. El objetivo es crear un RPG de gestión original, modular y comercialmente viable, con un vertical slice de alta calidad que pueda evolucionar posteriormente hacia decenas de horas de contenido.
El éxito se mide por un loop central divertido, sistemas sólidos, arquitectura mantenible, guardado fiable, buena UX y una ejecución coherente. Solo después se aumenta contenido, mundo y complejidad.