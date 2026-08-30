# 09 — Agricultura

## MVP actual
`fodder_turnip_seed → parcela → crecimiento por TimeManager → cosecha → inventario → persistencia`.

## Arquitectura extensible
`CropData`: id, seed item, produce item(s), stages, growth duration, yield, regrow opcional, requirements, sprite refs y tags.

## Segundo cultivo recomendado
`wheat`: valida que el sistema sea genérico y conecta agricultura con procesamiento (`wheat → flour`).

## Expansión gradual
Después del MVP: 4–6 cultivos con roles distintos, no 20 variantes cosméticas. Ejemplos: alimento, ingrediente, forraje, hierba medicinal, cultivo de alto valor.

## Fuera inicialmente
Riego complejo, clima que destruya cosechas, estaciones y fertilizantes avanzados.

## Conexiones
Cultivos deben poder alimentar servicio funerario/logística, cocina, comercio y crafting para evitar un subsistema aislado.