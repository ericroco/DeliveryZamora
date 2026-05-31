# 02 — Módulo Merchants

## ¿Qué hicimos?

1. Expandimos `MerchantProfile` en el schema de Prisma (descripción, dirección, teléfono, logo, portada, horarios)
2. Creamos el `RolesGuard` y el decorator `@Roles()` para controlar acceso por rol
3. Construimos el módulo `merchants` completo: crear perfil, editar, listar (admin), verificar, suspender

---

## ¿Por qué estas decisiones?

### RolesGuard separado del JwtAuthGuard

`JwtAuthGuard` resuelve *quién eres* (autenticación).  
`RolesGuard` resuelve *qué puedes hacer* (autorización).

Mantenerlos separados sigue el principio de responsabilidad única. Un guard hace una cosa. Si mañana necesitas lógica de permisos más granular, cambias `RolesGuard` sin tocar `JwtAuthGuard`.

### `@Roles('MERCHANT')` en los endpoints propios, `@Roles('ADMIN')` en los de gestión

El endpoint `POST /merchants/profile` solo lo puede llamar alguien con `role: MERCHANT`. Si un `CLIENT` lo intenta, recibe `403 Forbidden`. El admin tiene acceso de lectura/escritura sobre todos los perfiles para gestión del marketplace.

### `PartialType` para el DTO de actualización

`UpdateMerchantProfileDto extends PartialType(CreateMerchantProfileDto)` genera automáticamente un DTO donde todos los campos son opcionales. Sin código duplicado.

### Paginación en `GET /merchants`

La lista de merchants no es acotada — puede crecer a cientos. Siempre se pagina: `page` y `limit` como query params. Respuesta incluye `total` para que el frontend sepa cuántas páginas hay.

### `openingHours` como JSON

Guardamos los horarios como un objeto JSON flexible:
```json
{
  "monday":    { "open": "08:00", "close": "22:00" },
  "tuesday":   { "open": "08:00", "close": "22:00" },
  "saturday":  { "open": "09:00", "close": "18:00" },
  "sunday":    null
}
```
`null` = cerrado ese día. Esta estructura es suficiente para v1 y no requiere una tabla adicional.

---

## Estructura de archivos creados

```
apps/core-api/src/
├── common/
│   ├── decorators/
│   │   └── roles.decorator.ts       ← @Roles('MERCHANT', 'ADMIN') en los endpoints
│   └── guards/
│       └── roles.guard.ts           ← verifica que el JWT payload tenga el rol requerido
└── modules/
    └── merchants/
        ├── merchants.module.ts
        ├── merchants.service.ts     ← lógica de negocio
        ├── merchants.controller.ts  ← rutas HTTP
        └── dto/
            ├── create-merchant-profile.dto.ts
            └── update-merchant-profile.dto.ts
```

---

## Schema actualizado — campos nuevos en `MerchantProfile`

```prisma
model MerchantProfile {
  // campos anteriores
  userId       String  @id
  businessName String
  tier         Int     @default(1)
  ruc          String?
  commissionRate Decimal @default(0.12)
  isVerified   Boolean @default(false)
  verifiedAt   DateTime?
  createdAt    DateTime @default(now())

  // campos nuevos
  description  String?   // descripción del negocio
  address      String?   // dirección física
  phone        String?   // teléfono del local
  logoUrl      String?   // URL de la imagen del logo
  coverUrl     String?   // URL de la imagen de portada
  openingHours Json?     // horarios de atención
  updatedAt    DateTime  @updatedAt
}
```

---

## Las rutas del módulo

| Método | Ruta | Rol requerido | Para qué |
|--------|------|---------------|---------|
| POST | `/api/v1/merchants/profile` | MERCHANT | Crear perfil de comercio |
| GET | `/api/v1/merchants/me` | MERCHANT | Ver mi perfil |
| PATCH | `/api/v1/merchants/me` | MERCHANT | Actualizar mi perfil |
| GET | `/api/v1/merchants?page=1&limit=20` | ADMIN | Listar todos los comercios |
| GET | `/api/v1/merchants/:userId` | ADMIN | Ver comercio por ID |
| PATCH | `/api/v1/merchants/:userId/verify` | ADMIN | Aprobar/verificar comercio |
| PATCH | `/api/v1/merchants/:userId/suspend` | ADMIN | Suspender cuenta |

---

## Cómo fluye la autorización

```
Cliente envía: POST /api/v1/merchants/profile
Headers: { Authorization: "Bearer eyJhbGci..." }

1. JwtAuthGuard extrae y valida el token → inyecta user en request
2. RolesGuard lee @Roles('MERCHANT') del endpoint
3. Compara user.role === 'MERCHANT' → true ✓
4. MerchantsController ejecuta createProfile()
5. MerchantsService verifica que no exista perfil duplicado → crea en DB
```

Si el usuario tiene `role: CLIENT`:
- Paso 3 falla → `403 Forbidden` sin llegar al servicio

---

## Probar los endpoints

### Registrar un comercio
```bash
# 1. Registrar usuario con role MERCHANT
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"+593991234567","password":"password123","role":"MERCHANT"}'

# Guarda el accessToken de la respuesta
```

### Crear perfil del comercio
```bash
curl -X POST http://localhost:3000/api/v1/merchants/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_ACCESS_TOKEN" \
  -d '{
    "businessName": "Farmacia Central",
    "description": "Farmacia con más de 20 años en Zamora",
    "address": "Av. 24 de Mayo y Diego de Vaca",
    "phone": "+593987654321",
    "openingHours": {
      "monday": { "open": "08:00", "close": "22:00" },
      "sunday": null
    }
  }'
```

### Ver mi perfil
```bash
curl http://localhost:3000/api/v1/merchants/me \
  -H "Authorization: Bearer TU_ACCESS_TOKEN"
```

### Actualizar mi perfil
```bash
curl -X PATCH http://localhost:3000/api/v1/merchants/me \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TU_ACCESS_TOKEN" \
  -d '{"description": "Nueva descripción del negocio"}'
```

O usa **Swagger UI** en `http://localhost:3000/api/docs`.

---

## Nota sobre imágenes (logoUrl / coverUrl)

Por ahora los campos `logoUrl` y `coverUrl` son strings simples — el merchant los setea con `PATCH /merchants/me` enviando una URL.

En una iteración posterior, implementaremos upload real de archivos con S3/Cloudflare R2 + un endpoint `POST /merchants/me/logo` que devuelva la URL pública para guardar en el perfil.

---

## ¿Qué sigue?

**Siguiente paso:** módulo `categories` + `stores` — ver [03-stores.md](./03-stores.md)

Lo que vamos a construir:
1. Modelo `Store` — un merchant puede tener una o más tiendas/locales
2. Modelo `Category` — tipos de comercio (farmacia, restaurante, supermercado...)
3. Relación Store → Category
4. CRUD de stores para el merchant
