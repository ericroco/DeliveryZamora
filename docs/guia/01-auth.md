# 01 — Módulo Auth + Prisma + Base de Datos

## ¿Qué hicimos?

1. Scaffoldeamos NestJS con el CLI oficial
2. Configuramos Prisma (ORM) con el schema de usuarios
3. Corrimos la primera migración (creó las tablas en PostgreSQL)
4. Construimos el módulo `auth` completo: register, login, refresh, logout, me

---

## ¿Por qué estas decisiones?

### NestJS
Framework de Node.js con arquitectura muy similar a Angular: módulos, controladores, servicios, inyección de dependencias.

**Por qué no Express puro:** NestJS te da estructura desde el día 1. En Express terminas inventando tu propia arquitectura; en NestJS ya viene definida. Para un proyecto con 10+ módulos (auth, orders, payments, tracking...), la estructura importa.

### Prisma (v5) como ORM
Prisma genera un cliente TypeScript a partir de tu schema. En vez de escribir SQL crudo, escribes:
```typescript
prisma.user.findUnique({ where: { phone: '+593...' } })
```
Y Prisma genera el SQL correcto + te da autocompletado en el editor.

**Por qué no Prisma 7 (la versión más nueva):** Prisma 7 cambió completamente la API — el `url` en el schema ya no funciona, requiere un archivo de configuración nuevo llamado `prisma.config.ts`. Es una migración grande. Usamos v5 que es estable y documentada.

### JWT con access + refresh tokens
- **Access token (15 min):** token corto que el cliente manda en cada request. Si se filtra, expira rápido.
- **Refresh token (30 días):** token largo guardado en DB. Se usa solo para obtener un nuevo access token. Si el usuario "cierra sesión", borramos el refresh token de DB y el acceso queda revocado.

### bcrypt para contraseñas
`bcrypt` aplica hashing con "salt" (valor aleatorio). Dos usuarios con la misma contraseña tienen hashes diferentes. Es imposible recuperar la contraseña original desde el hash.

---

## Estructura de archivos creados

```
apps/core-api/
├── src/
│   ├── main.ts                          ← punto de entrada, configura Swagger y ValidationPipe
│   ├── app.module.ts                    ← módulo raíz, importa todos los demás
│   ├── common/
│   │   ├── prisma/
│   │   │   ├── prisma.service.ts        ← wrapper de PrismaClient (se conecta/desconecta)
│   │   │   └── prisma.module.ts        ← módulo Global = disponible en toda la app sin reimportar
│   │   ├── decorators/
│   │   │   └── current-user.decorator.ts ← @CurrentUser() extrae el usuario del JWT
│   │   └── guards/
│   │       └── jwt-auth.guard.ts        ← @UseGuards(JwtAuthGuard) protege rutas
│   └── modules/
│       └── auth/
│           ├── auth.module.ts           ← junta todo el módulo auth
│           ├── auth.service.ts          ← lógica de negocio (register, login, tokens)
│           ├── auth.controller.ts       ← define las rutas HTTP
│           ├── auth.types.ts            ← tipo TokenPair compartido
│           ├── dto/
│           │   ├── register.dto.ts      ← validación del body de /register
│           │   ├── login.dto.ts         ← validación del body de /login
│           │   └── refresh.dto.ts       ← validación del body de /refresh
│           └── strategies/
│               └── jwt.strategy.ts      ← le dice a Passport cómo validar el JWT
├── prisma/
│   ├── schema.prisma                    ← definición de tablas y relaciones
│   └── migrations/
│       └── 20260505041157_init/
│           └── migration.sql            ← SQL generado por Prisma (no editar a mano)
└── .env                                 ← variables de entorno (NO commitear a Git)
```

---

## El schema de Prisma explicado

```prisma
model User {
  id           String     @id @default(uuid())   // ID único generado automáticamente
  phone        String     @unique                 // teléfono = username en Ecuador
  email        String?    @unique                 // opcional (el ? significa nullable)
  passwordHash String     @map("password_hash")   // @map = nombre en DB es snake_case
  role         Role                               // enum: CLIENT, MERCHANT, DRIVER, ADMIN
  status       UserStatus @default(PENDING_VERIFICATION)
  ...
  refreshTokens RefreshToken[]                    // relación 1-a-muchos con tokens
}
```

**Un usuario tiene un perfil según su rol:**
- `ClientProfile` → para clientes (nombre, avatar)
- `MerchantProfile` → para comercios (nombre del negocio, RUC, comisión)
- `DriverProfile` → para repartidores (cédula, placa, rating)

`RefreshToken` guarda los tokens activos. Cuando el usuario hace logout, el token se borra de esta tabla.

---

## Las rutas de auth

| Método | Ruta | Protegida | Para qué |
|--------|------|-----------|---------|
| POST | `/api/v1/auth/register` | No | Crear cuenta nueva |
| POST | `/api/v1/auth/login` | No | Iniciar sesión |
| POST | `/api/v1/auth/refresh` | No | Renovar access token |
| POST | `/api/v1/auth/logout` | Sí (JWT) | Cerrar sesión |
| GET  | `/api/v1/auth/me` | Sí (JWT) | Ver mi perfil |

---

## Cómo fluye una petición protegida

```
Cliente envía: GET /api/v1/auth/me
Headers: { Authorization: "Bearer eyJhbGci..." }

1. JwtAuthGuard intercepta la petición
2. Extrae el token del header
3. JwtStrategy valida la firma del token con JWT_ACCESS_SECRET
4. Decodifica el payload: { sub: "uuid", phone: "...", role: "CLIENT" }
5. Busca el usuario en DB para verificar que sigue activo
6. Inyecta el usuario en request.user
7. AuthController ejecuta me(@CurrentUser() user) con el usuario ya disponible
```

---

## Comandos del día a día

### Primera vez (instalar dependencias)
```bash
# Desde la raíz del proyecto
pnpm install
```

### Levantar todo para desarrollar
```bash
# Terminal 1: infraestructura
docker compose -f docker-compose.infra.yml up -d

# Terminal 2: backend
cd apps/core-api
pnpm run start:dev
# El servidor se reinicia automáticamente cuando cambias un archivo (--watch)
```

### Prisma — comandos útiles
```bash
# Cuando cambias schema.prisma, crear y aplicar nueva migración
npx prisma migrate dev --name nombre-descriptivo

# Ver la DB en un browser (GUI visual de las tablas)
npx prisma studio
# Abre http://localhost:5555

# Regenerar el cliente TypeScript (sin migración)
npx prisma generate
```

### Probar los endpoints manualmente
```bash
# Registrar usuario
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"+593987654321","password":"password123","role":"CLIENT"}'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+593987654321","password":"password123"}'

# Ver perfil (reemplaza TOKEN con el accessToken del login)
curl http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer TOKEN"
```

O puedes usar **Swagger UI** directamente en el browser:
```
http://localhost:3000/api/docs
```
Swagger es una interfaz web donde puedes probar todos los endpoints sin escribir curl.

---

## Variables de entorno (`.env`)

```env
DATABASE_URL="postgresql://dz:dev@localhost:5434/dz_core"
# Formato: postgresql://USUARIO:CONTRASEÑA@HOST:PUERTO/NOMBRE_DB

JWT_ACCESS_SECRET="dz_access_secret_dev_change_in_prod"
JWT_REFRESH_SECRET="dz_refresh_secret_dev_change_in_prod"
# En producción estos van a ser strings largos y aleatorios, NUNCA los mismos que aquí

JWT_ACCESS_EXPIRES_IN="15m"   # 15 minutos
JWT_REFRESH_EXPIRES_IN="30d"  # 30 días
```

> **Importante:** `.env` está en `.gitignore`. Nunca se sube a GitHub porque contiene secretos.
> `.env.example` sí se sube — es la "plantilla" que muestra qué variables existen sin revelar los valores.

---

## ¿Qué sigue?

**Siguiente paso:** módulo `merchants` — ver [02-merchants.md](./02-merchants.md)

Lo que vamos a construir:
1. Un comercio puede completar su perfil (nombre, dirección, horario, RUC si tiene)
2. El admin puede verificar/aprobar comercios
3. El comercio puede subir su logo e imagen de portada
4. CRUD completo con los permisos correctos (solo el dueño puede editar su comercio)
