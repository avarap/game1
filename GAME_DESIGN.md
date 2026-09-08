# GAME DESIGN

## Concepto
RPG 2D de gestión, crafting, exploración y simulación con ambientación medieval original, humor oscuro y un cementerio como sistema central.

## Loop objetivo
Explorar → recolectar/cultivar → procesar → fabricar/cocinar → gestionar cadáveres → completar encargos → mejorar instalaciones → desbloquear tecnologías → acceder a nuevas zonas → conocer NPCs → descubrir historias.

## Vertical slice
El recorrido completo debe permitir despertar, recolectar recursos, cultivar un recurso útil, recibir un cadáver mediante el servicio funerario, decidir cómo gestionarlo, mejorar el cementerio, comerciar/cocinar, hablar con NPCs, completar misiones, desbloquear tecnologías, dormir, guardar y cargar preservando el estado.

## Núcleo del cementerio
Los cadáveres son decisiones de gestión, no simples puntos de rating. Cada cuerpo acumula edad en minutos enteros y descomposición como porcentaje entero `0..100`. El deterioro empieza lento y se acelera a partir de 24, 48 y 72 horas. El jugador ve estados Fresh/Fading/Decomposed/Rotten y la calidad efectiva cae al cruzar umbrales.

Preparar no rejuvenece. Tecnologías, utensilios e instalaciones reducirán la velocidad de deterioro. Investigar cambiará tiempo/calidad potencial por conocimiento; cremar dará una salida con recompensas distintas del entierro.

## Servicio funerario
Un transporte funerario original llegará al atardecer, objetivo inicial **18:00**. Durante la introducción podrá funcionar gratis; tras su quest requerirá un alimento cultivable depositado en un comedero. Las entregas serán deterministas e idempotentes al dormir, saltar tiempo y guardar/cargar.

Al principio los cuerpos se descargarán junto al camino. Más adelante una quest + tecnología/construcción desbloqueará una rampa que dirigirá nuevas entregas al área de recepción. La rampa automatiza logística, no conservación.

## Agricultura y recurso multiuso
La agricultura entra porque alimenta otros sistemas. El primer cultivo funcional será `fodder_turnip`: semillas → parcela → crecimiento por `TimeManager` → cosecha → inventario.

El mismo recurso competirá entre abastecer el transporte funerario, vender, comprar como solución de emergencia, cocinar y almacenar. Cultivarlo debe ser la estrategia sostenible; comprarlo, una válvula de recuperación.

La cocina reutiliza `RecipeData`/crafting y la comida recupera energía. No se añade hambre.

## Economía preparada para variación
Los precios siguen partiendo de valores base enteros, con arquitectura preparada para multiplicadores globales, de comerciante, relación y eventos, neutrales (`1.0`) por defecto. No se implementa todavía supply/demand complejo.

## Progresión
La progresión debe reducir fricciones ya experimentadas: mejor conservación concede margen temporal y la rampa elimina recogida manual. Automatizar no debe eliminar las decisiones principales sobre los cadáveres.

## Feedback
Las acciones permanentes deben disponer de hooks visuales/sonoros. La llegada o suspensión del transporte al atardecer debe ser reconocible incluso con placeholders, reutilizando `EventBus` y `AudioManager`.

## Alcance
Se prioriza densidad y calidad sobre tamaño. Fase 8 puede profundizar sistemas anteriores cuando esa profundidad sea necesaria para que el vertical slice cumpla su identidad jugable.

Diseño detallado: `docs/superpowers/specs/2026-08-30-phase8a-cemetery-depth-design.md`.
