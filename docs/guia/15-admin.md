# 15 — Admin

## Qué hace

Panel operacional exclusivo para ADMIN. Agrega funciones que no existen en otros módulos: dashboard operacional en tiempo real, filtros ricos en pedidos, historial de estados, cancelación forzada, reporte de comisiones por merchant, cola de merchants pendientes de verificación, y gestión de tiendas.

> Todos los endpoints requieren `role: ADMIN`. Devuelven 403 para cualquier otro rol.

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | /admin/dashboard | Snapshot operacional en tiempo real |
| GET | /admin/orders | Todos los pedidos con filtros |
| GET | /admin/orders/:orderId/history | Historial de cambios de estado |
| PATCH | /admin/orders/:orderId/cancel | Forzar cancelación (disputas) |
| GET | /admin/commissions | Reporte de comisiones (todos los merchants) |
| GET | /admin/commissions/:merchantId | Detalle de comisiones de un merchant |
| GET | /admin/merchants/pending | Cola de merchants sin verificar |
| GET | /admin/stores | Todas las tiendas (activas + inactivas) |
| PATCH | /admin/stores/:storeId/activate | Activar tienda |
| PATCH | /admin/stores/:storeId/deactivate | Desactivar tienda |

## Probar con curl

### Dashboard operacional
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/admin/dashboard
```

Respuesta:
```json
{
  "pendingOrders": 3,
  "activeDeliveries": 2,
  "todayOrders": 47,
  "todayRevenue": "384.50",
  "unverifiedMerchants": 2,
  "availableDrivers": 4,
  "totalStores": 12
}
```

### Pedidos con filtros
```bash
# Todos los pedidos pendientes de hoy
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/admin/orders?status=PENDING&from=2026-05-06"

# Todos los pedidos de una tienda específica
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/admin/orders?storeId=<uuid>&page=1&limit=50"

# Pedidos entregados en un rango de fechas
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/admin/orders?status=DELIVERED&from=2026-05-01&to=2026-05-31"
```

### Historial de estados de un pedido
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/admin/orders/<order-uuid>/history
```

Respuesta:
```json
[
  {
    "fromStatus": "PENDING",
    "toStatus": "CONFIRMED",
    "changedBy": { "phone": "0991234567", "role": "MERCHANT" },
    "createdAt": "2026-05-06T14:01:00Z"
  },
  {
    "fromStatus": "CONFIRMED",
    "toStatus": "PREPARING",
    "changedBy": { "phone": "0991234567", "role": "MERCHANT" },
    "createdAt": "2026-05-06T14:05:00Z"
  }
]
```

### Cancelación forzada (dispute)
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/admin/orders/<order-uuid>/cancel
```
Funciona en cualquier estado excepto DELIVERED y CANCELLED. Registra el cambio en `OrderStatusHistory`.

### Reporte de comisiones del mes
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/admin/commissions?from=2026-05-01&to=2026-05-31"
```

Respuesta:
```json
[
  {
    "merchantId": "uuid",
    "businessName": "Farmacia Central",
    "commissionRate": "0.1200",
    "totalOrders": 142,
    "totalRevenue": 1840.50,
    "commissionAmount": 220.86
  }
]
```

### Detalle de comisiones de un merchant
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/admin/commissions/<merchantId>?from=2026-05-01&to=2026-05-31"
```

### Cola de merchants pendientes
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/admin/merchants/pending
```

### Tiendas — todas (incluyendo inactivas)
```bash
# Todas
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/admin/stores

# Solo inactivas
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/admin/stores?isActive=false"
```

### Activar / desactivar tienda
```bash
curl -X PATCH -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/admin/stores/<store-uuid>/deactivate

curl -X PATCH -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/admin/stores/<store-uuid>/activate
```

## Diferencia con /analytics

| | /analytics | /admin |
|--|-----------|--------|
| Foco | Métricas históricas (totales, promedios) | Operaciones en tiempo real |
| Acciones | Solo lectura | Lectura + escritura (cancel, toggle) |
| Pedidos | Conteos por estado | Lista filtrable con detalle |
| Comisiones | No existe | Cálculo por merchant y período |
| Merchants | No existe | Cola de pendientes de verificación |

## Notas

- `GET /admin/commissions` solo incluye merchants verificados y con al menos 1 pedido entregado en el período.
- `commissionAmount = totalRevenue × commissionRate` (calculado en tiempo real, no almacenado).
- El filtro `from`/`to` en `/admin/orders` usa `createdAt` del pedido (zona UTC).
- `PATCH /admin/orders/:id/cancel` registra el cambio en `OrderStatusHistory` para trazabilidad.
