# 08 — Promotions

## Qué hace

Gestiona códigos de descuento que los merchants crean para sus tiendas. Los clientes aplican un código al crear un pedido. El sistema valida la vigencia, el monto mínimo, el uso máximo, y calcula el descuento automáticamente.

## Endpoints

| Método | Ruta | Rol | Descripción |
|--------|------|-----|-------------|
| POST | /promotions | MERCHANT | Crear promoción |
| GET | /promotions | MERCHANT/ADMIN | Listar promociones (merchant ve las suyas) |
| GET | /promotions/:id | MERCHANT/ADMIN | Ver detalle |
| PATCH | /promotions/:id | MERCHANT | Actualizar |
| DELETE | /promotions/:id | MERCHANT | Desactivar (soft delete) |

## Probar con Swagger / curl

### Crear promoción (MERCHANT)
```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN_MERCHANT" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "PROMO10",
    "discountType": "PERCENTAGE",
    "discountValue": 10,
    "storeId": "<store-uuid>",
    "minOrderAmount": 5.00,
    "maxUses": 100,
    "expiresAt": "2026-12-31T23:59:59Z"
  }' \
  http://localhost:3000/promotions
```

### Promoción de monto fijo
```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN_MERCHANT" \
  -H "Content-Type: application/json" \
  -d '{
    "code": "DESC1USD",
    "discountType": "FIXED",
    "discountValue": 1.00,
    "storeId": "<store-uuid>",
    "minOrderAmount": 3.00
  }' \
  http://localhost:3000/promotions
```

### Aplicar al crear pedido (CLIENT)
```bash
curl -X POST \
  -H "Authorization: Bearer $TOKEN_CLIENT" \
  -H "Content-Type: application/json" \
  -d '{
    "storeId": "<store-uuid>",
    "items": [{"productId":"<uuid>","quantity":2}],
    "deliveryAddress": "Calle X",
    "promoCode": "PROMO10"
  }' \
  http://localhost:3000/orders
```

## Tipos de descuento

| discountType | Comportamiento |
|-------------|----------------|
| PERCENTAGE | `descuento = subtotal * (value / 100)` |
| FIXED | `descuento = value` (no puede superar el subtotal) |

## Campos

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| code | string | ✓ | Código único por tienda |
| discountType | PERCENTAGE/FIXED | ✓ | Tipo de descuento |
| discountValue | number | ✓ | Porcentaje o monto |
| storeId | uuid | ✓ | Tienda donde aplica |
| minOrderAmount | number | — | Monto mínimo del pedido |
| maxUses | number | — | Límite de usos totales (null = ilimitado) |
| expiresAt | ISO date | — | Fecha de expiración (null = no expira) |

## Lógica de validación (en validate())

1. Promo existe y `isActive = true`
2. `storeId` coincide con el del pedido
3. `expiresAt` no ha pasado (si existe)
4. Subtotal del pedido >= `minOrderAmount` (si existe)
5. `usedCount < maxUses` (si existe)

Si falla alguna: lanza `BadRequestException`.

## Notas

- `consume()` usa `$transaction` para incrementar `usedCount` + crear `PromoUsage` atómicamente.
- La promo se valida Y consume en el mismo request de creación del pedido.
- `originalAmount` y `discountAmount` quedan registrados en el pedido para trazabilidad.
