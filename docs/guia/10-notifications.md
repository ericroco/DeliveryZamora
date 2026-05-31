# 10 — Notifications

## Qué hace

Almacena notificaciones en base de datos para clientes, merchants y drivers. Se disparan automáticamente desde `OrdersService` cuando se crea un pedido o cambia su estado. Los usuarios consultan y marcan sus notificaciones desde este módulo.

> **Nota:** Las notificaciones actuales son solo de base de datos. FCM (push nativo) es backlog P2.

## Endpoints

| Método | Ruta | Rol | Descripción |
|--------|------|-----|-------------|
| GET | /notifications | CLIENT/MERCHANT/DRIVER | Listar mis notificaciones |
| PATCH | /notifications/:id/read | CLIENT/MERCHANT/DRIVER | Marcar como leída |
| PATCH | /notifications/read-all | CLIENT/MERCHANT/DRIVER | Marcar todas como leídas |
| DELETE | /notifications/:id | CLIENT/MERCHANT/DRIVER | Borrar notificación |

## Probar con Swagger / curl

### Ver mis notificaciones
```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/notifications
```

### Ver solo no leídas
```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:3000/notifications?unreadOnly=true"
```

### Marcar una como leída
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/notifications/<notif-uuid>/read
```

### Marcar todas como leídas
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN" \
  http://localhost:3000/notifications/read-all
```

## Cuándo se generan

| Evento | Notificado | Mensaje |
|--------|-----------|---------|
| Pedido creado (PENDING) | MERCHANT | "Nuevo pedido recibido" |
| CONFIRMED | CLIENT | "Tu pedido fue confirmado" |
| PREPARING | CLIENT | "Tu pedido se está preparando" |
| READY | CLIENT | "Tu pedido está listo para recolección" |
| PICKED_UP | CLIENT | "Tu pedido está en camino" |
| DELIVERED | CLIENT | "Tu pedido fue entregado" |
| CANCELLED | CLIENT | "Tu pedido fue cancelado" |

## Estructura de una notificación

```json
{
  "id": "uuid",
  "userId": "uuid",
  "title": "Nuevo pedido",
  "body": "Tienes un nuevo pedido #ABC123",
  "isRead": false,
  "createdAt": "2026-05-06T12:00:00Z"
}
```

## Notas

- Las notificaciones son por `userId`, no por rol. Cada usuario ve solo las suyas.
- No hay WebSocket todavía; el cliente debe hacer polling a `GET /notifications` para ver nuevas.
- FCM push real está en el backlog P2 (requiere firebase-admin + device tokens).
