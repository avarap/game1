# 08 — Economía y comercio

## Regla central
Todo `ItemData` vendible debe tener al menos un comprador compatible, salvo `quest_only`, `key_item` o `non_sellable`.

## Comerciantes
No todos los aldeanos comercian. `MerchantProfile` define `accept_tags`, `sell_offers`, afinidades, límites/cupos, multiplicadores y restricciones.

## Ejemplos
- Herrero: `iron`, `ore`, `metal_part`, `tool`.
- Carpintero: `wood`, `plank`, `resin`, `carpentry_part`.
- Agricultor: `crop`, `seed`, `fertilizer`.
- Taberna/cocinero: `food`, `flour`, `herb`, `oil`.
- Especialista funerario/ocultista original: tags apropiados a narrativa.
- Comerciante general: cobertura amplia a peor precio.

## Precio
Pipeline futuro: `base × global × merchant × relationship`, con valores neutrales por defecto. Cupos/demanda ligera pueden limitar venta infinita sin simular un mercado complejo.

## Validación
Test/herramienta que falle si un item vendible no tiene comprador.

## UX
Interfaz separa inventario jugador/oferta comerciante, deja claro qué acepta, precio, cantidad y resultado antes de confirmar.