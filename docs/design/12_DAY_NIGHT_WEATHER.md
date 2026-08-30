# 12 — Día, noche y clima

## Tiempo
`TimeManager` sigue siendo única fuente de reloj/calendario.

## Día/noche
La hora debe influir progresivamente en iluminación, disponibilidad de NPCs, eventos, entregas y atmósfera.

## Clima — post-MVP
Primera versión solo visual/contextual: lluvia, niebla y variantes ambientales. No afectar farming hasta estabilizar agricultura.

## Posibles efectos posteriores
NPCs cambian rutina, ciertos recursos/eventos aparecen, visibilidad/sonido cambia, pesca puede variar.

## Regla técnica
Clima es estado persistible/data-driven y emite eventos; sistemas consumidores reaccionan sin acoplamiento directo.

## Arte
Interiores usan fuentes locales de luz y zonas oscuras; exteriores diferencian madrugada/día/tarde/noche manteniendo legibilidad.