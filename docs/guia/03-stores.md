# 03 — Módulos Categories + Stores

## ¿Qué hicimos?

1. Añadimos los modelos `Category` y `Store` al schema de Prisma
2. Construimos el módulo `categories` (CRUD administrado por ADMIN, GET público)
3. Construimos el módulo `stores` (CRUD del merchant, lectura pública, ownership check)

---

## ¿Por qué estas decisiones?

### Category como entidad separada

Las categorías (Farmacia, Restaurante, Supermercado...) son datos del sistema — los gestiona el ADMIN, no los merchants. Separarlas en su propia tabla permite:
- Filtrar stores por categoría en la app del cliente
- Añadir iconos, slugs URL-friendly, y activar/desactivar sin tocar stores
- Escalar con subcategorías en el futuro sin cambiar el modelo de Store

### Store separada de MerchantProfile

Un merchant puede tener **múltiples locales** (Farmacia Central Norte, Farmacia Central Sur). `MerchantProfile` representa la empresa. `Store` representa cada local físico.

`MerchantProfile → [Store, Store, ...]`

### GET /stores y GET /stores/:id son públicos (sin JWT)

La app del cliente necesita listar tiendas sin que el usuario esté logueado (para ver la oferta antes de registrarse). Las rutas de escritura siguen protegidas.

### Ownership check en update/delete

```typescript
if (requesterRole !== 'ADMIN' && store.merchantId !== requesterId) {
  throw new ForbiddenException('You do not own this store');
}
```

Un merchant solo puede editar/desactivar sus propias tiendas. El ADMIN puede editar cualquiera. Este check vive en el **servicio**, no en el guard — es lógica de negocio (quién posee el recurso), no lógica de autenticación.

### latitude/longitude en Store (no en MerchantProfile)

La ubicación geoespacial pertenece al **local físico**, no al perfil de la empresa. Si el merchant tiene 2 locales en distintos puntos de Zamora, cada Store tiene sus propias coordenadas.

---

## Estructura de archivos creados

```
apps/core-api/src/modules/
├── categories/
│   ├── categories.module.ts
│   ├── categories.service.ts
│   ├── categories.controller.ts
│   └── dto/
│       ├── create-category.dto.ts
│       └── update-category.dto.ts
└── stores/
    ├── stores.module.ts
    ├── stores.service.ts
    ├── stores.controller.ts
    └── dto/
        ├── create-store.dto.ts
        └── update-store.dto.ts
```

---

## Schema — modelos nuevos

```prisma
model Category {
  id        String   @id @default(uuid())
  name      String   @unique          // "Farmacia"
  slug      String   @unique          // "farmacia"
  iconUrl   String?
  isActive  Boolean  @default(true)
  ...
  stores Store[]
}

model Store {
  id           String  @id @default(uuid())
  merchantId   String  // FK → MerchantProfile.userId
  categoryId   String  // FK → Category.id
  name         String  // nombre del local
  address      String  // dirección física
  latitude     Float?  // coordenadas GPS
  longitude    Float?
  openingHours Json?   // { monday: { open, close }, sunday: null }
  isActive     Boolean @default(true)
  ...
}
```

---

## Las rutas de ambos módulos

### Categories

| Método | Ruta | Rol | Para qué |
|--------|------|-----|---------|
| GET | `/api/v1/categories` | público | Listar categorías activas |
| POST | `/api/v1/categories` | ADMIN | Crear categoría |
| PATCH | `/api/v1/categories/:id` | ADMIN | Actualizar categoría |
| DELETE | `/api/v1/categories/:id` | ADMIN | Desactivar categoría |

### Stores

| Método | Ruta | Rol | Para qué |
|--------|------|-----|---------|
| GET | `/api/v1/stores?categoryId=...` | público | Listar tiendas activas (con filtro) |
| GET | `/api/v1/stores/:id` | público | Ver tienda específica |
| GET | `/api/v1/stores/mine` | MERCHANT | Mis tiendas |
| POST | `/api/v1/stores` | MERCHANT | Crear tienda |
| PATCH | `/api/v1/stores/:id` | MERCHANT (dueño) / ADMIN | Actualizar tienda |
| DELETE | `/api/v1/stores/:id` | MERCHANT (dueño) / ADMIN | Desactivar tienda |

---

## Probar los endpoints

### Crear una categoría (como ADMIN)
```bash
# 1. Registrar y loguear un usuario ADMIN
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"+593900000001","password":"admin123","role":"ADMIN"}'

# 2. Crear categoría
curl -X POST http://localhost:3000/api/v1/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{"name":"Farmacia","slug":"farmacia"}'
```

### Crear una tienda (como MERCHANT)
```bash
# categoryId = el ID devuelto al crear la categoría
curl -X POST http://localhost:3000/api/v1/stores \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{
    "name": "Farmacia Central",
    "categoryId": "uuid-de-la-categoria",
    "address": "Av. 24 de Mayo y Diego de Vaca",
    "latitude": -4.0679,
    "longitude": -78.9468,
    "openingHours": {
      "monday": { "open": "08:00", "close": "22:00" },
      "sunday": null
    }
  }'
```

### Listar tiendas por categoría (público)
```bash
curl "http://localhost:3000/api/v1/stores?categoryId=uuid-de-la-categoria&page=1&limit=10"
```

---

## ¿Qué sigue?

**Siguiente paso:** módulo `products` — ver [04-products.md](./04-products.md)

Lo que vamos a construir:
1. Modelo `Product` — los productos/servicios que ofrece cada tienda
2. Modelo `ProductCategory` — categorías de producto dentro de una tienda (Analgésicos, Vitaminas...)
3. CRUD de productos para el merchant
4. Variantes de producto (tallas, sabores) — opcional para v1
