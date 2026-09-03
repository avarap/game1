# Plantilla de fase

Copiar esta estructura al abrir una fase nueva en `ROADMAP.md`, y usarla como
checklist antes de marcar la fase como completada. El objetivo es que
`ROADMAP.md`, `DEV_MEMORY.md` y `CHANGELOG.md` queden siempre sincronizados
con el código real — la deriva entre documentación y código ha sido, hasta
ahora, la inconsistencia más frecuente detectada en las auditorías de este
repositorio (más que los propios bugs de lógica).

---

## Fase N — <Nombre> — <ACTIVA | COMPLETADA>

### Criterios de aceptación (derivados del master spec)

Copiar aquí las secciones relevantes del master spec como checkboxes
verificables, no como descripciones vagas. Cada checkbox debe poder
responderse con sí/no mirando el código, no la intención.

- [ ] <criterio 1>
- [ ] <criterio 2>
- [ ] Persistencia compatible con el guardado versionado, si aplica.
- [ ] Test de aceptación lógico del flujo mínimo de la fase.
- [ ] `gdscript-quality` (lint + format) en verde sobre los archivos tocados.
- [ ] CI final (`validate-and-test`) en verde antes de cerrar la fase.

### Bloques de trabajo

Un bloque = un incremento coherente y pequeño (según la "Regla de
continuidad" de `DEV_MEMORY.md`). Por cada bloque, registrar:

```
#### Bloque N — <título>
- Qué se implementó (2-5 líneas, sin narrar el proceso paso a paso).
- Decisiones de diseño relevantes, si las hay.
- Commit funcional: `<hash completo>`
- Validación: `Godot CI` run `<run_id>`, `<success|failure>`
- Si hubo un fallo detectado y corregido: qué detectó el run de
  diagnóstico, y en qué commit se corrigió. No omitir el fallo del
  historial — el valor de `DEV_MEMORY.md` está en ser preciso, no en
  parecer perfecto.
```

### Antes de marcar la fase como COMPLETADA

- [ ] Todos los checkboxes de "Criterios de aceptación" están en `[x]`.
- [ ] El commit citado como "último bloque funcional" en `DEV_MEMORY.md`
      coincide con el HEAD real de `main` (`git log -1 --format=%H`).
- [ ] `ROADMAP.md`, `DEV_MEMORY.md` y `CHANGELOG.md` fueron actualizados en
      el mismo bloque de commits que cierra la fase, no en un commit
      posterior "para más tarde".
- [ ] El run de CI citado corresponde al HEAD real, no a un commit
      intermedio de la fase.
- [ ] Si se añadieron o modificaron archivos `.gd`, confirmar que están
      cubiertos por el gate de `gdlint`/`gdformat` (revisar el glob/lista
      de rutas en `.github/workflows/ci.yml`, no asumir cobertura).

### Al abrir la siguiente fase

- [ ] Releer las secciones correspondientes del master spec antes de
      implementar (no antes de documentar).
- [ ] Escribir "Próximo bloque — Fase N+1" en `DEV_MEMORY.md` con pasos
      concretos, no solo el nombre de la fase.
- [ ] Actualizar el resumen de "Estado" en `README.md`.
