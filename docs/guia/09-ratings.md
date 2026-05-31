# 09 — Ratings

## Qué hace

Permite a los clientes calificar la tienda y al driver después de que un pedido es entregado. El promedio de calificación se actualiza en tiempo real en los modelos `Store` y `DriverProfile`. Cada pedido solo puede calificarse una vez por cada parte (flag `storeRated` / `driverRated`).

## Endpoints

| Método | Ruta | Rol | Descripción |
|--------|------|-----|-------------|
| POST | /ratings/store | CLIENT | Calificar tienda |
| POST | /ratings/driver | CLIENT | Calificar driver |
| GET | /ratings/store/:storeId | PUBLIC | Ver calificaciones de una tienda |
| GET | /ratings/driver/:driverId | ADMIN/DRIVER | Ver calificaciones de un driver |

## Probar con Swagger / curl

### Calificar tienda (después de DELIVERED)
```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN_CLIENT" \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "<order-uuid>",
    "storeId": "<store-uuid>",
    "score": 5,
    "comment": "Excelente servicio, llegó rápido"
  }' \
  http://localhost:3000/ratings/store
```

### Calificar driver
```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN_CLIENT" \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "<order-uuid>",
    "driverId": "<driver-uuid>",
    "score": 4
  }' \
  http://localhost:3000/ratings/driver
```

### Ver calificaciones de una tienda (público)
```bash
curl http://localhost:3000/ratings/store/<store-uuid>
```

## Fórmula del promedio

```
nuevoPromedio = (promedioActual * conteoActual + nuevaCalificacion) / (conteoActual + 1)
```

Se usa aritmética exacta de Prisma `Decimal` para evitar errores de punto flotante.

## Reglas de negocio

| Regla | Implementación |
|-------|----------------|
| Solo el cliente del pedido puede calificar | Verifica `order.clientId === user.id` |
| Pedido debe estar DELIVERED | Verifica `order.status === 'DELIVERED'` |
| Solo una calificación de tienda por pedido | Flag `order.storeRated` |
| Solo una calificación de driver por pedido | Flag `order.driverRated` |
| Score entre 1 y 5 | Validación en DTO |

## Transacción atómica

`rateStore()` ejecuta en `$transaction`:
1. `store.update` — recalcula `ratingAvg` y suma 1 a `ratingCount`
2. `storeRating.create` — guarda el registro individual
3. `order.update` — pone `storeRated = true`

`rateDriver()` igual pero sobre `DriverProfile` y `driverRated`.

## Notas

- Si el pedido no tiene driver asignado y se intenta calificar al driver: lanza `BadRequestException`.
- El `comment` es opcional en ambos tipos de calificación.
- Las calificaciones no se pueden editar ni borrar (registro permanente).
