# 04 — Módulo Products

## ¿Qué hicimos?

1. Añadimos `ProductCategory` y `Product` al schema de Prisma
2. Construimos el módulo `products` con dos controllers anidados bajo `/stores/:storeId/`
3. Reutilizamos el ownership check de la tienda para proteger todas las escrituras

---

## ¿Por qué estas decisiones?

### ProductCategory dentro de la tienda, no global

Las categorías de producto son del negocio — "Analgésicos" y "Vitaminas" son de la Farmacia Central, no del sistema. Cada tienda tiene su propio árbol de categorías.

Comparar con `Category` (el tipo de tienda — Farmacia, Restaurante): esa sí es global y la gestiona el ADMIN.

### Rutas anidadas bajo `/stores/:storeId/`

Los endpoints son:
```
GET  /stores/:storeId/products
GET  /stores/:storeId/products/:id
POST /stores/:storeId/products
...
```

El `storeId` en la URL hace explícito que los productos pertenecen a una tienda. Sin esto necesitarías enviar `storeId` en el body de cada request — menos REST, más propenso a errores.

### `assertOwnership` compartido entre servicios

`ProductCategoriesService.assertOwnership()` lo usan tanto `ProductCategoriesService` como `ProductsService`. Evita duplicar la lógica:

```typescript
// ProductsService inyecta ProductCategoriesService
await this.productCategoriesService.assertOwnership(storeId, requesterId, requesterRole);
```

### `isAvailable` vs `isActive` en Product

Dos estados diferentes:
- `isAvailable = false`: agotado temporalmente (muestra "Sin stock" en la app)
- `isActive = false`: eliminado del catálogo (no aparece en ninguna lista)

El merchant puede toggle `isAvailable` del día a día sin borrar el producto.

### `price` como `Decimal(10,2)`

Precios en USD con máximo 2 decimales. `$99,999,999.99` como máximo — más que suficiente. Usamos `Decimal` (no `Float`) porque Float tiene errores de redondeo que no quieres en precios:
```
Float:   0.1 + 0.2 = 0.30000000000000004
Decimal: 0.1 + 0.2 = 0.3
```

---

## Estructura de archivos creados

```
apps/core-api/src/modules/products/
├── products.module.ts
├── products.service.ts
├── products.controller.ts              ← rutas: /stores/:storeId/products
├── product-categories.service.ts
├── product-categories.controller.ts    ← rutas: /stores/:storeId/product-categories
└── dto/
    ├── create-product-category.dto.ts
    ├── update-product-category.dto.ts
    ├── create-product.dto.ts
    └── update-product.dto.ts
```

---

## Schema — modelos nuevos

```prisma
model ProductCategory {
  id        String   @id
  storeId   String           // FK → Store
  name      String           // "Analgésicos", "Vitaminas"
  sortOrder Int      @default(0)
  isActive  Boolean  @default(true)
  products  Product[]
}

model Product {
  id                String   @id
  storeId           String           // FK → Store
  productCategoryId String?          // FK → ProductCategory (opcional)
  name              String
  price             Decimal  @db.Decimal(10, 2)
  description       String?
  imageUrl          String?
  isAvailable       Boolean  @default(true)   // stock
  isActive          Boolean  @default(true)   // visibilidad
  sortOrder         Int      @default(0)
}
```

---

## Las rutas del módulo

### Product Categories

| Método | Ruta | Rol | Para qué |
|--------|------|-----|---------|
| GET | `/api/v1/stores/:storeId/product-categories` | público | Listar categorías de la tienda |
| POST | `/api/v1/stores/:storeId/product-categories` | MERCHANT (dueño) / ADMIN | Crear categoría |
| PATCH | `/api/v1/stores/:storeId/product-categories/:id` | MERCHANT (dueño) / ADMIN | Actualizar |
| DELETE | `/api/v1/stores/:storeId/product-categories/:id` | MERCHANT (dueño) / ADMIN | Desactivar |

### Products

| Método | Ruta | Rol | Para qué |
|--------|------|-----|---------|
| GET | `/api/v1/stores/:storeId/products` | público | Listar productos activos |
| GET | `/api/v1/stores/:storeId/products/:id` | público | Ver producto |
| POST | `/api/v1/stores/:storeId/products` | MERCHANT (dueño) / ADMIN | Crear producto |
| PATCH | `/api/v1/stores/:storeId/products/:id` | MERCHANT (dueño) / ADMIN | Actualizar |
| DELETE | `/api/v1/stores/:storeId/products/:id` | MERCHANT (dueño) / ADMIN | Desactivar |

---

## Probar los endpoints

### Crear categoría de producto
```bash
curl -X POST http://localhost:3000/api/v1/stores/STORE_ID/product-categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"name":"Analgésicos","sortOrder":0}'
```

### Crear producto
```bash
curl -X POST http://localhost:3000/api/v1/stores/STORE_ID/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{
    "name": "Paracetamol 500mg x 10",
    "price": 1.25,
    "productCategoryId": "PRODUCT_CATEGORY_ID",
    "description": "Caja de 10 tabletas de 500mg"
  }'
```

### Listar productos (filtrar por categoría)
```bash
curl "http://localhost:3000/api/v1/stores/STORE_ID/products?productCategoryId=CAT_ID"
```

### Marcar como sin stock
```bash
curl -X PATCH http://localhost:3000/api/v1/stores/STORE_ID/products/PRODUCT_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"isAvailable": false}'
```

---

## ¿Qué sigue?

**Siguiente paso:** módulo `orders` — ver [05-orders.md](./05-orders.md)

Lo que vamos a construir:
1. Modelo `Order` con estados (PENDING → CONFIRMED → PREPARING → READY → PICKED_UP → DELIVERED)
2. Modelo `OrderItem` — los productos de cada pedido con precio capturado al momento de la compra
3. El cliente crea un pedido desde la app
4. El merchant confirma/rechaza y actualiza el estado
