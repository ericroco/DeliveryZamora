# 05 — Módulo Orders

## ¿Qué hicimos?

1. Añadimos `OrderStatus` enum y modelos `Order` + `OrderItem` al schema de Prisma
2. Construimos el módulo `orders` con lógica de transición de estados
3. El cliente crea pedidos, el merchant los confirma, el driver los recoge

---

## ¿Por qué estas decisiones?

### Estado capturado en `OrderItem.unitPrice`

El precio del producto puede cambiar después de que se hizo el pedido. Capturamos `unitPrice` al momento de crear la orden — así la factura siempre refleja lo que el cliente pagó realmente.

### Máquina de estados explícita

Las transiciones están definidas en `ALLOWED_TRANSITIONS`:

```
PENDING → CONFIRMED  (MERCHANT/ADMIN)
PENDING → CANCELLED  (MERCHANT/ADMIN/CLIENT)
CONFIRMED → PREPARING (MERCHANT/ADMIN)
CONFIRMED → CANCELLED (MERCHANT/ADMIN)
PREPARING → READY    (MERCHANT/ADMIN)
READY → PICKED_UP    (DRIVER/ADMIN)
PICKED_UP → DELIVERED (DRIVER/ADMIN)
```

Ventaja: si intentas `PENDING → DELIVERED` directamente, la API rechaza con 400 — no hay forma de saltarse pasos.

### `driverId` se asigna al hacer PICKED_UP

No se asigna driver al crear el pedido. Cuando un driver hace `PATCH /orders/:id/status` con `{ status: "PICKED_UP" }`, el sistema asigna automáticamente `driverId = requester.id`.

### Control de acceso por rol

- **CLIENT**: solo ve/cancela sus propios pedidos
- **MERCHANT**: solo ve/gestiona pedidos de sus tiendas
- **DRIVER**: solo ve/actualiza pedidos asignados a él (o recién en READY)
- **ADMIN**: acceso total

---

## Estructura de archivos creados

```
apps/core-api/src/modules/orders/
├── orders.module.ts
├── orders.service.ts
├── orders.controller.ts
└── dto/
    ├── create-order.dto.ts
    └── update-order-status.dto.ts
```

---

## Schema — modelos nuevos

```prisma
enum OrderStatus {
  PENDING | CONFIRMED | PREPARING | READY | PICKED_UP | DELIVERED | CANCELLED
}

model Order {
  id              String      @id
  clientId        String      // FK → User (CLIENT)
  storeId         String      // FK → Store
  driverId        String?     // FK → DriverProfile (asignado en PICKED_UP)
  status          OrderStatus @default(PENDING)
  totalAmount     Decimal     @db.Decimal(10, 2)
  deliveryAddress String
  notes           String?
}

model OrderItem {
  id        String
  orderId   String   // FK → Order (cascade delete)
  productId String   // FK → Product
  quantity  Int
  unitPrice Decimal  @db.Decimal(10, 2)  // precio capturado al momento de compra
  subtotal  Decimal  @db.Decimal(10, 2)  // quantity * unitPrice
}
```

---

## Las rutas del módulo

| Método | Ruta | Rol | Para qué |
|--------|------|-----|---------|
| POST | `/api/v1/orders` | CLIENT | Crear pedido |
| GET | `/api/v1/orders` | Todos (auth) | Listar pedidos (filtrado por rol) |
| GET | `/api/v1/orders/:id` | Todos (auth) | Ver pedido |
| PATCH | `/api/v1/orders/:id/status` | MERCHANT/DRIVER/ADMIN | Avanzar estado |

---

## Probar los endpoints

### Crear pedido (CLIENT)
```bash
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer CLIENT_TOKEN" \
  -d '{
    "storeId": "STORE_ID",
    "deliveryAddress": "Calle Bolívar 123, Zamora",
    "notes": "Sin cebolla",
    "items": [
      { "productId": "PRODUCT_ID_1", "quantity": 2 },
      { "productId": "PRODUCT_ID_2", "quantity": 1 }
    ]
  }'
```

### Confirmar pedido (MERCHANT)
```bash
curl -X PATCH http://localhost:3000/api/v1/orders/ORDER_ID/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"status": "CONFIRMED"}'
```

### Driver recoge pedido
```bash
curl -X PATCH http://localhost:3000/api/v1/orders/ORDER_ID/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DRIVER_TOKEN" \
  -d '{"status": "PICKED_UP"}'
```

---

## ¿Qué sigue?

**Siguiente paso:** módulo `drivers` — ver [06-drivers.md](./06-drivers.md)

Lo que vamos a construir:
1. Gestión del perfil del driver (ya existe `DriverProfile` en DB)
2. Toggle de disponibilidad (`isAvailable`)
3. Lista de pedidos disponibles para tomar (estado READY, sin driver asignado)
4. Rating del driver tras entrega
