# 07 — Clients

## Qué hace

Gestiona los perfiles de clientes. Cuando un usuario se registra con `role: CLIENT`, se crea automáticamente un `ClientProfile` en el mismo request de auth. Este módulo expone endpoints para que el propio cliente edite su perfil y para que ADMIN liste/vea todos los clientes.

## Endpoints

| Método | Ruta | Rol | Descripción |
|--------|------|-----|-------------|
| GET | /clients | ADMIN | Lista todos los clientes |
| GET | /clients/me | CLIENT | Perfil propio |
| PATCH | /clients/me | CLIENT | Actualiza perfil propio |
| GET | /clients/:id | ADMIN | Perfil de un cliente específico |

## Probar con Swagger / curl

### Ver mi perfil (CLIENT)
```bash
curl -H "Authorization: Bearer $TOKEN_CLIENT" \
  http://localhost:3000/clients/me
```

### Actualizar perfil
```bash
curl -X PATCH \
  -H "Authorization: Bearer $TOKEN_CLIENT" \
  -H "Content-Type: application/json" \
  -d '{"phone":"+593999888777","address":"Av. del Ejército 12"}' \
  http://localhost:3000/clients/me
```

### Listar todos (ADMIN)
```bash
curl -H "Authorization: Bearer $TOKEN_ADMIN" \
  http://localhost:3000/clients
```

## Flujo típico

1. Usuario se registra vía `POST /auth/register` con `role: CLIENT`
2. Auth service llama internamente a `ClientsService.createProfile()`
3. Cliente llama `GET /clients/me` para ver su perfil
4. Cliente actualiza con `PATCH /clients/me`

## Campos del perfil

| Campo | Tipo | Descripción |
|-------|------|-------------|
| phone | string? | Teléfono de contacto |
| address | string? | Dirección por defecto |
| avatarUrl | string? | URL de foto de perfil |

## Notas

- El perfil se crea vacío al registrarse; el cliente lo completa después.
- ADMIN puede ver pero no editar perfiles de clientes desde este módulo (edición de estado es vía `/users`).
