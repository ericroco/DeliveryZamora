# 00 — Setup del Monorepo e Infraestructura

## ¿Qué hicimos?

Preparamos la base sobre la que va a vivir todo el proyecto: la estructura de carpetas, el gestor de paquetes, y los servicios de base de datos corriendo en Docker.

---

## ¿Por qué estas decisiones?

### pnpm workspaces (monorepo)
Un monorepo significa que todos los proyectos (`core-api`, `web`, `mobile-*`, `tracking-service`) viven en **una sola carpeta de Git**.

**Ventaja práctica:** si cambias un tipo de dato compartido, lo arreglas en un solo lugar y todos los proyectos lo reciben. Sin copiar/pegar entre repos.

`pnpm` en vez de `npm` porque:
- Instala paquetes mucho más rápido
- No duplica `node_modules` — usa symlinks (ahorra ~500MB en este proyecto)
- Tiene soporte nativo para workspaces

### Docker Compose para la infraestructura
En vez de instalar PostgreSQL, Redis y TimescaleDB directamente en tu máquina (que ensucian el sistema y generan conflictos), los corremos en contenedores aislados.

**Ventaja:** cualquier persona que clone el repo puede levantar exactamente el mismo entorno con un solo comando.

### Puertos no-estándar
Tu máquina ya tenía otro proyecto usando `5432` (postgres) y `5433`. Elegimos:
- PostgreSQL/PostGIS → **5434**
- TimescaleDB → **5435**  
- Redis → **6380**

---

## Archivos creados

```
DeliveryZamora/
├── package.json              ← raíz del workspace (scripts globales)
├── pnpm-workspace.yaml       ← le dice a pnpm "busca proyectos en apps/* y packages/*"
├── tsconfig.base.json        ← configuración TypeScript compartida por todos los proyectos
├── docker-compose.infra.yml  ← define los 3 contenedores de infraestructura
└── .gitignore                ← excluye node_modules, .env, dist
```

### `pnpm-workspace.yaml`
```yaml
packages:
  - "apps/*"      # core-api, web, mobile-customer, mobile-driver, tracking-service
  - "packages/*"  # tipos compartidos, componentes UI compartidos
```

### `docker-compose.infra.yml` — los 3 servicios
```
postgres    → imagen postgis/postgis (PostgreSQL + extensión geoespacial PostGIS)
timescaledb → imagen timescale (PostgreSQL + extensión time-series para GPS)
redis       → caché + colas de trabajos asíncronos (BullMQ)
```

### `tsconfig.base.json` — opciones clave
```jsonc
"experimentalDecorators": true   // NestJS usa decoradores (@Injectable, @Module, etc.)
"emitDecoratorMetadata": true    // necesario para que NestJS inyecte dependencias
"strict": true                   // TypeScript estricto = menos bugs en runtime
```

---

## Comandos básicos

### Levantar infraestructura (DB + Redis)
```bash
# Desde la raíz del proyecto
docker compose -f docker-compose.infra.yml up -d

# -d = "detached" = corre en background, no bloquea la terminal
```

### Verificar que están corriendo
```bash
docker ps
# Deberías ver: dz_postgres, dz_timescale, dz_redis con status "Up"
```

### Apagar infraestructura
```bash
docker compose -f docker-compose.infra.yml down
# Los datos se conservan en volumes de Docker (no se pierden al apagar)
```

### Borrar datos (reset total)
```bash
docker compose -f docker-compose.infra.yml down -v
# -v = borra los volumes = borra todos los datos. Usar solo si quieres empezar de cero.
```

---

## ¿Qué sigue?

**Siguiente paso:** módulo `auth` — ver [01-auth.md](./01-auth.md)
