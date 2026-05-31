# Plan Técnico — DeliveryZamora

> Versión 3.0 | Fecha: 2026-05-04 | Autor: Eric Rodas

---

## 1. Arquitectura

### Decisión: Modular Monolith + tracking-service extraído

```
┌──────────────────────────────────────────────────────────┐
│   Flutter (cliente)        Next.js (web — admin/merchant) │
└─────────────────────┬────────────────────────────────────┘
                      │ HTTPS / WSS
┌─────────────────────▼────────────────────────────────────┐
│               NestJS — Core API                           │
│                                                           │
│  auth │ catalog │ orders │ payments │ merchants            │
│  admin │ promotions │ ratings │ analytics                 │
│                                                           │
│  BullMQ Workers (notificaciones, liquidaciones, emails)   │
└────────┬──────────────────────────┬───────────────────────┘
         │                          │
  ┌──────▼──────┐          ┌────────▼────────┐
  │ PostgreSQL  │          │ tracking-service │
  │ + PostGIS   │          │   NestJS         │
  └──────┬──────┘          │   Socket.io      │
         │                 │   Redis pub/sub  │
  ┌──────▼──────┐          │   TimescaleDB    │
  │    Redis    │          └─────────────────┘
  │  cache+queue│
  └─────────────┘

Externos: Kushki · FCM · Twilio · Google Maps · Cloudinary · SRI
```

**tracking-service separado tiene justificación técnica real:**
- Actualiza posición cada 5s por repartidor activo → escrituras muy frecuentes
- DB diferente: TimescaleDB (time-series, retención automática)
- WebSockets stateful: no puedes hacer rolling deploy sin romper conexiones activas
- Escala independiente del resto del sistema

Todo lo demás vive en el monolito con módulos bien definidos. Si en el futuro `payments-service` necesita extraerse, los boundaries ya están trazados — es una semana de trabajo, no una reescritura.

---

## 2. Stack Tecnológico

### 2.1 Backend — Core API

```
Runtime:        Node.js 20 LTS
Framework:      NestJS 10+ (TypeScript nativo)
ORM:            Prisma 5
DB:             PostgreSQL 16 + PostGIS 3.4
Cache / Queue:  Redis 7
Async jobs:     BullMQ (sobre Redis)
Auth:           JWT access (15min) + refresh (30d) + OTP WhatsApp
Docs:           Swagger / OpenAPI 3.0
Validación:     class-validator + class-transformer
Testing:        Jest + Supertest + Testcontainers
FSM pedidos:    XState v5
```

**BullMQ en vez de Kafka:** mismo patrón event-driven, sin overhead operacional. Kafka resuelve millones de eventos/segundo con replay distribuido — tenemos ~100 pedidos/día. BullMQ tiene queues, delayed jobs, reintentos, dead-letter, prioridades, y una UI de monitoreo (Bull Board). Suficiente para este proyecto y para el próximo.

### 2.2 tracking-service

```
Framework:      NestJS 10+ (TypeScript)
DB:             TimescaleDB 2.x (PostgreSQL + extensión time-series)
Real-time:      Socket.io 4 (WebSockets + fallback polling)
Cache:          Redis pub/sub (Core API publica ubicación → tracking broadcast)
Protocolo:      REST hacia Core API (2 servicios, no necesitan gRPC)
```

### 2.3 Frontend Web

```
Framework:      Next.js 14 (App Router)
Lenguaje:       TypeScript
Estilos:        Tailwind CSS 3 + shadcn/ui
State:          Zustand (client) + TanStack Query v5 (server)
Forms:          React Hook Form + Zod
Maps:           @vis.gl/react-google-maps
Real-time:      Socket.io client (conecta a tracking-service)
Charts:         Recharts
Auth:           NextAuth.js v5
HTTP:           Axios + interceptors
```

Una sola app Next.js con rutas separadas por rol:
- `/` → landing público
- `/app/*` → cliente (catálogo, carrito, tracking)
- `/merchant/*` → panel de comercio
- `/admin/*` → panel de administración
- `/driver/*` → versión web del repartidor (fallback)

### 2.4 Mobile — Flutter

```
Framework:      Flutter 3.x (Dart) — cliente + repartidor (mismo repo)
State:          Riverpod 2
Navigation:     GoRouter
HTTP:           Dio + interceptors (JWT auto-refresh)
Maps:           google_maps_flutter + geolocator
Real-time:      socket_io_client
Notifications:  Firebase Cloud Messaging
Storage:        Hive (offline cache) + flutter_secure_storage
```

### 2.5 Infraestructura

```
Contenedores:   Docker + Docker Compose (dev)
CI/CD:          GitHub Actions
IaC:            Terraform (Railway provider o DigitalOcean)
Deploy:         Railway (prod inicial) → DigitalOcean cuando escale
Media:          Cloudinary
Push:           Firebase Cloud Messaging
Errores:        Sentry
Logs:           Pino (JSON estructurado)
Monitoreo:      Uptime Robot (gratuito)
Email:          Resend
SMS/WhatsApp:   Twilio
```

---

## 3. Terraform

Terraform maneja toda la infraestructura en código. Si borras un recurso accidentalmente, `terraform apply` lo recrea exactamente igual.

### 3.1 Estructura

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── environments/
    ├── staging/
    │   ├── main.tf          # usa Railway
    │   └── terraform.tfvars
    └── prod/
        ├── main.tf          # usa DigitalOcean cuando escale
        └── terraform.tfvars
```

### 3.2 Railway (inicial)

```hcl
# terraform/environments/staging/main.tf
terraform {
  required_providers {
    railway = {
      source  = "terraform-community-providers/railway"
      version = "~> 0.3"
    }
  }
  backend "s3" {
    # DO Spaces como backend remoto (S3-compatible, $5/mes por 250GB)
    endpoint = "https://nyc3.digitaloceanspaces.com"
    bucket   = "dz-terraform-state"
    key      = "staging/terraform.tfstate"
    region   = "us-east-1"  # valor requerido, ignorado por DO
  }
}

resource "railway_project" "dz" {
  name = "deliveryzamora"
}

resource "railway_service" "core_api" {
  project_id = railway_project.dz.id
  name       = "core-api"
}

resource "railway_service" "tracking" {
  project_id = railway_project.dz.id
  name       = "tracking-service"
}

resource "railway_service" "postgres" {
  project_id = railway_project.dz.id
  name       = "postgres"
  source_image = "ankane/postgis"
}

resource "railway_service" "timescale" {
  project_id = railway_project.dz.id
  name       = "timescaledb"
  source_image = "timescale/timescaledb-ha:pg16"
}

resource "railway_service" "redis" {
  project_id = railway_project.dz.id
  name       = "redis"
  source_image = "redis:7-alpine"
}

resource "railway_variable" "core_api_vars" {
  for_each   = var.core_api_env_vars
  project_id = railway_project.dz.id
  service_id = railway_service.core_api.id
  name       = each.key
  value      = each.value
}
```

### 3.3 DigitalOcean (cuando escale)

```hcl
# terraform/environments/prod/main.tf
resource "digitalocean_app" "dz" {
  spec {
    name   = "deliveryzamora"
    region = "nyc"

    service {
      name               = "core-api"
      instance_count     = 2
      instance_size_slug = "basic-xs"   # $12/mes por instancia
      dockerfile_path    = "apps/core-api/Dockerfile"

      env {
        key   = "DATABASE_URL"
        value = digitalocean_database_cluster.postgres.uri
        type  = "SECRET"
      }
    }

    service {
      name               = "tracking-service"
      instance_count     = 1
      instance_size_slug = "basic-xs"
      dockerfile_path    = "apps/tracking-service/Dockerfile"
    }
  }
}

resource "digitalocean_database_cluster" "postgres" {
  name       = "dz-postgres"
  engine     = "pg"
  version    = "16"
  size       = "db-s-1vcpu-1gb"   # $15/mes
  region     = "nyc1"
  node_count = 1
}

resource "digitalocean_database_cluster" "redis" {
  name       = "dz-redis"
  engine     = "redis"
  version    = "7"
  size       = "db-s-1vcpu-1gb"   # $15/mes
  region     = "nyc1"
  node_count = 1
}
```

### 3.4 Comandos del día a día

```bash
cd terraform/environments/staging
terraform init       # primera vez
terraform plan       # ver qué va a cambiar
terraform apply      # aplicar cambios
terraform destroy    # borrar todo (cuidado en prod)
```

---

## 4. Estructura del Monorepo

```
DeliveryZamora/                        # pnpm workspaces
├── apps/
│   ├── core-api/                      # NestJS — monolito
│   │   ├── src/
│   │   │   ├── config/
│   │   │   ├── common/
│   │   │   │   ├── decorators/        # @CurrentUser, @Roles, @Public
│   │   │   │   ├── guards/            # JwtAuthGuard, RolesGuard
│   │   │   │   ├── interceptors/
│   │   │   │   └── filters/
│   │   │   └── modules/
│   │   │       ├── auth/
│   │   │       ├── users/
│   │   │       ├── merchants/
│   │   │       ├── catalog/
│   │   │       ├── orders/
│   │   │       │   ├── fsm/           # XState machine
│   │   │       │   └── sagas/         # flujos multi-paso
│   │   │       ├── payments/
│   │   │       │   ├── ledger/        # deuda acumulada
│   │   │       │   └── wallet/        # wallet repartidor
│   │   │       ├── delivery/          # asignación de drivers
│   │   │       ├── notifications/     # BullMQ consumers
│   │   │       ├── promotions/
│   │   │       ├── ratings/
│   │   │       ├── analytics/
│   │   │       └── admin/
│   │   ├── prisma/
│   │   │   ├── schema.prisma
│   │   │   ├── migrations/
│   │   │   └── seed.ts
│   │   ├── Dockerfile
│   │   └── package.json
│   │
│   ├── tracking-service/              # NestJS — servicio independiente
│   │   ├── src/
│   │   │   ├── gateway/               # Socket.io WebSocket gateway
│   │   │   ├── location/              # escritura GPS → TimescaleDB
│   │   │   └── assignment/            # ST_DWithin — repartidor más cercano
│   │   ├── prisma/
│   │   │   └── schema.prisma          # solo TimescaleDB
│   │   ├── Dockerfile
│   │   └── package.json
│   │
│   ├── web/                           # Next.js 14 — app única
│   │   ├── app/
│   │   │   ├── (public)/              # landing
│   │   │   ├── (customer)/            # /app/*
│   │   │   ├── (merchant)/            # /merchant/*
│   │   │   ├── (admin)/               # /admin/*
│   │   │   └── (driver)/              # /driver/*
│   │   ├── components/
│   │   ├── lib/
│   │   ├── Dockerfile
│   │   └── package.json
│   │
│   ├── mobile-customer/               # Flutter — cliente
│   │   ├── lib/
│   │   └── pubspec.yaml
│   │
│   └── mobile-driver/                 # Flutter — repartidor
│       ├── lib/
│       └── pubspec.yaml
│
├── packages/
│   ├── types/                         # @dz/types — interfaces compartidas
│   └── ui/                            # @dz/ui — componentes React (shadcn base)
│
├── terraform/
│   ├── environments/
│   │   ├── staging/
│   │   └── prod/
│   └── modules/                       # módulos reutilizables si aplica
│
├── docker-compose.yml                 # dev completo (infra + servicios)
├── docker-compose.infra.yml           # solo infra (postgres, redis, timescale)
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── package.json                       # pnpm workspace root
└── CLAUDE.md
```

---

## 5. Entorno de Desarrollo ($0)

```yaml
# docker-compose.infra.yml
services:
  postgres:
    image: postgis/postgis:16-3.4-alpine
    environment:
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: dz_core
    ports: ["5432:5432"]
    volumes: [postgres_data:/var/lib/postgresql/data]

  timescaledb:
    image: timescale/timescaledb-ha:pg16
    environment:
      POSTGRES_PASSWORD: dev
      POSTGRES_DB: dz_tracking
    ports: ["5433:5432"]

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

  redpanda:                              # Kafka-compatible, 512MB vs 4GB
    image: redpandadata/redpanda:latest
    command: redpanda start --overprovisioned --smp 1 --memory 512M
    ports:
      - "9092:9092"   # Kafka API
      - "8080:8080"   # Redpanda Console (UI web)

volumes:
  postgres_data:
```

**BullMQ no necesita Redpanda** — usa Redis directamente. Redpanda está en docker-compose para cuando quieras practicar event streaming, pero no es requerido para el MVP.

```bash
# Flujo de trabajo diario
docker compose -f docker-compose.infra.yml up -d

# Terminal 1
cd apps/core-api && npm run start:dev

# Terminal 2
cd apps/tracking-service && npm run start:dev

# Terminal 3
cd apps/web && npm run dev

# Terminal 4
cd apps/mobile-customer && flutter run
```

---

## 6. CI/CD (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI
on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgis/postgis:16-3.4-alpine
        env: { POSTGRES_PASSWORD: test, POSTGRES_DB: dz_test }
      redis:
        image: redis:7-alpine

    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
      - run: pnpm install
      - run: pnpm --filter core-api run lint
      - run: pnpm --filter core-api run typecheck
      - run: pnpm --filter core-api run test
      - run: pnpm --filter tracking-service run test
      - run: pnpm --filter web run typecheck

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build & push images
        run: |
          docker build -t ghcr.io/${{ github.repository }}/core-api:${{ github.sha }} apps/core-api
          docker build -t ghcr.io/${{ github.repository }}/tracking-service:${{ github.sha }} apps/tracking-service
          docker build -t ghcr.io/${{ github.repository }}/web:${{ github.sha }} apps/web
          docker push ghcr.io/${{ github.repository }}/core-api:${{ github.sha }}
          # ...
```

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Terraform apply
        working-directory: terraform/environments/staging
        run: |
          terraform init
          terraform apply -auto-approve
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
          TF_VAR_image_tag: ${{ github.sha }}
```

---

## 7. FSM del Pedido (XState v5)

```typescript
// core-api/src/modules/orders/fsm/order.machine.ts
import { createMachine, assign } from 'xstate';

export const orderMachine = createMachine({
  id: 'order',
  initial: 'PENDING_CONFIRMATION',
  states: {
    PENDING_CONFIRMATION: {
      after: { 600_000: 'CANCELLED_BY_TIMEOUT' },
      on: {
        CONFIRM:  'CONFIRMED',
        REJECT:   'CANCELLED_BY_MERCHANT',
        CANCEL:   'CANCELLED_BY_CLIENT',
      },
    },
    CONFIRMED: {
      on: { DRIVER_ASSIGNED: 'DRIVER_ASSIGNED' },
    },
    DRIVER_ASSIGNED: {
      on: { DRIVER_AT_MERCHANT: 'PICKING_UP' },
    },
    PICKING_UP: {
      on: { PICKED_UP: 'ON_THE_WAY' },
    },
    ON_THE_WAY: {
      on: { DELIVERED: 'DELIVERED' },
    },
    DELIVERED:              { type: 'final' },
    CANCELLED_BY_MERCHANT:  { type: 'final' },
    CANCELLED_BY_CLIENT:    { type: 'final' },
    CANCELLED_BY_TIMEOUT:   { type: 'final' },
  },
});
```

---

## 8. Schema de Base de Datos

```sql
-- PostgreSQL + PostGIS (core-api)

-- Usuarios y roles
users:          id, phone, email, password_hash, role, status, created_at
client_profiles:   user_id, name, avatar_url
merchant_profiles: user_id, business_name, tier, ruc, commission_rate, status, verified_at
                   location GEOMETRY(POINT), coverage_area GEOMETRY(POLYGON)
driver_profiles:   user_id, name, cedula, vehicle_type, plate, rating_avg
                   current_location GEOMETRY(POINT), is_available

-- Catálogo
categories:   id, name, icon, parent_id
products:     id, merchant_id, category_id, name, description, price,
              image_url, is_available, preparation_time_min
variants:     id, product_id, name, extra_price

-- Pedidos
orders:       id, client_id, merchant_id, driver_id, state,
              delivery_point GEOMETRY(POINT), delivery_text,
              subtotal, delivery_fee, service_fee, total,
              payment_method, payment_status, created_at, delivered_at
order_items:  id, order_id, product_snapshot JSONB, quantity, unit_price, notes

-- Pagos y ledger
transactions:    id, order_id, amount, method, kushki_ref, status, created_at
merchant_ledger: id, merchant_id, type, amount, order_id, created_at  -- immutable
driver_wallet:   driver_id, balance, updated_at
wallet_movements: id, driver_id, amount, type, order_id, created_at

-- Ratings, cupones
ratings:  id, order_id, from_user_id, target_type, target_id, score, comment
coupons:  id, code, discount_type, amount, min_order, uses_left, expires_at
```

```sql
-- TimescaleDB (tracking-service)

-- Hypertable — retención 30 días automática
driver_locations: time TIMESTAMPTZ, driver_id UUID,
                  location GEOMETRY(POINT), order_id UUID
-- chunk_time_interval = '1 day'
-- retention policy = 30 days
```

---

## 9. APIs de Terceros

| Servicio | Uso | Costo |
|---|---|---|
| **Kushki** | Tarjetas + Split Payments + PayOuts | 3.5% + $0.30/transacción; PayOuts ~$0.25/transferencia |
| **Google Maps Platform** | Maps SDK, Geocoding, Directions | ~$0 en MVP (límite gratuito: 28k calls/mes) |
| **Firebase FCM** | Push notifications Android | Gratis |
| **Twilio** | OTP + notificaciones WhatsApp | ~$0.05/SMS; $0.005/mensaje WhatsApp |
| **Cloudinary** | Storage + CDN de imágenes | Gratis hasta 25 créditos/mes |
| **Sentry** | Error tracking | Gratis hasta 5k errores/mes |
| **Resend** | Emails transaccionales | Gratis hasta 3k/mes |
| **De Una (Pichincha)** | Pago de deuda acumulada por comercios | Negociar con Pichincha |

---

## 10. Costos

| Etapa | Qué usas | Costo |
|---|---|---|
| **Desarrollo** | Docker Compose local | $0/mes |
| **Staging** | Railway Hobby plan | $5/mes |
| **Producción inicial** | Railway Pro | ~$20–30/mes |
| **Producción con carga** | DigitalOcean App Platform (Terraform) | ~$60–80/mes |

Con 12% de comisión, $60/mes de infra se cubre con ~$500 de GMV = ~50 pedidos promedio de $10. Alcanzable en el primer mes real.

---

## 11. Fases de Desarrollo

### Fase 0 — Foundation (Semanas 1–2)

| Tarea | Verificación |
|---|---|
| Monorepo pnpm workspaces + TypeScript config | `pnpm install` sin errores |
| docker-compose.infra.yml funcional | Postgres + Redis + TimescaleDB levantados |
| core-api: módulo auth | `POST /auth/register → /auth/login → GET /auth/me` |
| Prisma schema v1 + migraciones | `prisma migrate dev` sin errores |
| Terraform staging (Railway) | `terraform apply` crea proyecto en Railway |
| GitHub Actions CI | PR verde en repo vacío |

### Fase 1 — Core MVP (Semanas 3–8)

| Semana | Módulos | Entregable |
|---|---|---|
| 3 | merchants, catalog | Comercio se registra, carga catálogo |
| 4 | orders + XState FSM | Crear pedido, FSM funcional, ciclo completo |
| 5 | delivery + PostGIS | Asignación repartidor por ST_DWithin |
| 6 | Flutter customer app | Auth, catálogo, carrito, pedido, historial |
| 7 | Flutter driver app | Disponibilidad, asignación, navegación, confirmación |
| 8 | Next.js merchant panel | Pedidos entrantes, catálogo, resumen del día |

**Verificación Fase 1:** E2E manual completo sin pagos — cliente pide, comercio confirma, repartidor entrega.

### Fase 2 — Real-time (Semanas 9–11)

| Tarea | Descripción |
|---|---|
| tracking-service completo | Socket.io rooms, GPS broadcast, TimescaleDB |
| Redis pub/sub | core-api publica posición → tracking broadcast a cliente |
| Next.js mapa admin | Pedidos activos + repartidores en tiempo real |
| Bull Board | UI de monitoreo de queues en `/admin/queues` |

**Verificación:** Cliente ve repartidor moverse en mapa en tiempo real.

### Fase 3 — Pagos (Semanas 12–15)

| Tarea | Descripción |
|---|---|
| payments module completo | Kushki SDK, webhook confirmación, reembolso |
| Ledger de deuda acumulada | Efectivo → deuda → tope $10 → ocultar tienda |
| Kushki PayOuts batch | Liquidación T+1 diaria a vendedores y repartidores |
| Compensación cruzada | Liquidación digital descuenta deuda antes de depositar |
| Módulo "Mi Cuenta" | Saldo/deuda, historial, pago por De Una |

**Verificación:** $10 con tarjeta → Kushki split 88/12 → T+1 depósito → deuda efectivo descontada.

### Fase 4 — Polish + Launch (Semanas 16–20)

| Tarea | Descripción |
|---|---|
| Ratings, cupones, promociones | Post-entrega, cupones de bienvenida |
| Notificaciones completas | FCM + WhatsApp fallback para los 3 actores |
| Impresión de tickets | Bluetooth térmica — `escpos` o similar |
| SRI básico | Nota de venta Tier RISE; RIDE XML Tier RUC (fase 2) |
| Load testing (k6) | 200 usuarios concurrentes |
| Security audit | OWASP checklist, rate limiting, injection |
| Play Store | Publicar app cliente |
| Pilot real | 5 comercios + 3 repartidores en Zamora |

---

## 12. Resume — Qué demuestra este stack

| Tecnología | Señal |
|---|---|
| **NestJS modular** | Arquitectura enterprise, DI, bounded contexts, TypeScript avanzado |
| **PostgreSQL + PostGIS** | Geoespacial real — ST_DWithin, índices GIST, no solo CRUD |
| **TimescaleDB** | Time-series DB especializada — integración con datos de alto volumen |
| **XState FSM** | Modelado formal de estados — diferencia de un `switch/case` ad-hoc |
| **BullMQ + Redis** | Arquitectura asíncrona con colas — piensas en resiliencia |
| **Socket.io** | Tiempo real con rooms, namespaces, fallback — no trivial |
| **Flutter (2 apps)** | Cross-platform nativo — diferenciador fuerte en LATAM |
| **Next.js App Router** | RSC, SSR/SSG, rutas por rol, SEO |
| **Kushki Split + PayOuts** | Pagos reales con gateway ecuatoriano — conocimiento del ecosistema |
| **Terraform** | IaC real — diferencia entre "sé Docker" y "sé DevOps" |
| **GitHub Actions CI/CD** | Pipeline completo: lint → test → build → deploy |
| **Monorepo pnpm** | Gestión de proyectos multi-app con packages compartidos |
| **Docker** | Containerización correcta con multi-stage builds |

**Narrativa de entrevista:**
> "Construí DeliveryZamora desde cero — plataforma multi-vendor de delivery para Ecuador. Backend NestJS con arquitectura modular, geoespacial con PostGIS (asignación de repartidores por proximidad), tracking en tiempo real con Socket.io y TimescaleDB, jobs asíncronos con BullMQ, FSM del pedido con XState, integración completa con Kushki Split Payments y PayOuts diarios. Dos apps Flutter, dashboard Next.js, infraestructura en Terraform. En producción real en Zamora con comercios y repartidores activos."
