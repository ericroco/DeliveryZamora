# Guía de Pruebas Completa — DeliveryZamora API

> **Herramienta recomendada:** Postman (guarda tokens entre requests, permite variables de entorno).  
> **Alternativa:** Swagger en `http://localhost:3000/api/docs` — sirve para explorar pero no guarda estado entre requests.  
> **Base URL:** `http://localhost:3000`

---

## ÍNDICE

1. [Preparación del entorno](#1-preparación-del-entorno)
2. [Configurar Postman](#2-configurar-postman)
3. [Auth — Registro y Login](#3-auth--registro-y-login)
4. [Categories — ADMIN crea categorías](#4-categories)
5. [Merchants — Perfil y verificación](#5-merchants)
6. [Stores — Tiendas](#6-stores)
7. [Products — Categorías y productos](#7-products)
8. [Catalog — Endpoints públicos](#8-catalog)
9. [Clients — Perfil de cliente](#9-clients)
10. [Promotions — Códigos de descuento](#10-promotions)
11. [Orders — Flujo completo de pedido](#11-orders)
12. [Drivers — Perfil y disponibilidad](#12-drivers)
13. [Delivery — Tracking de ubicación](#13-delivery)
14. [Ratings — Calificaciones](#14-ratings)
15. [Notifications — Notificaciones](#15-notifications)
16. [Admin — Panel operacional](#16-admin)
17. [Analytics — Estadísticas](#17-analytics)
18. [Users — Gestión de usuarios](#18-users)
19. [Casos de error esperados](#19-casos-de-error-esperados)

---

## 1. Preparación del entorno

### 1.1 Requisitos previos

- Docker Desktop corriendo
- Node.js instalado
- pnpm instalado

### 1.2 Levantar infraestructura (PostgreSQL + Redis)

```bash
cd C:\Users\StarMedia\Desktop\TrabajosWeb\DeliveryZamora
docker compose -f docker-compose.infra.yml up -d
```

Verifica que los contenedores estén corriendo:
```bash
docker ps
```
Debes ver PostgreSQL en puerto `5434` y Redis en `6379`.

### 1.3 Variables de entorno

Revisa que `apps/core-api/.env` tenga:
```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5434/dz_core"
JWT_ACCESS_SECRET="tu_secreto_access"
JWT_REFRESH_SECRET="tu_secreto_refresh"
JWT_ACCESS_EXPIRES_IN="15m"
JWT_REFRESH_EXPIRES_IN="30d"
```

### 1.4 Levantar el servidor

```bash
cd apps/core-api
npm run start:dev
```

Espera ver en consola:
```
[NestApplication] Nest application successfully started
```

Swagger disponible en: `http://localhost:3000/api/docs`

### 1.5 Crear el usuario ADMIN (seed)

ADMIN no se puede registrar por la API (bloqueado por seguridad). Créalo directo en la DB:

```bash
cd apps/core-api
npx ts-node -e "
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');
const prisma = new PrismaClient();

async function main() {
  const hash = await bcrypt.hash('Admin1234!', 12);
  const admin = await prisma.user.create({
    data: {
      phone: '+593900000001',
      email: 'admin@deliveryzamora.com',
      passwordHash: hash,
      role: 'ADMIN',
      status: 'ACTIVE',
    },
  });
  console.log('ADMIN creado:', admin.id, admin.phone);
  await prisma.\$disconnect();
}
main();
"
```

**Resultado esperado:**
```
ADMIN creado: <uuid> +593900000001
```

---

## 2. Configurar Postman

### 2.1 Crear Environment en Postman

`Environments` → `New` → nombre: `DeliveryZamora Local`

Agrega estas variables (todas vacías inicialmente, las vas llenando conforme avanzas):

| Variable | Initial Value |
|----------|--------------|
| `BASE_URL` | `http://localhost:3000` |
| `ADMIN_TOKEN` | *(vacío)* |
| `MERCHANT_TOKEN` | *(vacío)* |
| `CLIENT_TOKEN` | *(vacío)* |
| `DRIVER_TOKEN` | *(vacío)* |
| `CATEGORY_ID` | *(vacío)* |
| `STORE_ID` | *(vacío)* |
| `PRODUCT_ID` | *(vacío)* |
| `PRODUCT_CAT_ID` | *(vacío)* |
| `ORDER_ID` | *(vacío)* |
| `PROMO_ID` | *(vacío)* |
| `MERCHANT_USER_ID` | *(vacío)* |
| `CLIENT_USER_ID` | *(vacío)* |
| `DRIVER_USER_ID` | *(vacío)* |

### 2.2 Header de autenticación

En cada request que requiera auth, en la pestaña `Headers`:
```
Authorization: Bearer {{ADMIN_TOKEN}}
```
(cambia `ADMIN_TOKEN` por la variable del rol correspondiente)

### 2.3 Scripts de auto-guardado de tokens (opcional pero muy útil)

En cada request de login, en pestaña `Tests` de Postman, pega esto (cambia la variable según el rol):

```javascript
// Para admin login:
const res = pm.response.json();
pm.environment.set("ADMIN_TOKEN", res.accessToken);
```

---

## 3. Auth — Registro y Login

### 3.1 Login del ADMIN

**`POST /auth/login`**

```json
{
  "phone": "+593900000001",
  "password": "Admin1234!"
}
```

**Respuesta esperada (200):**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc..."
}
```

✅ Guarda `accessToken` en la variable `ADMIN_TOKEN` de Postman.

---

### 3.2 Registrar un MERCHANT

**`POST /auth/register`**

```json
{
  "phone": "+593911111111",
  "password": "Merchant123!",
  "role": "MERCHANT"
}
```

**Respuesta esperada (201):**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc..."
}
```

✅ Guarda `accessToken` en `MERCHANT_TOKEN`.

---

### 3.3 Registrar un CLIENT

**`POST /auth/register`**

```json
{
  "phone": "+593922222222",
  "password": "Client123!",
  "role": "CLIENT"
}
```

**Respuesta esperada (201):** igual al anterior.  
✅ Guarda `accessToken` en `CLIENT_TOKEN`.

---

### 3.4 Registrar un DRIVER

**`POST /auth/register`**

```json
{
  "phone": "+593933333333",
  "password": "Driver123!",
  "role": "DRIVER"
}
```

✅ Guarda `accessToken` en `DRIVER_TOKEN`.

---

### 3.5 Intentar registrar como ADMIN (debe fallar)

**`POST /auth/register`**

```json
{
  "phone": "+593944444444",
  "password": "Hacker123!",
  "role": "ADMIN"
}
```

**Respuesta esperada (400):**
```json
{
  "statusCode": 400,
  "message": ["role must be CLIENT, MERCHANT, or DRIVER"],
  "error": "Bad Request"
}
```

✅ Confirma que el registro de ADMIN está bloqueado.

---

### 3.6 Ver usuario actual (GET /auth/me)

**`GET /auth/me`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):**
```json
{
  "id": "uuid",
  "phone": "+593922222222",
  "email": null,
  "role": "CLIENT",
  "status": "ACTIVE",
  "createdAt": "...",
  "clientProfile": null,
  "merchantProfile": null,
  "driverProfile": null
}
```

---

### 3.7 Refresh token

**`POST /auth/refresh`**

```json
{
  "refreshToken": "<el refreshToken que guardaste del login>"
}
```

**Respuesta esperada (200):** nuevo par de tokens.  
⚠️ El refresh token original queda invalidado — usa solo el nuevo.

---

### 3.8 Logout

**`POST /auth/logout`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):** `{}` o sin body.  
Después de esto, el refreshToken queda inválido en DB.

---

## 4. Categories

### 4.1 Crear categorías (ADMIN)

**`POST /categories`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

```json
{
  "name": "Farmacias",
  "slug": "farmacias",
  "iconUrl": "https://example.com/icons/farmacia.png"
}
```

**Respuesta esperada (201):**
```json
{
  "id": "uuid",
  "name": "Farmacias",
  "slug": "farmacias",
  "iconUrl": "https://example.com/icons/farmacia.png",
  "isActive": true,
  "createdAt": "..."
}
```

✅ Guarda el `id` en `CATEGORY_ID`.

Crea 2-3 categorías más para tener variedad:

```json
{ "name": "Restaurantes", "slug": "restaurantes" }
{ "name": "Tiendas", "slug": "tiendas" }
```

---

### 4.2 Listar categorías (público)

**`GET /categories`**  
*(Sin auth)*

**Respuesta esperada (200):**
```json
[
  { "id": "uuid1", "name": "Farmacias", "slug": "farmacias", "iconUrl": "..." },
  { "id": "uuid2", "name": "Restaurantes", "slug": "restaurantes", "iconUrl": null },
  { "id": "uuid3", "name": "Tiendas", "slug": "tiendas", "iconUrl": null }
]
```

---

### 4.3 Actualizar categoría (ADMIN)

**`PATCH /categories/{{CATEGORY_ID}}`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

```json
{
  "iconUrl": "https://example.com/icons/farmacia-v2.png"
}
```

**Respuesta esperada (200):** categoría actualizada.

---

### 4.4 Intentar crear con slug duplicado (debe fallar)

**`POST /categories`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

```json
{
  "name": "Farmacias Duplicada",
  "slug": "farmacias"
}
```

**Respuesta esperada (409):**
```json
{
  "statusCode": 409,
  "message": "Category with slug \"farmacias\" already exists"
}
```

---

## 5. Merchants

### 5.1 Crear perfil de merchant

**`POST /merchants/profile`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{
  "businessName": "Farmacia Central Zamora",
  "description": "La farmacia más completa del cantón",
  "address": "Av. del Ejército 45, Zamora",
  "phone": "+593911111111",
  "ruc": "1191234560001"
}
```

**Respuesta esperada (201):**
```json
{
  "userId": "uuid",
  "businessName": "Farmacia Central Zamora",
  "description": "La farmacia más completa del cantón",
  "isVerified": false,
  "commissionRate": "0.1200",
  ...
}
```

✅ Guarda `userId` en `MERCHANT_USER_ID`.  
Nota: `isVerified: false` — no puede recibir pedidos todavía.

---

### 5.2 Ver mi perfil (MERCHANT)

**`GET /merchants/me`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

**Respuesta esperada (200):** perfil completo del merchant.

---

### 5.3 Verificar merchant (ADMIN)

**`PATCH /merchants/{{MERCHANT_USER_ID}}/verify`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

*(Sin body)*

**Respuesta esperada (200):**
```json
{
  "userId": "uuid",
  "businessName": "Farmacia Central Zamora",
  "isVerified": true,
  "verifiedAt": "2026-05-06T..."
}
```

✅ Ahora el merchant puede recibir pedidos.

---

### 5.4 Listar todos los merchants (ADMIN)

**`GET /merchants`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):**
```json
{
  "merchants": [...],
  "total": 1,
  "page": 1,
  "limit": 20
}
```

---

### 5.5 Intentar crear perfil dos veces (debe fallar)

**`POST /merchants/profile`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{
  "businessName": "Duplicado",
  "address": "Calle X"
}
```

**Respuesta esperada (409):**
```json
{
  "statusCode": 409,
  "message": "Merchant profile already exists"
}
```

---

## 6. Stores

### 6.1 Crear tienda (MERCHANT)

**`POST /stores`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{
  "name": "Farmacia Central",
  "categoryId": "{{CATEGORY_ID}}",
  "address": "Av. del Ejército 45, Zamora",
  "phone": "+593911111111",
  "description": "Medicamentos, cosméticos y más",
  "latitude": -4.067,
  "longitude": -78.951
}
```

**Respuesta esperada (201):**
```json
{
  "id": "uuid",
  "name": "Farmacia Central",
  "merchantId": "uuid",
  "isActive": true,
  "ratingAvg": "0.00",
  "ratingCount": 0,
  "category": { "id": "...", "name": "Farmacias" }
}
```

✅ Guarda `id` en `STORE_ID`.

---

### 6.2 Listar tiendas (público)

**`GET /stores`**  
*(Sin auth)*

**Respuesta esperada (200):**
```json
{
  "stores": [
    {
      "id": "uuid",
      "name": "Farmacia Central",
      "ratingAvg": "0.00",
      "category": { "name": "Farmacias" },
      "merchant": { "businessName": "Farmacia Central Zamora", "isVerified": true }
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 10
}
```

---

### 6.3 Buscar tiendas por nombre

**`GET /stores?search=farmacia`**

**Respuesta esperada (200):** solo tiendas cuyo nombre/descripción contienen "farmacia" (case-insensitive).

---

### 6.4 Filtrar por categoría

**`GET /stores?categoryId={{CATEGORY_ID}}`**

**Respuesta esperada (200):** solo tiendas de esa categoría.

---

### 6.5 Ver mis tiendas (MERCHANT)

**`GET /stores/mine`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

**Respuesta esperada (200):** array con las tiendas del merchant.

---

### 6.6 Actualizar tienda

**`PATCH /stores/{{STORE_ID}}`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{
  "description": "Medicamentos, cosméticos, perfumería y cuidado personal"
}
```

**Respuesta esperada (200):** tienda actualizada.

---

## 7. Products

### 7.1 Crear categoría de producto

**`POST /stores/{{STORE_ID}}/product-categories`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{
  "name": "Analgésicos",
  "sortOrder": 1
}
```

**Respuesta esperada (201):**
```json
{
  "id": "uuid",
  "name": "Analgésicos",
  "storeId": "...",
  "sortOrder": 1,
  "isActive": true
}
```

✅ Guarda `id` en `PRODUCT_CAT_ID`.

Crea otra:
```json
{ "name": "Vitaminas", "sortOrder": 2 }
```

---

### 7.2 Listar categorías de producto (público)

**`GET /stores/{{STORE_ID}}/product-categories`**

**Respuesta esperada (200):** array de categorías de producto de esa tienda.

---

### 7.3 Crear productos

**`POST /stores/{{STORE_ID}}/products`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{
  "name": "Paracetamol 500mg x 10",
  "description": "Analgésico y antipirético",
  "price": 1.25,
  "productCategoryId": "{{PRODUCT_CAT_ID}}",
  "sortOrder": 1
}
```

**Respuesta esperada (201):**
```json
{
  "id": "uuid",
  "name": "Paracetamol 500mg x 10",
  "price": "1.25",
  "isAvailable": true,
  "isActive": true,
  "productCategory": { "id": "...", "name": "Analgésicos" }
}
```

✅ Guarda `id` en `PRODUCT_ID`.

Crea 2-3 productos más (los necesitas para el pedido):

```json
{
  "name": "Ibuprofeno 400mg x 10",
  "price": 1.50,
  "productCategoryId": "{{PRODUCT_CAT_ID}}"
}
```

```json
{
  "name": "Vitamina C 1g x 10",
  "price": 3.00,
  "productCategoryId": "<ID de la categoría Vitaminas>"
}
```

---

### 7.4 Listar productos (público)

**`GET /stores/{{STORE_ID}}/products`**

**Respuesta esperada (200):**
```json
{
  "products": [...],
  "total": 3,
  "page": 1,
  "limit": 10
}
```

---

### 7.5 Filtrar por categoría de producto

**`GET /stores/{{STORE_ID}}/products?productCategoryId={{PRODUCT_CAT_ID}}`**

**Respuesta esperada (200):** solo los productos de "Analgésicos".

---

### 7.6 Buscar producto por nombre

**`GET /stores/{{STORE_ID}}/products?search=paracetamol`**

**Respuesta esperada (200):** solo Paracetamol.

---

### 7.7 Marcar producto sin stock

**`PATCH /stores/{{STORE_ID}}/products/{{PRODUCT_ID}}`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{
  "isAvailable": false
}
```

**Respuesta esperada (200):** producto con `isAvailable: false`.

Devuélvelo a stock:
```json
{ "isAvailable": true }
```

---

### 7.8 Intentar crear producto con categoría de otra tienda (debe fallar)

Si tienes otra tienda con otra categoría, intenta asignarla a un producto de `STORE_ID`.  
**Respuesta esperada (404):** `Product category not found in this store`

---

## 8. Catalog

### 8.1 Home screen (público)

**`GET /catalog`**  
*(Sin auth)*

**Respuesta esperada (200):**
```json
{
  "categories": [
    { "id": "...", "name": "Farmacias", "slug": "farmacias", "iconUrl": "..." },
    { "id": "...", "name": "Restaurantes", ... }
  ],
  "featuredStores": [
    {
      "id": "...",
      "name": "Farmacia Central",
      "ratingAvg": "0.00",
      "ratingCount": 0,
      "category": { "name": "Farmacias" }
    }
  ]
}
```

---

### 8.2 Búsqueda global

**`GET /catalog/search?q=farmacia`**

**Respuesta esperada (200):**
```json
{
  "query": "farmacia",
  "stores": [...],
  "products": [...],
  "page": 1,
  "limit": 10
}
```

---

### 8.3 Búsqueda por producto

**`GET /catalog/search?q=paracetamol`**

**Respuesta esperada (200):**
```json
{
  "query": "paracetamol",
  "stores": [],
  "products": [
    {
      "id": "...",
      "name": "Paracetamol 500mg x 10",
      "price": "1.25",
      "store": { "id": "...", "name": "Farmacia Central" }
    }
  ]
}
```

---

### 8.4 Tiendas por categoría

**`GET /catalog/categories/{{CATEGORY_ID}}/stores`**

**Respuesta esperada (200):**
```json
{
  "stores": [...],
  "total": 1,
  "page": 1,
  "limit": 20
}
```

---

### 8.5 Búsqueda vacía (debe devolver vacío, no todo el catálogo)

**`GET /catalog/search?q=`**

**Respuesta esperada (200):**
```json
{
  "query": "",
  "stores": [],
  "products": [],
  "page": 1,
  "limit": 10
}
```

---

## 9. Clients

### 9.1 Crear perfil de cliente

**`POST /clients/profile`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{
  "name": "Juan Pérez"
}
```

**Respuesta esperada (201):**
```json
{
  "userId": "uuid",
  "name": "Juan Pérez",
  "avatarUrl": null
}
```

✅ Guarda `userId` en `CLIENT_USER_ID`.

---

### 9.2 Ver mi perfil

**`GET /clients/me`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):** perfil del cliente.

---

### 9.3 Actualizar perfil

**`PATCH /clients/me`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{
  "name": "Juan Carlos Pérez"
}
```

**Respuesta esperada (200):** perfil actualizado.

---

### 9.4 Listar clientes (ADMIN)

**`GET /clients`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):** lista paginada de clientes.

---

## 10. Promotions

### 10.1 Crear promoción para la tienda (MERCHANT)

**`POST /promotions`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{
  "code": "PROMO10",
  "name": "10% de descuento",
  "discountType": "PERCENTAGE",
  "discountValue": 10,
  "storeId": "{{STORE_ID}}",
  "minOrderAmount": 3.00,
  "maxUses": 50,
  "expiresAt": "2027-12-31T23:59:59Z"
}
```

**Respuesta esperada (201):**
```json
{
  "id": "uuid",
  "code": "PROMO10",
  "discountType": "PERCENTAGE",
  "discountValue": "10.00",
  "isActive": true,
  "usedCount": 0
}
```

✅ Guarda `id` en `PROMO_ID`.

---

### 10.2 Crear promoción de monto fijo (ADMIN — global)

**`POST /promotions`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

```json
{
  "code": "BIENVENIDO1",
  "name": "$1 de descuento bienvenida",
  "discountType": "FIXED",
  "discountValue": 1.00
}
```

*(Sin storeId = válida en cualquier tienda)*

**Respuesta esperada (201):** promoción global creada.

---

### 10.3 Intentar crear código duplicado (debe fallar)

**`POST /promotions`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

```json
{
  "code": "PROMO10",
  "name": "Duplicado",
  "discountType": "FIXED",
  "discountValue": 1
}
```

**Respuesta esperada (409):** `Promo code already exists`

---

### 10.4 Validar promo antes de pedir (CLIENT)

**`POST /promotions/validate`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{
  "code": "PROMO10",
  "storeId": "{{STORE_ID}}",
  "orderAmount": 5.00
}
```

**Respuesta esperada (200):**
```json
{
  "promotionId": "uuid",
  "discountAmount": 0.50,
  "finalAmount": 4.50
}
```

---

### 10.5 Validar promo con monto insuficiente (debe fallar)

```json
{
  "code": "PROMO10",
  "storeId": "{{STORE_ID}}",
  "orderAmount": 2.00
}
```

**Respuesta esperada (400):** `Minimum order amount is $3 for this promo`

---

### 10.6 Listar mis promos (MERCHANT)

**`GET /promotions`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

**Respuesta esperada (200):** solo las promos de las tiendas del merchant.

---

## 11. Orders — Flujo completo de pedido

Este es el módulo más importante. Seguimos el flujo completo de un pedido de inicio a fin.

### 11.1 Crear pedido (CLIENT) — sin promo

**`POST /orders`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{
  "storeId": "{{STORE_ID}}",
  "deliveryAddress": "Calle Bolívar 123, Zamora",
  "notes": "Sin cebolla por favor",
  "items": [
    { "productId": "{{PRODUCT_ID}}", "quantity": 2 },
    { "productId": "<ID del Ibuprofeno>", "quantity": 1 }
  ]
}
```

**Respuesta esperada (201):**
```json
{
  "id": "uuid",
  "status": "PENDING",
  "originalAmount": "4.00",
  "discountAmount": "0.00",
  "totalAmount": "4.00",
  "promoCode": null,
  "deliveryAddress": "Calle Bolívar 123, Zamora",
  "notes": "Sin cebolla por favor",
  "items": [
    {
      "productId": "...",
      "quantity": 2,
      "unitPrice": "1.25",
      "subtotal": "2.50",
      "product": { "name": "Paracetamol 500mg x 10" }
    },
    {
      "productId": "...",
      "quantity": 1,
      "unitPrice": "1.50",
      "subtotal": "1.50",
      "product": { "name": "Ibuprofeno 400mg x 10" }
    }
  ],
  "store": { "name": "Farmacia Central" }
}
```

✅ Guarda `id` en `ORDER_ID`.

---

### 11.2 Crear pedido con promo aplicada

**`POST /orders`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{
  "storeId": "{{STORE_ID}}",
  "deliveryAddress": "Av. Amazonas 45",
  "items": [
    { "productId": "{{PRODUCT_ID}}", "quantity": 4 }
  ],
  "promoCode": "PROMO10"
}
```

**Respuesta esperada (201):**
```json
{
  "status": "PENDING",
  "originalAmount": "5.00",
  "discountAmount": "0.50",
  "totalAmount": "4.50",
  "promoCode": "PROMO10"
}
```

---

### 11.3 Intentar pedido sin items (debe fallar)

```json
{
  "storeId": "{{STORE_ID}}",
  "deliveryAddress": "Calle X",
  "items": []
}
```

**Respuesta esperada (400):** `items must contain at least 1 elements`

---

### 11.4 Intentar pedido a tienda no verificada

Si creas un merchant SIN verificar y le creas una tienda, al intentar pedir:  
**Respuesta esperada (400):** `This store is not yet verified and cannot accept orders`

---

### 11.5 Ver mis pedidos (CLIENT)

**`GET /orders`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):**
```json
{
  "orders": [...],
  "total": 2,
  "page": 1,
  "limit": 10
}
```

---

### 11.6 Ver pedidos de mi tienda (MERCHANT)

**`GET /orders`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

**Respuesta esperada (200):** solo los pedidos de sus tiendas.

---

### 11.7 Ver detalle del pedido

**`GET /orders/{{ORDER_ID}}`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):** pedido completo con items, tienda, driver.

---

### 11.8 MERCHANT confirma el pedido

**`PATCH /orders/{{ORDER_ID}}/status`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{ "status": "CONFIRMED" }
```

**Respuesta esperada (200):** `"status": "CONFIRMED"`

---

### 11.9 MERCHANT: PREPARING

**`PATCH /orders/{{ORDER_ID}}/status`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{ "status": "PREPARING" }
```

**Respuesta esperada (200):** `"status": "PREPARING"`

---

### 11.10 MERCHANT: READY

**`PATCH /orders/{{ORDER_ID}}/status`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

```json
{ "status": "READY" }
```

**Respuesta esperada (200):** `"status": "READY"`

---

### 11.11 Intentar saltar estado (debe fallar)

Intenta ir directo de `PENDING` a `DELIVERED`:

**`PATCH /orders/{{ORDER_ID}}/status`**  
*(Usa el segundo ORDER_ID del pedido con promo)*

```json
{ "status": "DELIVERED" }
```

**Respuesta esperada (400):** `Cannot transition from PENDING to DELIVERED`

---

### 11.12 Intentar que CLIENT confirme (debe fallar)

**`PATCH /orders/{{ORDER_ID}}/status`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{ "status": "CONFIRMED" }
```

**Respuesta esperada (403):** `Role CLIENT cannot set status CONFIRMED`

---

### 11.13 CLIENT cancela su propio pedido PENDING

Usa el segundo pedido (con promo, aún en PENDING):

**`PATCH /orders/<order2-id>/status`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{ "status": "CANCELLED" }
```

**Respuesta esperada (200):** `"status": "CANCELLED"`

---

### 11.14 DRIVER recoge el pedido (READY → PICKED_UP)

Primero registra el perfil del driver (ver sección 12), luego:

**`PATCH /orders/{{ORDER_ID}}/status`**  
Header: `Authorization: Bearer {{DRIVER_TOKEN}}`

```json
{ "status": "PICKED_UP" }
```

**Respuesta esperada (200):**
```json
{
  "status": "PICKED_UP",
  "driverId": "<userId del driver>"
}
```

El `driverId` se asigna automáticamente al driver que ejecuta esta acción.

---

### 11.15 DRIVER entrega el pedido

**`PATCH /orders/{{ORDER_ID}}/status`**  
Header: `Authorization: Bearer {{DRIVER_TOKEN}}`

```json
{ "status": "DELIVERED" }
```

**Respuesta esperada (200):** `"status": "DELIVERED"`

✅ El pedido está completo. Ahora se puede calificar.

---

## 12. Drivers

### 12.1 Crear perfil de driver

**`POST /drivers/profile`**  
Header: `Authorization: Bearer {{DRIVER_TOKEN}}`

```json
{
  "name": "Carlos Rodríguez",
  "cedula": "1190123456",
  "vehicleType": "Moto",
  "plate": "ZAM-001"
}
```

**Respuesta esperada (201):**
```json
{
  "userId": "uuid",
  "name": "Carlos Rodríguez",
  "cedula": "1190123456",
  "vehicleType": "Moto",
  "plate": "ZAM-001",
  "ratingAvg": "5.00",
  "ratingCount": 0,
  "isAvailable": false
}
```

✅ Guarda `userId` en `DRIVER_USER_ID`.

---

### 12.2 Ver mi perfil (DRIVER)

**`GET /drivers/me`**  
Header: `Authorization: Bearer {{DRIVER_TOKEN}}`

**Respuesta esperada (200):** perfil completo.

---

### 12.3 Activar disponibilidad

**`PATCH /drivers/me/availability`**  
Header: `Authorization: Bearer {{DRIVER_TOKEN}}`

```json
{ "isAvailable": true }
```

**Respuesta esperada (200):**
```json
{
  "userId": "uuid",
  "name": "Carlos Rodríguez",
  "isAvailable": true
}
```

---

### 12.4 Intentar disponibilidad con valor inválido (debe fallar)

```json
{ "isAvailable": "si" }
```

**Respuesta esperada (400):** `isAvailable must be a boolean value`

---

### 12.5 Ver pedidos disponibles para tomar

**`GET /drivers/available-orders`**  
Header: `Authorization: Bearer {{DRIVER_TOKEN}}`

**Respuesta esperada (200):** pedidos en estado `READY` sin driver asignado.

```json
{
  "orders": [
    {
      "id": "uuid",
      "status": "READY",
      "totalAmount": "4.00",
      "deliveryAddress": "Calle Bolívar 123",
      "store": { "name": "Farmacia Central", "address": "..." },
      "items": [{ "quantity": 2, "product": { "name": "Paracetamol..." } }]
    }
  ],
  "total": 1
}
```

---

### 12.6 Listar todos los drivers (ADMIN)

**`GET /drivers`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):** lista paginada de todos los drivers.

---

## 13. Delivery — Tracking de ubicación

*(El pedido debe estar en estado `PICKED_UP` para estos endpoints)*

### 13.1 Driver actualiza ubicación

**`PATCH /delivery/orders/{{ORDER_ID}}/location`**  
Header: `Authorization: Bearer {{DRIVER_TOKEN}}`

```json
{
  "lat": -4.0679,
  "lng": -78.9468
}
```

**Respuesta esperada (200):**
```json
{
  "orderId": "uuid",
  "driverLat": -4.0679,
  "driverLng": -78.9468,
  "locationUpdatedAt": "2026-05-06T..."
}
```

---

### 13.2 Actualizar posición de nuevo (simulando movimiento)

```json
{ "lat": -4.0685, "lng": -78.9472 }
```

---

### 13.3 CLIENT consulta posición del driver

**`GET /delivery/orders/{{ORDER_ID}}/location`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):**
```json
{
  "orderId": "uuid",
  "driverLat": -4.0685,
  "driverLng": -78.9472,
  "locationUpdatedAt": "2026-05-06T..."
}
```

---

### 13.4 Intentar actualizar ubicación sin ser el driver asignado (debe fallar)

Intenta con `CLIENT_TOKEN` en el PATCH location:  
**Respuesta esperada (403):** rol CLIENT no tiene permiso.

---

### 13.5 Intentar actualizar ubicación con pedido en estado incorrecto (debe fallar)

Usa un pedido que esté en `READY` (no `PICKED_UP`):  
**Respuesta esperada (400):** `Order must be in PICKED_UP status`

---

## 14. Ratings — Calificaciones

*(El pedido DEBE estar en `DELIVERED`)*

### 14.1 CLIENT califica la tienda

**`POST /ratings/orders/{{ORDER_ID}}/store`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{
  "rating": 5,
  "comment": "Excelente servicio, llegó en 15 minutos"
}
```

**Respuesta esperada (200):**
```json
{
  "id": "uuid",
  "orderId": "...",
  "storeId": "...",
  "rating": 5,
  "comment": "Excelente servicio, llegó en 15 minutos",
  "createdAt": "..."
}
```

Después de esto, verifica que el rating promedio de la tienda haya cambiado:

**`GET /stores/{{STORE_ID}}`** → `ratingAvg` debe ser `5.00`, `ratingCount: 1`.

---

### 14.2 Intentar calificar dos veces (debe fallar)

Repite exactamente el mismo request del paso anterior.

**Respuesta esperada (409):** `Store already rated for this order`

---

### 14.3 Ver ratings de una tienda (público)

**`GET /ratings/stores/{{STORE_ID}}`**  
*(Sin auth)*

**Respuesta esperada (200):**
```json
{
  "ratings": [
    {
      "id": "uuid",
      "rating": 5,
      "comment": "Excelente servicio...",
      "client": { "clientProfile": { "name": "Juan Carlos Pérez" } }
    }
  ],
  "total": 1,
  "summary": { "ratingAvg": "5.00", "ratingCount": 1 }
}
```

---

### 14.4 CLIENT califica al driver

**`POST /drivers/orders/{{ORDER_ID}}/rate`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

```json
{
  "rating": 4,
  "comment": "Puntual y amable"
}
```

**Respuesta esperada (200):**
```json
{
  "userId": "uuid",
  "name": "Carlos Rodríguez",
  "ratingAvg": 4.50,
  "ratingCount": 1
}
```

*(El promedio empieza en 5.00 por defecto, con 0 ratings. Al agregar el primero de 4: `(5.00 * 0 + 4) / 1 = 4.00`)*  
Corrección: el `ratingCount` inicia en 0 con `ratingAvg = 5.00` como default. Al recibir primer rating: `(5.00 * 0 + 4) / 1 = 4.00`.

---

### 14.5 Intentar calificar driver dos veces (debe fallar)

**Respuesta esperada (400):** `Driver already rated for this order`

---

### 14.6 Intentar calificar con pedido no entregado (debe fallar)

Usa un `ORDER_ID` en estado distinto a `DELIVERED`:  
**Respuesta esperada (400):** `Can only rate after delivery`

---

## 15. Notifications

### 15.1 Ver mis notificaciones (CLIENT)

**`GET /notifications`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):**
```json
{
  "notifications": [
    {
      "id": "uuid",
      "title": "Pedido confirmado",
      "body": "Tu pedido fue confirmado por la tienda",
      "isRead": false,
      "createdAt": "..."
    },
    {
      "id": "uuid",
      "title": "En preparación",
      "isRead": false
    }
    ...
  ],
  "total": 5,
  "unreadCount": 5
}
```

Debes ver una notificación por cada cambio de estado del pedido.

---

### 15.2 Ver notificaciones del MERCHANT

**`GET /notifications`**  
Header: `Authorization: Bearer {{MERCHANT_TOKEN}}`

Debes ver la notificación de "Nuevo pedido recibido".

---

### 15.3 Marcar una notificación como leída

**`PATCH /notifications/<notif-uuid>/read`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):** `{ "isRead": true }`

---

### 15.4 Marcar todas como leídas

**`PATCH /notifications/read-all`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

**Respuesta esperada (200):** `{ "updated": N }`

---

### 15.5 Verificar que todas estén leídas

**`GET /notifications`**  
Header: `Authorization: Bearer {{CLIENT_TOKEN}}`

Todas deben tener `isRead: true` y `unreadCount: 0`.

---

## 16. Admin

### 16.1 Dashboard operacional

**`GET /admin/dashboard`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):**
```json
{
  "pendingOrders": 0,
  "activeDeliveries": 0,
  "todayOrders": 2,
  "todayRevenue": "4.00",
  "unverifiedMerchants": 0,
  "availableDrivers": 1,
  "totalStores": 1
}
```

---

### 16.2 Listar todos los pedidos con filtros

**`GET /admin/orders`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):** todos los pedidos del sistema.

---

### 16.3 Filtrar pedidos por estado

**`GET /admin/orders?status=DELIVERED`**

**Respuesta esperada (200):** solo pedidos entregados.

---

### 16.4 Filtrar pedidos por fecha

**`GET /admin/orders?from=2026-05-01&to=2026-05-31`**

**Respuesta esperada (200):** pedidos del mes de mayo.

---

### 16.5 Filtrar por tienda

**`GET /admin/orders?storeId={{STORE_ID}}`**

**Respuesta esperada (200):** solo pedidos de esa tienda.

---

### 16.6 Ver historial de estados de un pedido

**`GET /admin/orders/{{ORDER_ID}}/history`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):**
```json
[
  {
    "fromStatus": "PENDING",
    "toStatus": "CONFIRMED",
    "changedBy": { "phone": "+593911111111", "role": "MERCHANT" },
    "createdAt": "2026-05-06T14:01:00Z"
  },
  {
    "fromStatus": "CONFIRMED",
    "toStatus": "PREPARING",
    ...
  },
  {
    "fromStatus": "READY",
    "toStatus": "PICKED_UP",
    "changedBy": { "phone": "+593933333333", "role": "DRIVER" },
    ...
  },
  {
    "fromStatus": "PICKED_UP",
    "toStatus": "DELIVERED",
    ...
  }
]
```

---

### 16.7 Forzar cancelación de un pedido

Crea un pedido nuevo que quede en PENDING, luego:

**`PATCH /admin/orders/<nuevo-order-id>/cancel`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):** `"status": "CANCELLED"`

---

### 16.8 Intentar cancelar pedido ya DELIVERED (debe fallar)

**`PATCH /admin/orders/{{ORDER_ID}}/cancel`**  
*(ORDER_ID ya entregado)*

**Respuesta esperada (400):** `Order is already DELIVERED and cannot be cancelled`

---

### 16.9 Reporte de comisiones

**`GET /admin/commissions`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):**
```json
[
  {
    "merchantId": "uuid",
    "businessName": "Farmacia Central Zamora",
    "commissionRate": "0.1200",
    "totalOrders": 1,
    "totalRevenue": 4.00,
    "commissionAmount": 0.48
  }
]
```

*(12% de $4.00 = $0.48)*

---

### 16.10 Reporte de comisiones con fechas

**`GET /admin/commissions?from=2026-05-01&to=2026-05-31`**

**Respuesta esperada (200):** mismos datos filtrados por ese período.

---

### 16.11 Detalle de comisiones de un merchant

**`GET /admin/commissions/{{MERCHANT_USER_ID}}`**

**Respuesta esperada (200):** detalle con lista de pedidos entregados.

---

### 16.12 Cola de merchants pendientes

**`GET /admin/merchants/pending`**

Si todos están verificados: `{ "merchants": [], "total": 0 }`.  
Registra un MERCHANT nuevo sin verificar para verlo aquí.

---

### 16.13 Todas las tiendas (incluyendo inactivas)

**`GET /admin/stores`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):** todas las tiendas con info del merchant y conteo de pedidos/productos.

---

### 16.14 Desactivar tienda

**`PATCH /admin/stores/{{STORE_ID}}/deactivate`**

**Respuesta esperada (200):** `{ "isActive": false }`

Verifica: `GET /catalog` ya no debe mostrar la tienda.

---

### 16.15 Reactivar tienda

**`PATCH /admin/stores/{{STORE_ID}}/activate`**

**Respuesta esperada (200):** `{ "isActive": true }`

---

## 17. Analytics

### 17.1 Resumen global

**`GET /analytics/summary`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):**
```json
{
  "totalUsers": 4,
  "totalOrders": 2,
  "totalStores": 1,
  "totalRevenue": "4.00",
  "pendingOrders": 0
}
```

---

### 17.2 Pedidos por estado

**`GET /analytics/orders/by-status`**

**Respuesta esperada (200):**
```json
[
  { "status": "PENDING", "count": 0 },
  { "status": "CONFIRMED", "count": 0 },
  { "status": "PREPARING", "count": 0 },
  { "status": "READY", "count": 0 },
  { "status": "PICKED_UP", "count": 0 },
  { "status": "DELIVERED", "count": 1 },
  { "status": "CANCELLED", "count": 1 }
]
```

---

### 17.3 Revenue por período

**`GET /analytics/revenue?days=30`**

**Respuesta esperada (200):**
```json
[
  { "date": "2026-05-06", "revenue": 4 }
]
```

---

### 17.4 Top tiendas

**`GET /analytics/stores/top?limit=5`**

**Respuesta esperada (200):**
```json
[
  {
    "id": "uuid",
    "name": "Farmacia Central",
    "ratingAvg": "5.00",
    "ratingCount": 1,
    "_count": { "orders": 2 }
  }
]
```

---

### 17.5 Top drivers

**`GET /analytics/drivers/top?limit=5`**

**Respuesta esperada (200):**
```json
[
  {
    "userId": "uuid",
    "name": "Carlos Rodríguez",
    "ratingAvg": "4.00",
    "ratingCount": 1,
    "_count": { "orders": 1 }
  }
]
```

---

### 17.6 Usuarios por rol

**`GET /analytics/users/by-role`**

**Respuesta esperada (200):**
```json
[
  { "role": "CLIENT", "count": 1 },
  { "role": "MERCHANT", "count": 1 },
  { "role": "DRIVER", "count": 1 },
  { "role": "ADMIN", "count": 1 }
]
```

---

## 18. Users

### 18.1 Listar todos los usuarios

**`GET /users`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

**Respuesta esperada (200):** todos los usuarios con sus perfiles.

---

### 18.2 Filtrar por rol

**`GET /users?role=DRIVER`**

**Respuesta esperada (200):** solo los usuarios DRIVER.

---

### 18.3 Ver un usuario específico

**`GET /users/{{CLIENT_USER_ID}}`**

**Respuesta esperada (200):**
```json
{
  "id": "uuid",
  "phone": "+593922222222",
  "role": "CLIENT",
  "status": "ACTIVE",
  "clientProfile": { "name": "Juan Carlos Pérez" }
}
```

---

### 18.4 Suspender una cuenta

**`PATCH /users/{{CLIENT_USER_ID}}/status`**  
Header: `Authorization: Bearer {{ADMIN_TOKEN}}`

```json
{ "status": "SUSPENDED" }
```

**Respuesta esperada (200):** `{ "status": "SUSPENDED" }`

---

### 18.5 Verificar que el usuario suspendido no puede hacer login

**`POST /auth/login`**
```json
{
  "phone": "+593922222222",
  "password": "Client123!"
}
```

**Respuesta esperada (401):** `Account suspended`

---

### 18.6 Reactivar cuenta

**`PATCH /users/{{CLIENT_USER_ID}}/status`**

```json
{ "status": "ACTIVE" }
```

**Respuesta esperada (200):** `{ "status": "ACTIVE" }`

Verifica: el usuario ahora puede hacer login de nuevo.

---

## 19. Casos de error esperados

Esta sección resume todos los errores que DEBEN ocurrir. Si no ocurren, hay un bug.

| Caso | Endpoint | Error esperado |
|------|----------|----------------|
| Registrar como ADMIN | POST /auth/register | 400 — role must be CLIENT, MERCHANT, or DRIVER |
| Login de usuario suspendido | POST /auth/login | 401 — Account suspended |
| Refresh con token inválido | POST /auth/refresh | 401 — Invalid or expired refresh token |
| Crear orden sin items | POST /orders | 400 — items must contain at least 1 elements |
| Orden a tienda no verificada | POST /orders | 400 — store is not yet verified |
| Transición de estado inválida | PATCH /orders/:id/status | 400 — Cannot transition from X to Y |
| Rol incorrecto en transición | PATCH /orders/:id/status | 403 — Role X cannot set status Y |
| Calificar sin DELIVERED | POST /ratings/orders/:id/store | 400 — Can only rate after delivery |
| Calificar dos veces tienda | POST /ratings/orders/:id/store | 409 — Store already rated |
| Calificar dos veces driver | POST /drivers/orders/:id/rate | 400 — Driver already rated |
| Promo código duplicado | POST /promotions | 409 — Promo code already exists |
| Promo monto insuficiente | POST /promotions/validate | 400 — Minimum order amount is $X |
| Promo de otra tienda | POST /promotions/validate | 400 — Promo code not valid for this store |
| MERCHANT ve promos ajenas | GET /promotions | Solo devuelve las suyas |
| MERCHANT borra promo ajena | DELETE /promotions/:id | 403 — Not your promotion |
| Slug duplicado en categoría | POST/PATCH /categories | 409 — Category with slug already exists |
| Categoría de producto ajena | POST/PATCH /stores/:id/products | 404 — Product category not found in this store |
| Actualizar tienda ajena | PATCH /stores/:id | 403 — You do not own this store |
| Actualizar ubicación sin ser driver | PATCH /delivery/orders/:id/location | 403 — Forbidden |
| Ubicación en estado incorrecto | PATCH /delivery/orders/:id/location | 400 — Order must be in PICKED_UP status |
| Forzar cancel en DELIVERED | PATCH /admin/orders/:id/cancel | 400 — Order is already DELIVERED |
| Endpoint ADMIN con otro rol | Cualquier /admin/* | 403 — Forbidden |

---

## Checklist de pruebas completadas

- [ ] Auth: registro, login, refresh, logout, me
- [ ] Categories: CRUD completo
- [ ] Merchants: perfil, verificación admin
- [ ] Stores: CRUD, búsqueda, filtros
- [ ] Products: categorías, CRUD, stock
- [ ] Catalog: home, search, por categoría
- [ ] Clients: perfil
- [ ] Promotions: crear, validar, aplicar en pedido
- [ ] Orders: flujo completo PENDING → DELIVERED
- [ ] Orders: cancelación por CLIENT
- [ ] Orders: errores de transición
- [ ] Drivers: perfil, disponibilidad, available-orders
- [ ] Delivery: actualizar y consultar ubicación
- [ ] Ratings: tienda + driver, doble calificación bloqueada
- [ ] Notifications: listar, marcar leída, marcar todas
- [ ] Admin: dashboard, órdenes filtradas, historial, cancel forzado
- [ ] Admin: comisiones, merchants pendientes, stores
- [ ] Analytics: todos los endpoints
- [ ] Users: listar, suspender, reactivar
- [ ] Errores esperados: todos los casos de la tabla 19
