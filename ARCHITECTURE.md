# ARCHITECTURE

## Principios

- Godot 4.x + GDScript + renderizado 2D.
- Composición frente a herencia profunda.
- Datos de gameplay mediante Resources tipados cuando corresponda.
- Señales para desacoplamiento real.
- UI como representación del estado, nunca propietaria de la lógica.
- Persistencia versionada.
- Autoloads solo para responsabilidades globales reales.

## Autoloads

| Servicio | Responsabilidad |
| --- | --- |
| EventBus | Eventos globales desacoplados |
| GameManager | Lifecycle y coordinación mínima |
| TimeManager | Reloj y calendario |
| SaveManager | Persistencia, versión y futuras migraciones |
| AudioManager | Buses y audio global |

## Bootstrap actual

`main.tscn` es la escena raíz. El panel debug permite validar tiempo, FPS y una operación mínima de guardado. `TimeMath` contiene lógica pura y sirve como primera pieza testeable fuera de Node.

## Regla de evolución

Antes de añadir un sistema nuevo, verificar que la fase activa cumple sus criterios de aceptación y que el proyecto sigue arrancando en modo normal y headless.
