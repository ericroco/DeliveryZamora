# 13 — Analytics

## Qué hace

Dashboard de métricas para ADMIN. Proporciona datos agregados sobre el negocio: resumen general, pedidos por estado, ingresos por período, tiendas y drivers más activos, y distribución de usuarios por rol.

## Endpoints

| Método | Ruta | Rol | Descripción |
|--------|------|-----|-------------|
| GET | /analytics/summary | ADMIN | Resumen general |
| GET | /analytics/orders-by-status | ADMIN | Conteo de pedidos por estado |
| GET | /analytics/revenue | ADMIN | Ingresos agrupados por día |
| GET | /analytics/top-stores | ADMIN | Tiendas con más pedidos |
| GET | /analytics/top-drivers | ADMIN | Drivers mejor calificados |
| GET | /analytics/users-by-role | ADMIN | Usuarios por rol |

## Probar con Swagger / curl

### Resumen general
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/analytics/summary
```

Respuesta:
```json
{
  "totalUsers": 342,
  "totalStores": 28,
  "totalOrders": 1205,
  "totalRevenue": "18430.50",
  "pendingOrders": 7
}
```

### Pedidos por estado
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/analytics/orders-by-status
```

Respuesta:
```json
{
  "PENDING": 7,
  "CONFIRMED": 3,
  "PREPARING": 5,
  "READY": 2,
  "PICKED_UP": 4,
  "DELIVERED": 1150,
  "CANCELLED": 34
}
```

### Ingresos por período
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/analytics/revenue?from=2026-05-01&to=2026-05-06"
```

Respuesta:
```json
[
  { "date": "2026-05-01", "revenue": "1240.00", "orders": 82 },
  { "date": "2026-05-02", "revenue": "980.50", "orders": 65 },
  ...
]
```

### Top tiendas
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/analytics/top-stores?limit=10"
```

### Top drivers
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/analytics/top-drivers?limit=10"
```

### Usuarios por rol
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/analytics/users-by-role
```

Respuesta:
```json
{
  "CLIENT": 280,
  "MERCHANT": 42,
  "DRIVER": 18,
  "ADMIN": 2
}
```

## Implementación

- `getSummary()` ejecuta 5 queries en paralelo con `Promise.all`.
- `getOrdersByStatus()` itera el enum `OrderStatus` y hace `count` por cada uno.
- `getRevenueByPeriod()` usa `groupBy` de Prisma sobre `createdAt` truncado a día.
- `getTopStores()` ordena por `_count: { orders: 'desc' }`.
- `getTopDrivers()` ordena por `ratingAvg: 'desc'`.

## Notas

- Todos los endpoints requieren rol ADMIN; devuelven 403 para cualquier otro rol.
- Los datos son en tiempo real (sin caché). Para dashboards con mucho tráfico, agregar Redis cache es backlog P3.
- `getRevenueByPeriod` acepta `from` y `to` como query params en formato `YYYY-MM-DD`. Sin parámetros retorna los últimos 30 días.
