# 06 — Módulo Drivers

## ¿Qué hicimos?

1. Añadimos `ratingCount` a `DriverProfile` para calcular promedio de rating correctamente
2. Construimos el módulo `drivers` con perfil, disponibilidad, pedidos disponibles y rating

---

## ¿Por qué estas decisiones?

### `ratingCount` para promedio móvil correcto

Sin `ratingCount`, no puedes recalcular el promedio — solo tendrías el último valor. Con el conteo:

```
newAvg = (oldAvg * oldCount + newRating) / (oldCount + 1)
```

Así el promedio es matemáticamente correcto sin guardar todos los ratings individuales.

### `GET /drivers/available-orders` — pedidos sin driver asignado

El driver ve solo los pedidos en estado `READY` con `driverId = null`. Esto permite un modelo "primer en llegar, primer en servir" — el driver que haga `PATCH /orders/:id/status { "status": "PICKED_UP" }` primero gana el pedido y queda asignado automáticamente.

### Rating solo después de `DELIVERED`

Validamos `order.status === DELIVERED` antes de permitir rating. Si el pedido fue cancelado o está en tránsito, la API rechaza con 400. Evita ratings prematuros o de prueba.

### `PATCH /drivers/me/availability` — toggle simple

El driver solo envía `{ "isAvailable": true/false }`. No se expone el mecanismo de asignación — la app móvil simplemente activa/desactiva disponibilidad.

---

## Estructura de archivos creados

```
apps/core-api/src/modules/drivers/
├── drivers.module.ts
├── drivers.service.ts
├── drivers.controller.ts
└── dto/
    ├── create-driver-profile.dto.ts
    ├── update-driver-profile.dto.ts
    └── rate-driver.dto.ts
```

---

## Schema — cambio en DriverProfile

```prisma
model DriverProfile {
  // ... campos existentes ...
  ratingAvg   Decimal @default(5.0)  // promedio de ratings
  ratingCount Int     @default(0)    // número de ratings recibidos ← NUEVO
}
```

---

## Las rutas del módulo

### Driver (propio)

| Método | Ruta | Rol | Para qué |
|--------|------|-----|---------|
| POST | `/api/v1/drivers/profile` | DRIVER | Crear perfil |
| GET | `/api/v1/drivers/me` | DRIVER | Ver mi perfil |
| PATCH | `/api/v1/drivers/me` | DRIVER | Actualizar perfil |
| PATCH | `/api/v1/drivers/me/availability` | DRIVER | Toggle disponibilidad |
| GET | `/api/v1/drivers/available-orders` | DRIVER | Ver pedidos READY sin driver |

### Rating

| Método | Ruta | Rol | Para qué |
|--------|------|-----|---------|
| POST | `/api/v1/drivers/orders/:orderId/rate` | CLIENT | Calificar al driver tras entrega |

### Admin

| Método | Ruta | Rol | Para qué |
|--------|------|-----|---------|
| GET | `/api/v1/drivers` | ADMIN | Listar todos los drivers |
| GET | `/api/v1/drivers/:userId` | ADMIN | Ver driver |
| PATCH | `/api/v1/drivers/:userId/suspend` | ADMIN | Suspender driver |

---

## Probar los endpoints

### Crear perfil de driver
```bash
curl -X POST http://localhost:3000/api/v1/drivers/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DRIVER_TOKEN" \
  -d '{
    "name": "Carlos Pérez",
    "cedula": "1107654321",
    "vehicleType": "moto",
    "plate": "ZMR-123"
  }'
```

### Activar disponibilidad
```bash
curl -X PATCH http://localhost:3000/api/v1/drivers/me/availability \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DRIVER_TOKEN" \
  -d '{"isAvailable": true}'
```

### Ver pedidos disponibles
```bash
curl http://localhost:3000/api/v1/drivers/available-orders \
  -H "Authorization: Bearer DRIVER_TOKEN"
```

### Tomar pedido (PICKED_UP → asigna driverId)
```bash
curl -X PATCH http://localhost:3000/api/v1/orders/ORDER_ID/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DRIVER_TOKEN" \
  -d '{"status": "PICKED_UP"}'
```

### Cliente califica al driver
```bash
curl -X POST http://localhost:3000/api/v1/drivers/orders/ORDER_ID/rate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer CLIENT_TOKEN" \
  -d '{"rating": 5}'
```

---

## ¿Qué sigue?

**Siguiente paso:** módulo `notifications` — ver [07-notifications.md](./07-notifications.md)

Lo que vamos a construir:
1. Integración con Firebase Cloud Messaging (FCM) o similar para push notifications
2. Notificaciones al cliente cuando cambia el estado de su pedido
3. Notificaciones al merchant cuando llega un pedido nuevo
4. Notificaciones al driver cuando hay pedidos disponibles en su zona
