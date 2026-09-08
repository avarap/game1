# LOCALIZATION

Política de localización del vertical slice.

## Idiomas iniciales

- Inglés: `en`.
- Español: `es`.
- Fallback: inglés (`en`).

El master spec ya exige localización y diálogos data-driven. Esta decisión concreta los idiomas del vertical slice y la implementación nativa de Godot sin alterar la arquitectura general.

## Implementación

- `TranslationServer` es la autoridad runtime de idioma.
- `LocalizationService` valida los locales soportados y encapsula el cambio de idioma/traducción por clave.
- Las traducciones viven en `localization/en.po` y `localization/es.po`.
- `project.godot` registra ambos catálogos.
- El selector técnico actual permite cambiar ES/EN en runtime; una pantalla de ajustes final pertenece al trabajo posterior de UI/polish.

## Regla de datos

Los datos de gameplay nunca deben depender de texto traducido.

Correcto:

```text
npc_id = brother_aldren
text_key = DIALOGUE_ALDREN_INTRO
quest_id = aldren_restore_grave
```

Incorrecto:

```text
npc_id = Hermano Aldren
condition = "Repara la tumba"
```

IDs, condiciones, progreso, saves y relaciones permanecen invariantes al cambiar de idioma. `DialogueData`, `DialogueNodeData` y `DialogueOptionData` almacenan claves; la UI traduce únicamente al presentar.

## Ampliación futura

Añadir un idioma nuevo debe requerir principalmente un nuevo catálogo de traducción y su registro, no duplicar árboles de diálogo ni lógica. Los tests deben comprobar que cambiar de idioma no modifica el estado del grafo de diálogo.
