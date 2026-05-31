# 12 — Users

## Qué hace

Panel de administración de usuarios. Solo accesible por ADMIN. Permite listar todos los usuarios del sistema con sus perfiles, ver detalle individual, y cambiar el estado de una cuenta (activar, suspender, banear).

## Endpoints

| Método | Ruta | Rol | Descripción |
|--------|------|-----|-------------|
| GET | /users | ADMIN | Listar usuarios (filtrable por rol) |
| GET | /users/:id | ADMIN | Ver detalle de un usuario |
| PATCH | /users/:id/status | ADMIN | Cambiar estado de cuenta |

## Probar con Swagger / curl

### Listar todos los usuarios
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/users
```

### Filtrar por rol
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  "http://localhost:3000/users?role=DRIVER"
```

Roles disponibles: `CLIENT`, `MERCHANT`, `DRIVER`, `ADMIN`

### Ver un usuario específico
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/users/<user-uuid>
```

### Suspender una cuenta
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{"status":"SUSPENDED"}' \
  http://localhost:3000/users/<user-uuid>/status
```

### Reactivar cuenta
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{"status":"ACTIVE"}' \
  http://localhost:3000/users/<user-uuid>/status
```

## Estados de cuenta

| Status | Descripción |
|--------|-------------|
| ACTIVE | Usuario activo, puede usar la app |
| SUSPENDED | Suspendido temporalmente, no puede iniciar sesión |
| BANNED | Baneado permanentemente |

## Respuesta enriquecida por rol

Cuando se lista o se consulta un usuario, la respuesta incluye el perfil correspondiente:

- `role: CLIENT` → incluye `ClientProfile` (teléfono, dirección)
- `role: MERCHANT` → incluye `MerchantProfile` (businessName, taxId)
- `role: DRIVER` → incluye `DriverProfile` (vehicle, licenseNumber, ratingAvg)
- `role: ADMIN` → sin perfil adicional

## Notas

- ADMIN no puede cambiar el rol de un usuario desde este módulo (requeriría migración de perfil).
- El cambio de estado de `ACTIVE` a `SUSPENDED` no invalida los refresh tokens existentes (backlog: invalidar tokens al suspender).
- Para gestión de perfil propio, los usuarios usan `/clients/me`, `/merchants/me`, `/drivers/me`.
