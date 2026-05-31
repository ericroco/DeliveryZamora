# 14 — Catalog

## Qué hace

Capa de descubrimiento pública para la app mobile/web. Sin autenticación. Agrega datos de categorías, tiendas y productos en endpoints optimizados para la pantalla de inicio, búsqueda global y exploración por categoría.

## Endpoints

| Método | Ruta | Rol | Descripción |
|--------|------|-----|-------------|
| GET | /catalog | PUBLIC | Pantalla de inicio: categorías + tiendas destacadas |
| GET | /catalog/search | PUBLIC | Búsqueda en tiendas y productos |
| GET | /catalog/categories/:categoryId/stores | PUBLIC | Tiendas de una categoría |

## Probar con Swagger / curl

### Pantalla de inicio (home)
```bash
curl http://localhost:3000/catalog
```

Respuesta:
```json
{
  "categories": [
    { "id": "uuid", "name": "Farmacias", "slug": "farmacias", "iconUrl": "..." },
    { "id": "uuid", "name": "Restaurantes", "slug": "restaurantes", "iconUrl": "..." }
  ],
  "featuredStores": [
    {
      "id": "uuid",
      "name": "Farmacia Zamora",
      "ratingAvg": 4.8,
      "ratingCount": 120,
      "logoUrl": "...",
      "category": { "name": "Farmacias", "slug": "farmacias" }
    }
  ]
}
```

### Búsqueda global
```bash
curl "http://localhost:3000/catalog/search?q=farmacia&page=1&limit=10"
```

Respuesta:
```json
{
  "query": "farmacia",
  "stores": [...],
  "products": [...],
  "page": 1,
  "limit": 10
}
```

### Tiendas por categoría (paginado)
```bash
curl "http://localhost:3000/catalog/categories/<category-uuid>/stores?page=1&limit=20"
```

Respuesta:
```json
{
  "stores": [...],
  "total": 8,
  "page": 1,
  "limit": 20
}
```

## Diferencia con /stores

| | /catalog | /stores |
|--|---------|---------|
| Auth | No requerida | Requerida (MERCHANT/ADMIN) |
| Uso | App mobile, descubrimiento | CRUD de tiendas |
| Datos | Agregados, optimizados para UI | CRUD completo |
| Búsqueda | Global (tiendas + productos) | Solo tiendas |

## Detalles de implementación

- `getHome()` hace 2 queries en paralelo: todas las categorías activas + top 10 tiendas por `ratingAvg`.
- `search()` hace 2 queries en paralelo: tiendas Y productos que coincidan con `q`, case-insensitive.
- `getStoresByCategory()` hace `findMany` + `count` en paralelo para devolver paginación completa.

## Notas

- Al no requerir auth, estos endpoints son los que consume la app al abrirse por primera vez.
- La búsqueda busca en `name` y `description` de tiendas, y en `name` y `description` de productos.
- Las tiendas inactivas (`isActive: false`) nunca aparecen en el catálogo.
- Paginación: `page` y `limit` son query params opcionales con defaults `page=1, limit=10` (categorías/stores usa `limit=20`).
