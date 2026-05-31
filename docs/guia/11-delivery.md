# 11 — Delivery

## Qué hace

Gestiona la localización en tiempo real del driver durante la entrega. El driver actualiza su posición GPS mientras el pedido está en estado `PICKED_UP`. El cliente, merchant y admin pueden consultar la última posición conocida.

> **Nota:** Este módulo es un placeholder de polling. El sistema de tracking en tiempo real (Socket.io + TimescaleDB) es backlog P2.

## Endpoints

| Método | Ruta | Rol | Descripción |
|--------|------|-----|-------------|
| PATCH | /delivery/:orderId/location | DRIVER | Actualizar posición GPS |
| GET | /delivery/:orderId/location | CLIENT/MERCHANT/DRIVER/ADMIN | Consultar última posición |

## Probar con Swagger / curl

### Driver actualiza posición (solo cuando pedido está PICKED_UP)
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN_DRIVER" \
  -H "Content-Type: application/json" \
  -d '{"lat": -4.0678, "lng": -78.9510}' \
  http://localhost:3000/delivery/<order-uuid>/location
```

### Cliente consulta posición del driver
```bash
curl -H "Authorization: Bearer $TOKEN_CLIENT" \
  http://localhost:3000/delivery/<order-uuid>/location
```

Respuesta ejemplo:
```json
{
  "orderId": "uuid",
  "driverLat": -4.0678,
  "driverLng": -78.9510,
  "locationUpdatedAt": "2026-05-06T14:32:00Z"
}
```

## Reglas

| Regla | Implementación |
|-------|----------------|
| Solo el driver asignado puede actualizar | Verifica `order.driverId === user.id` |
| Solo cuando pedido está PICKED_UP | Verifica `order.status === 'PICKED_UP'` |
| Solo partes del pedido pueden ver la ubicación | CLIENT ve si `order.clientId === user.id`, MERCHANT si `order.storeId` pertenece al merchant |

## Flujo completo de entrega

```
PENDING → (driver acepta) PICKED_UP
  │
  ├─ Driver llama PATCH /delivery/:id/location cada N segundos
  │
  └─ Cliente llama GET /delivery/:id/location (polling)
        │
        └─ Cuando entregado: PATCH /orders/:id/status { status: "DELIVERED" }
```

## Notas

- `driverLat`, `driverLng`, `locationUpdatedAt` se guardan directamente en el modelo `Order`.
- El polling desde el cliente mobile se haría cada ~5 segundos mientras el pedido esté `PICKED_UP`.
- La migración al tracking-service real (P2) no cambia esta API; agrega un canal WebSocket paralelo.
