# Backend — Referencia Completa

> Core API · NestJS · Base URL: `http://localhost:3000/api/v1`  
> Swagger: `http://localhost:3000/api/docs`  
> Para levantar: `cd apps/core-api && npx nest start --watch`

---

## Índice de módulos

| Módulo | Prefijo | Autenticación | Estado |
|--------|---------|---------------|--------|
| [auth](#auth) | `/auth` | Pública + JWT | ✅ Completo |
| [catalog](#catalog) | `/catalog` | Pública | ✅ Completo |
| [categories](#categories) | `/categories` | Pública (lectura) | ✅ Completo |
| [stores](#stores) | `/stores` | Mixta | ✅ Completo |
| [products](#products) | `/stores/:storeId/products` | Mixta | ✅ Completo |
| [clients](#clients) | `/clients` | JWT | ✅ Completo |
| [merchants](#merchants) | `/merchants` | JWT | ✅ Completo |
| [promotions](#promotions) | `/promotions` | JWT | ✅ Completo |
| [orders](#orders) | `/orders` | JWT | ✅ Completo |
| [ratings](#ratings) | `/ratings` | JWT | ✅ Completo |
| [drivers](#drivers) | `/drivers` | JWT | ✅ Completo |
| [delivery](#delivery) | `/delivery` | JWT | ✅ Completo |
| [notifications](#notifications) | `/notifications` | JWT | ✅ Completo |
| [users](#users) | `/users` | JWT · ADMIN | ✅ Completo |
| [analytics](#analytics) | `/analytics` | JWT · ADMIN | ✅ Completo |

---

## Flujo de registro por rol

```
CLIENT:   POST /auth/register → POST /clients/profile
MERCHANT: POST /auth/register → POST /merchants/profile → [ADMIN verifica]
DRIVER:   POST /auth/register → POST /drivers/profile
ADMIN:    Solo se crea directo en DB (seed)
```

---

## auth

### ¿Qué hace?
Registro, login JWT (access 15min + refresh 30d), logout, ver usuario actual.

### Endpoints

| Método | Ruta | Auth | Body / Notas |
|--------|------|------|--------------|
| POST | `/auth/register` | No | `phone, password, role, email?` |
| POST | `/auth/login` | No | `phone, password` |
| POST | `/auth/refresh` | No | `refreshToken` |
| POST | `/auth/logout` | JWT | Invalida el refresh token |
| GET | `/auth/me` | JWT | Retorna usuario + perfil según rol |

### Probar
```bash
# 1. Registrar CLIENT
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"0991234567","password":"secret123","role":"CLIENT"}'

# 2. Login → guarda accessToken
curl -X POST http://localhost:3000/api/v1/auth/login \
  -d '{"phone":"0991234567","password":"secret123"}'
```

---

## catalog

### ¿Qué hace?
Pantalla principal de la app (home screen público). Categorías + tiendas destacadas. Búsqueda global de tiendas y productos.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| GET | `/catalog` | No | Home: categorías + 10 tiendas con mejor rating |
| GET | `/catalog/search?q=` | No | Busca tiendas y productos por texto |
| GET | `/catalog/categories/:id/stores` | No | Tiendas de una categoría con paginación |

### Probar
```bash
# Home screen
curl http://localhost:3000/api/v1/catalog

# Buscar "farmacia"
curl "http://localhost:3000/api/v1/catalog/search?q=farmacia"

# Ver tiendas de una categoría
curl "http://localhost:3000/api/v1/catalog/categories/CATEGORY_ID/stores"
```

---

## categories

### ¿Qué hace?
Tipos de negocio del sistema (Farmacia, Restaurante, Tienda, etc.). Los administra solo ADMIN. Los clientes y merchants solo leen.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| GET | `/categories` | No | Lista activas |
| POST | `/categories` | ADMIN | `name, slug, iconUrl?` |
| PATCH | `/categories/:id` | ADMIN | Actualizar |
| DELETE | `/categories/:id` | ADMIN | Desactivar (soft delete) |

### Probar
```bash
# Crear categoría
curl -X POST http://localhost:3000/api/v1/categories \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{"name":"Farmacia","slug":"farmacia","iconUrl":"https://..."}'
```

---

## stores

### ¿Qué hace?
Tiendas / locales registrados. Cada tienda pertenece a un MERCHANT. Los clientes las ven públicamente.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| GET | `/stores` | No | Lista con filtros: `categoryId`, `search`, `page`, `limit` |
| GET | `/stores/:id` | No | Detalle de tienda |
| GET | `/stores/mine` | MERCHANT | Mis tiendas |
| POST | `/stores` | MERCHANT | `name, categoryId, address, ...` |
| PATCH | `/stores/:id` | MERCHANT/ADMIN | Actualizar |
| DELETE | `/stores/:id` | MERCHANT/ADMIN | Desactivar |

### Probar
```bash
# Listar tiendas con búsqueda
curl "http://localhost:3000/api/v1/stores?search=farmacia&categoryId=ID"

# Crear tienda (MERCHANT)
curl -X POST http://localhost:3000/api/v1/stores \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"name":"Farmacia Central","categoryId":"ID","address":"Calle Bolívar 123, Zamora"}'
```

---

## products

### ¿Qué hace?
Catálogo de productos por tienda. Incluye categorías de producto propias de cada tienda (ej. "Analgésicos" dentro de Farmacia Central).

### Endpoints — Categorías de producto

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| GET | `/stores/:storeId/product-categories` | No | Lista categorías de la tienda |
| POST | `/stores/:storeId/product-categories` | MERCHANT/ADMIN | `name, sortOrder?` |
| PATCH | `/stores/:storeId/product-categories/:id` | MERCHANT/ADMIN | |
| DELETE | `/stores/:storeId/product-categories/:id` | MERCHANT/ADMIN | |

### Endpoints — Productos

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| GET | `/stores/:storeId/products` | No | Filtros: `productCategoryId`, `search`, `page`, `limit` |
| GET | `/stores/:storeId/products/:id` | No | Detalle |
| POST | `/stores/:storeId/products` | MERCHANT/ADMIN | `name, price, description?, imageUrl?, productCategoryId?` |
| PATCH | `/stores/:storeId/products/:id` | MERCHANT/ADMIN | Incluye `isAvailable` para toggle stock |
| DELETE | `/stores/:storeId/products/:id` | MERCHANT/ADMIN | Desactivar |

### Probar
```bash
# Crear producto
curl -X POST http://localhost:3000/api/v1/stores/STORE_ID/products \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"name":"Paracetamol 500mg","price":1.25,"productCategoryId":"CAT_ID"}'

# Marcar sin stock
curl -X PATCH http://localhost:3000/api/v1/stores/STORE_ID/products/PRODUCT_ID \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"isAvailable":false}'
```

---

## clients

### ¿Qué hace?
Gestión del perfil de usuario CLIENT (nombre, avatar). Los datos de autenticación viven en `users`.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| POST | `/clients/profile` | CLIENT | `name, avatarUrl?` — crear una sola vez |
| GET | `/clients/me` | CLIENT | Ver mi perfil |
| PATCH | `/clients/me` | CLIENT | Actualizar nombre / avatar |
| GET | `/clients` | ADMIN | Lista todos los clientes |
| PATCH | `/clients/:userId/suspend` | ADMIN | Suspender cuenta |

---

## merchants

### ¿Qué hace?
Gestión del perfil de negocio del MERCHANT. Los admins verifican merchants antes de que puedan operar.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| POST | `/merchants/profile` | MERCHANT | `businessName, description?, address?, phone?, ruc?` |
| GET | `/merchants/me` | MERCHANT | Ver mi perfil |
| PATCH | `/merchants/me` | MERCHANT | Actualizar |
| GET | `/merchants` | ADMIN | Lista todos |
| GET | `/merchants/:userId` | ADMIN | Ver uno |
| PATCH | `/merchants/:userId/verify` | ADMIN | Verificar/aprobar merchant |
| PATCH | `/merchants/:userId/suspend` | ADMIN | Suspender |

### Notas importantes
- Un merchant NO verificado puede crear tiendas pero esto se puede agregar como restricción en Sprint 2.
- `commissionRate` solo se puede cambiar directo en DB (o desde endpoint admin futuro).

---

## promotions

### ¿Qué hace?
Códigos de descuento. ADMIN crea promos globales. MERCHANT crea promos para sus tiendas. CLIENT valida antes de hacer el pedido o lo incluye directamente en el body del pedido.

### Tipos de descuento
- `PERCENTAGE` — `discountValue = 10` → 10% del total
- `FIXED` — `discountValue = 2.00` → $2.00 fijos

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| POST | `/promotions` | ADMIN/MERCHANT | `code, name, discountType, discountValue, minOrderAmount?, maxUses?, expiresAt?, storeId?` |
| POST | `/promotions/validate` | CLIENT | `code, storeId, orderAmount` — previsualizar descuento |
| GET | `/promotions` | ADMIN/MERCHANT | Lista |
| DELETE | `/promotions/:id` | ADMIN/MERCHANT | Desactivar |

### Probar
```bash
# Crear promo global (ADMIN)
curl -X POST http://localhost:3000/api/v1/promotions \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -d '{"code":"BIENVENIDO10","name":"Descuento bienvenida","discountType":"PERCENTAGE","discountValue":10}'

# Validar antes de pedir (CLIENT)
curl -X POST http://localhost:3000/api/v1/promotions/validate \
  -H "Authorization: Bearer CLIENT_TOKEN" \
  -d '{"code":"BIENVENIDO10","storeId":"STORE_ID","orderAmount":15.50}'

# Usar en el pedido (incluir promoCode en create-order)
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer CLIENT_TOKEN" \
  -d '{"storeId":"...","deliveryAddress":"...","promoCode":"BIENVENIDO10","items":[...]}'
```

---

## orders

### ¿Qué hace?
El corazón del sistema. El CLIENT crea pedidos, el MERCHANT los confirma y prepara, el DRIVER los entrega. Máquina de estados estricta con transiciones validadas por rol.

### Máquina de estados

```
PENDING ──→ CONFIRMED ──→ PREPARING ──→ READY ──→ PICKED_UP ──→ DELIVERED
   │              │                                                
   └──CANCELLED   └──CANCELLED                                    
```

| Transición | Quién puede |
|-----------|-------------|
| PENDING → CONFIRMED | MERCHANT, ADMIN |
| PENDING → CANCELLED | MERCHANT, ADMIN, **CLIENT** |
| CONFIRMED → PREPARING | MERCHANT, ADMIN |
| CONFIRMED → CANCELLED | MERCHANT, ADMIN |
| PREPARING → READY | MERCHANT, ADMIN |
| READY → PICKED_UP | DRIVER, ADMIN |
| PICKED_UP → DELIVERED | DRIVER, ADMIN |

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| POST | `/orders` | CLIENT | Crear pedido |
| GET | `/orders` | JWT | CLIENT ve los suyos · MERCHANT ve sus tiendas · DRIVER ve los asignados · ADMIN ve todos |
| GET | `/orders/:id` | JWT | Ver detalle |
| PATCH | `/orders/:id/status` | JWT | `{ "status": "CONFIRMED" }` |

### Probar flujo completo
```bash
# 1. CLIENT crea pedido
curl -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer CLIENT_TOKEN" \
  -d '{"storeId":"ID","deliveryAddress":"Calle Bolivar 123","items":[{"productId":"ID","quantity":2}]}'

# 2. MERCHANT confirma
curl -X PATCH http://localhost:3000/api/v1/orders/ORDER_ID/status \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"status":"CONFIRMED"}'

# 3. MERCHANT: PREPARING → READY
curl -X PATCH http://localhost:3000/api/v1/orders/ORDER_ID/status \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"status":"PREPARING"}'

curl -X PATCH http://localhost:3000/api/v1/orders/ORDER_ID/status \
  -H "Authorization: Bearer MERCHANT_TOKEN" \
  -d '{"status":"READY"}'

# 4. DRIVER recoge → se asigna driverId automáticamente
curl -X PATCH http://localhost:3000/api/v1/orders/ORDER_ID/status \
  -H "Authorization: Bearer DRIVER_TOKEN" \
  -d '{"status":"PICKED_UP"}'

# 5. DRIVER entrega
curl -X PATCH http://localhost:3000/api/v1/orders/ORDER_ID/status \
  -H "Authorization: Bearer DRIVER_TOKEN" \
  -d '{"status":"DELIVERED"}'
```

---

## ratings

### ¿Qué hace?
Calificaciones de tiendas (1–5 estrellas). Una calificación por pedido por CLIENT. Las calificaciones de drivers están en el módulo `drivers`.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| POST | `/ratings/orders/:orderId/store` | CLIENT | `rating (1-5), comment?` — solo post-DELIVERED, una vez |
| GET | `/ratings/stores/:storeId` | No | Lista de ratings con promedio |

### Probar
```bash
# Calificar tienda después de entrega
curl -X POST http://localhost:3000/api/v1/ratings/orders/ORDER_ID/store \
  -H "Authorization: Bearer CLIENT_TOKEN" \
  -d '{"rating":5,"comment":"Excelente servicio"}'

# Ver ratings de una tienda
curl http://localhost:3000/api/v1/ratings/stores/STORE_ID
```

---

## drivers

### ¿Qué hace?
Perfil del repartidor, disponibilidad, lista de pedidos disponibles para tomar (READY sin driver asignado), y calificación post-entrega.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| POST | `/drivers/profile` | DRIVER | `name, cedula, vehicleType, plate` |
| GET | `/drivers/me` | DRIVER | Ver mi perfil |
| PATCH | `/drivers/me` | DRIVER | Actualizar datos |
| PATCH | `/drivers/me/availability` | DRIVER | `{"isAvailable":true}` |
| GET | `/drivers/available-orders` | DRIVER | Pedidos READY sin driver (paginado) |
| POST | `/drivers/orders/:orderId/rate` | CLIENT | `rating (1-5)` — solo post-DELIVERED, una vez |
| GET | `/drivers` | ADMIN | Lista todos los drivers |
| GET | `/drivers/:userId` | ADMIN | Ver driver |
| PATCH | `/drivers/:userId/suspend` | ADMIN | Suspender |

---

## delivery

### ¿Qué hace?
Actualización y consulta de ubicación GPS del driver durante un pedido activo (estado PICKED_UP). Es la versión básica del tracking — el sistema real-time via Socket.io + TimescaleDB es el tracking-service (sprint futuro).

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| PATCH | `/delivery/orders/:orderId/location` | DRIVER | `{"lat":-4.0679,"lng":-78.9468}` |
| GET | `/delivery/orders/:orderId/location` | JWT | CLIENT/MERCHANT/DRIVER/ADMIN |

### Limitaciones actuales
- Polling manual (GET cada X segundos). No hay WebSocket push.
- Solo guarda última posición conocida, no historial.

---

## notifications

### ¿Qué hace?
Notificaciones en base de datos generadas automáticamente en cada cambio de estado de pedido. El cliente hace polling o las consulta bajo demanda. FCM (push real) es sprint futuro.

### Cuándo se generan

| Evento | Notificado |
|--------|-----------|
| Pedido creado (PENDING) | MERCHANT — nuevo pedido |
| CONFIRMED | CLIENT |
| PREPARING | CLIENT |
| READY | CLIENT |
| PICKED_UP | CLIENT |
| DELIVERED | CLIENT — con prompt de calificación |
| CANCELLED | CLIENT o MERCHANT según contexto |

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| GET | `/notifications` | JWT | `page, limit` — con `unreadCount` en respuesta |
| PATCH | `/notifications/:id/read` | JWT | Marcar una como leída |
| PATCH | `/notifications/read-all` | JWT | Marcar todas como leídas |

---

## users

### ¿Qué hace?
Gestión centralizada de usuarios para ADMIN. Lista, filtra por rol, cambia status.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| GET | `/users` | ADMIN | `page, limit, role?` |
| GET | `/users/:id` | ADMIN | Con perfil según rol |
| PATCH | `/users/:id/status` | ADMIN | `{"status":"ACTIVE\|SUSPENDED\|PENDING_VERIFICATION"}` |

---

## analytics

### ¿Qué hace?
Estadísticas del sistema para el panel admin. Sin estado, calculados en tiempo real desde la DB.

### Endpoints

| Método | Ruta | Auth | Notas |
|--------|------|------|-------|
| GET | `/analytics/summary` | ADMIN | Total users, orders, stores, revenue, pedidos pendientes |
| GET | `/analytics/orders/by-status` | ADMIN | Conteo por cada estado |
| GET | `/analytics/revenue?days=30` | ADMIN | Revenue por día (últimos N días) |
| GET | `/analytics/stores/top?limit=10` | ADMIN | Top tiendas por pedidos |
| GET | `/analytics/drivers/top?limit=10` | ADMIN | Top drivers por rating |
| GET | `/analytics/users/by-role` | ADMIN | Conteo de usuarios por rol |

---

## Pendientes — Backlog por prioridad

### P1 — Crítico para operación comercial

**Pagos con Kushki**
- Integrar SDK de Kushki para cobros con tarjeta y transferencia
- Flujo: `POST /payments/intent` → confirmar → webhook de Kushki
- Guardar `PaymentIntent` en DB con estado (PENDING, PAID, FAILED, REFUNDED)
- Ligar pago a Order: orden solo se confirma si pago fue exitoso
- Reembolsos en cancelaciones post-pago
- Liquidaciones a merchants (T+1, después de comisión)

**Verificación de teléfono por OTP (WhatsApp / SMS)**
- Integrar Twilio o Meta Cloud API
- Al registrar, enviar OTP al número de teléfono
- `POST /auth/verify-phone` — activar cuenta
- Mientras status = `PENDING_VERIFICATION`, bloquear acceso a recursos protegidos

**Restricción: merchant no verificado no puede recibir pedidos**
- En `orders.service.ts` → validar `store.merchant.isVerified` al crear pedido

### P2 — Mejora de experiencia

**Push notifications reales (FCM)**
- Guardar `fcmToken` en `User` o `UserDevice`
- En `NotificationsService.createMany()`, disparar FCM además de guardar en DB
- Soporte multi-device

**tracking-service (real-time)**
- Servicio separado: NestJS + Socket.io + TimescaleDB
- Driver emite posición cada 5s
- Cliente recibe updates vía WebSocket sin polling
- Historial de trayectoria por pedido

**Imágenes con Cloudinary**
- Subir logos, covers, imágenes de producto
- `POST /uploads/image` → retorna URL
- Reemplaza las URLs hardcodeadas actuales

**Horarios de atención con validación**
- `openingHours` ya existe en DB como JSON
- Falta: endpoint que valide si una tienda está abierta ahora
- Falta: bloquear crear pedidos en tiendas cerradas

### P3 — Admin y operación

**Panel de operaciones admin**
- Reporte de comisiones por período
- Exportar pedidos en CSV
- Gestión de disputas

**Merchant: restricción de crear tiendas sin verificación**
- Actualmente cualquier MERCHANT puede crear tiendas
- Bloquear hasta que `isVerified = true`

**Historial de cambios de estado de pedido**
- Modelo `OrderStatusHistory { orderId, fromStatus, toStatus, changedById, createdAt }`
- Para auditoría y disputas

**Password reset**
- `POST /auth/forgot-password` → OTP al teléfono
- `POST /auth/reset-password` → con OTP + nueva contraseña

### P4 — Crecimiento

**Promotions: límite por usuario**
- Actualmente un usuario puede usar el mismo código ilimitadas veces
- Agregar validación: `WHERE promotionId = X AND userId = Y` en PromoUsage

**Búsqueda geográfica**
- Stores con PostGIS: `ORDER BY ST_Distance(point, userLocation)`
- Requiere que usuarios compartan ubicación

**Sistema de referidos**
- Código de referido por usuario
- Crédito en cuenta al primer pedido del referido

**Multi-idioma**
- Soporte ES/EN en mensajes de notificaciones y errores
