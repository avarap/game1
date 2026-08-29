# CHANGELOG

## Unreleased

### Added
- Inicialización del proyecto Godot 4.x.
- Escena raíz ejecutable.
- Autoloads globales mínimos.
- InputMap base.
- Logging mínimo.
- Panel debug de bootstrap.
- Utilidad pura `TimeMath` y test headless.
- GitHub Actions para validación y tests.
- Documentación base y memoria de desarrollo.
- `world/world.tscn` como composición base del walking prototype.
- `player/player.tscn` con `CharacterBody2D`, colisión, `InteractionArea` y `Camera2D`.
- Movimiento 8-direccional con aceleración/desaceleración mediante `PlayerMovement`.
- Límites de mapa, obstáculo de prueba y Y-sort.
- Componente base `Interactable` y `DebugSign` funcional.
- Tests de movimiento del jugador.
- Test de aceptación `test_walking_prototype.gd` para validar escenas y componentes críticos de Fase 1.

### Validated
- Fase 0 validada mediante `Godot CI` run `33278173612`.
- Fase 1 validada mediante `Godot CI` run `33280758441` sobre `ae77e23a190c4cb7824eff0bce8c6cf672fb381f`.
- Importación Godot, smoke test de `main.tscn` y suite headless completan con éxito.
