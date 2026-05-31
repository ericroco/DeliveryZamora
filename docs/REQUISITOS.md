# Ingeniería de Requisitos — DeliveryZamora

> Versión 3.0 | Fecha: 2026-05-04 | Autor: Eric Rodas

---

## 1. Visión del Producto

**DeliveryZamora** es una plataforma multi-vendedor de entregas a domicilio diseñada específicamente para el Cantón Zamora, capital de la provincia Zamora Chinchipe, Ecuador. Conecta comercios locales (desde restaurantes establecidos hasta vendedores caseros informales) con consumidores finales, gestionando el ciclo completo pedido → despacho → entrega en tiempo real.

### Problema que resuelve

- Zamora carece de una plataforma de delivery organizada y confiable.
- Comercios dependen de WhatsApp manual y de "centrales de pedidos" humanas: sin trazabilidad, sin escalabilidad, sin pagos digitales.
- **Vendedores informales (postres caseros, comida desde casa) son invisibles**: no tienen local físico y los servicios centralizados de WhatsApp no los promocionan, limitando sus ventas solo a conocidos.
- Repartidores trabajan sin herramientas, sin historial de ganancias, sin asignación eficiente.
- Clientes no pueden pagar con tarjeta en la mayoría de locales — **Zamora tiene muy pocos POS físicos**.

### Propuesta de valor

| Actor | Propuesta core |
|---|---|
| **Cliente** | Catálogo visual completo de toda la ciudad (descubriendo joyas escondidas caseras). Pedir en < 2 minutos, rastrear la moto en tiempo real y pagar con tarjeta |
| **Comercio formal** | Control directo del menú. Efectivo al instante, tarjeta T+1. Sin WhatsApp manual todo el día; sin comprar POS físico ($300+) |
| **Vendedor informal (Casero)** | Vitrina digital gratuita — aparece al lado de los restaurantes grandes. Puede cobrar con tarjeta sin RUC. La logística se resuelve sola: solo toca un botón y la moto llega |
| **Repartidor** | Asignaciones automáticas GPS, no más direcciones escritas con errores por chat, reducción de tiempos muertos, ganancias visibles al día |
| **Plataforma** | Comisión 12% + tarifa de servicio; crecimiento orgánico en mercado sin competencia directa |

---

## 2. Contexto del Mercado y Competencia

### 2.1 Datos de Zamora

- Población urbana estimada: ~15.000–18.000 habitantes
- Capital provincial con crecimiento por minería (proyecto Mirador) y turismo amazónico
- Conectividad: CNT fibra en centro urbano; 4G Claro/Movistar en zonas principales; 3G o sin señal en periferias
- Economía: alta informalidad comercial; muchos locales operan sin RUC; el comercio pequeño compra ingredientes con las ganancias del día
- Uso masivo de WhatsApp y Facebook para comercio; poca experiencia con apps de pago
- **Bancos presentes:** Banco de Loja (fuerte presencia regional), Banco Pichincha, BancoGuayaquil, CACPE Zamora (cooperativa), BanEcuador
- **Medios de pago dominantes:** efectivo (>80%), De Una (Banco Pichincha), transferencias entre cuentas; tarjetas físicas pero casi sin POS en locales

### 2.2 El enemigo real: Centrales de WhatsApp (ej. "Express Delivery")

Nuestra competencia principal no es el WhatsApp de cada local — es el despachador humano centralizado ("Express Delivery" y similares). Y tenemos que ser mejores que Zaymi, que ya opera exitosamente en Loja (ciudad vecina).

**Por qué el sector informal pierde con las centrales de WhatsApp:**
Si un cliente escribe a la central, pide lo que ya conoce ("tráeme una hamburguesa de X lugar"). La persona que vende postres caseros no existe en esa transacción. WhatsApp no permite "vitrinear".

| Capacidad | WhatsApp local | Express Delivery (central) | PedidosYa / Zaymi | DeliveryZamora |
|---|---|---|---|---|
| Pagar con tarjeta crédito/débito | ❌ | ❌ | ✅ | ✅ |
| Rastrear repartidor en tiempo real | ❌ | ❌ | ✅ | ✅ |
| Catálogo organizado y visual | Parcial | Parcial | ✅ | ✅ |
| Vendedor recibe dinero hoy | ✅ (efectivo inmediato) | ✅ (efectivo) | ❌ (semanal PedidosYa) | ✅ (**diario T+1**) |
| Vendedores informales sin RUC | ✅ (sin control) | ✅ (sin control) | ❌ (requieren formalización) | ✅ (Tier 1 con cédula) |
| Vitrina para informales "invisibles" | ❌ Nula | ❌ Nula | ❌ Nula | ✅ Alta — Categoría "Caseros" |
| Sin terminal POS físico para tarjetas | N/A | N/A | ✅ (via app) | ✅ (via Kushki) |
| Gestión multi-pedido simultáneo | ❌ (caos) | Limitada | ✅ | ✅ |
| Comisión | $0 | ~$1–2 por pedido (informal) | 20–25% | **12% + $0.15–$0.25 cliente** |

### 2.3 "El Escaparate Democrático" — nuestro diferenciador real

DeliveryZamora le da al negocio casero el mismo tamaño de foto y presencia que al local más caro de Zamora. **Democratiza las ventas generando "compras por antojo"** cuando el cliente abre la app sin saber exactamente qué quiere comer.

**Los dos argumentos decisivos para el vendedor:**
1. "Aceptas tarjetas sin comprar un terminal POS ($300+). Ningún cliente en Zamora puede pagarte con tarjeta hoy. Con nosotros, sí."
2. "Te pagamos todo lo del día, al día siguiente, a tu cuenta de siempre. Sin esperar una semana como en PedidosYa. Sin perseguir transferencias de cada cliente como en WhatsApp."

### 2.4 Categorías de Comercios objetivo

**Tier A — Establecidos (priorizados en lanzamiento):**
1. Restaurantes y comidas rápidas
2. Farmacias
3. Supermercados / minimarkets (TIA, mercados locales)
4. Panaderías y pastelerías con local físico

**Tier B — Semiformales (segunda ola):**
5. Licorerías
6. Ferreterías (material de construcción liviano, herramientas)
7. Tiendas de abarrotes
8. Tiendas de mascotas

**Tier C — Informales / Caseros (diferenciador de mercado):**
9. Vendedores de postres y dulces caseros
10. Almuerzos y meriendas preparadas en casa
11. Repostería por encargo
12. Cualquier persona que venda comida o productos desde su domicilio

> El Tier C es el diferenciador crítico: ninguna plataforma en Ecuador onboardea a este segmento. Son decenas de vendedores en Zamora que hoy solo operan por WhatsApp o Facebook y son completamente invisibles para clientes nuevos.

---

## 3. Stakeholders

### 3.1 Interesados Directos (Primary)

| Stakeholder | Rol | Interés principal | Influencia |
|---|---|---|---|
| **Cliente final** | Usuario consumidor | Comodidad, velocidad, poder pagar con tarjeta | ALTA |
| **Comercio establecido (Tier A/B)** | Vendedor con local | Más ventas, no perder tiempo en WhatsApp, aceptar tarjetas | ALTA |
| **Vendedor informal (Tier C)** | Vendedor casero | Canal de ventas sin burocracia ni inversión | ALTA |
| **Repartidor (freelance)** | Ejecuta entregas | Ingresos, asignación justa, no depender de llamadas | ALTA |
| **Administrador plataforma** | Dueño del sistema | Crecimiento sostenible, comisiones, calidad de servicio | ALTA |

### 3.2 Interesados Secundarios

| Stakeholder | Interés |
|---|---|
| **GAD Municipal Zamora** | Empleo local, modernización, formalización de comercio |
| **Cámara de Comercio Zamora** | Beneficio a socios; posible convenio de promoción |
| **Banco de Loja** | Adopción de su plataforma de pagos móvil; partnership |
| **Banco Pichincha / De Una** | Volumen de transacciones en su plataforma |
| **SRI** | Eventual formalización de vendedores informales |
| **UTPL / UNL sede Zamora** | Caso de estudio; estudiantes como usuarios early adopters |
| **Inversores locales** | ROI en plataforma con monopolio local |

### 3.3 Antipartes

| Antipartes | Razón de resistencia | Estrategia de mitigación |
|---|---|---|
| Centrales de WhatsApp (Express Delivery) | Pérdida de negocio de intermediación | La plataforma ofrece más valor al cliente y al comercio simultáneamente |
| Comercios que cobran efectivo inmediato | Percepción de deuda vs. libertad del efectivo | Modelo Deuda Acumulada no toca el efectivo en el momento; la deuda se salda después |
| Vendedores informales sin RUC | Miedo a fiscalización al formalizarse | Tier informal sin obligación de RUC; sin reportes a SRI bajo $800/mes |
| Taxistas que hacen delivery informal | Competencia por encargos | Ofrecerles ser repartidores oficiales de la plataforma |
| Clientes acostumbrados a WhatsApp gratis | Cambio de hábito | Primeros pedidos con delivery gratis o cupones de bienvenida |

---

## 4. Modelo de Monetización y Sostenibilidad

### 4.1 Las tres fuentes de ingreso

| Fuente | Quién paga | Monto | Notas |
|---|---|---|---|
| **Comisión al comercio** | Vendedor | 12% sobre subtotal de productos | Digital: vía Kushki Split. Efectivo: vía Deuda Acumulada |
| **Tarifa de servicio** | Cliente | $0.15 – $0.25 por pedido | Recargo mínimo para cubrir costos operativos de la plataforma |
| **Publicidad destacada** | Comercio | Tarifa variable | Fase 2 — banner o posición destacada en categoría |

> Sin suscripciones. Sin planes premium. La plataforma gana **solo cuando hay transacciones**.

### 4.2 Gestión de Efectivo: Modelo de Deuda Acumulada (Post-pago)

Cobrar saldo prepago o retener el efectivo en el momento de la entrega es inviable para el comerciante zamorano y mortal para el vendedor casero que vive al día. Se adopta el **modelo de Deuda Acumulada**:

| Paso | Qué ocurre |
|---|---|
| **Flujo Libre** | Cliente paga $10.00 en efectivo al repartidor. El repartidor entrega 100% al vendedor. El vendedor tiene su dinero al instante para volver a comprar ingredientes. La plataforma no toca el efectivo. |
| **Ledger Interno** | El sistema anota silenciosamente que el vendedor debe $1.20 (12% de comisión sobre $10.00). |
| **Acumulación** | La deuda crece con cada venta en efectivo sin interferir en las operaciones. |
| **Límite de Tolerancia** | Al llegar a **$10.00 de deuda acumulada** (equivale a ~$83 vendidos en efectivo), la tienda se oculta automáticamente de la app hasta que el vendedor realice un abono. |
| **Notificación previa** | Al 70% del tope ($7.00 deuda), el sistema envía alerta al vendedor para que no sea sorprendido. |
| **Pago de deuda** | El vendedor paga por De Una directamente desde el módulo "Mi Cuenta". Su tienda se reactiva inmediatamente. |

> No se siente como un robo — se siente como pagar la luz después de consumirla.

### 4.3 Compensación Cruzada (El escenario ideal)

Si el vendedor recibe ventas con tarjeta (vía Kushki), la liquidación del día siguiente (T+1) **descuenta automáticamente** la deuda acumulada por ventas en efectivo antes de depositar el neto.

```
Ejemplo: Vendedor tiene $3.50 de deuda por efectivo.
Hoy recibió $50 en pedidos con tarjeta → comisión digital $6.00.
Liquidación T+1 = ($50 × 88%) − $3.50 deuda = $40.50 neto depositado.
Deuda = $0. Tienda sigue activa.
```

### 4.4 Liquidación diaria — nuestro mayor diferenciador vs. competencia

**El problema:** PedidosYa paga a comercios cada semana. Para un restaurante que compra ingredientes con lo que vende hoy, esperar 7 días es inviable. Para un vendedor casero de postres, directamente imposible.

**Nuestra solución: Kushki PayOuts — pago diario automatizado a cualquier cuenta bancaria ecuatoriana.**

El vendedor registra su cuenta bancaria **una sola vez** (personal o comercial, cualquier banco: CACPE, Pichincha, BancoLoja, Produbanco, lo que tenga). Desde ese momento:

| Método | Flujo del dinero | ¿Cuándo llega al vendedor? |
|---|---|---|
| **Efectivo** | Cliente → repartidor → vendedor (en mano, en la entrega) | Inmediato |
| **Tarjeta (Kushki Split)** | Kushki divide en el cobro: vendedor 88%, plataforma 12% (menos deuda pendiente si aplica) | Siguiente día hábil (T+1) vía Kushki PayOuts |
| **De Una** | Plataforma recibe → Kushki PayOuts al vendedor (menos deuda pendiente si aplica) | T+1 |

### 4.5 Stats diarias: gratis para todos

- **Resumen del día para todo vendedor**: 3 datos en pantalla grande — ventas totales, número de pedidos, producto más pedido.
- Sin dashboards complejos, sin términos de negocio, sin gráficas de barras.
- Pensado para alguien que nunca ha usado un sistema de punto de venta en su vida.

---

## 5. Requisitos de Negocio (BR)

| ID | Requisito de Negocio |
|---|---|
| BR-01 | Modelo 100% basado en transacciones. Sin suscripciones, sin planes. La plataforma solo gana cuando hay actividad |
| BR-02 | Comisión del 12% aplica sobre subtotal de productos (no sobre costo de delivery). Tasa configurable por categoría |
| BR-03 | Pagos digitales (tarjeta, De Una): Kushki Split divide el cobro automáticamente en el momento de la transacción |
| BR-04 | Pagos en efectivo: comisión del 12% se registra como deuda acumulada en ledger interno; no se retiene nada al momento de la entrega |
| BR-05 | Tope de deuda por efectivo: **$10.00**. Al superarlo, la tienda se oculta hasta abono |
| BR-06 | Compensación cruzada: toda liquidación digital descuenta primero la deuda pendiente de efectivo antes de transferir el neto |
| BR-07 | Tarifa de servicio al cliente: **$0.15 – $0.25 por pedido** (recargo visible en el resumen del carrito) |
| BR-08 | Liquidación a vendedores: **diaria (T+1)** vía Kushki PayOuts a cualquier cuenta bancaria ecuatoriana registrada |
| BR-09 | La plataforma actúa como merchant of record ante Kushki; el vendedor no necesita cuenta Kushki propia |
| BR-10 | El tier de formalización (Informal/RISE/RUC) determina solo la documentación tributaria, **no** las funcionalidades de cobro |
| BR-11 | Los repartidores son independientes; la plataforma no asume relación laboral |
| BR-12 | Zonas de cobertura configurables por comercio |
| BR-13 | Precio de delivery configurable; puede ser $0 por monto mínimo |
| BR-14 | Mínimo viable piloto: 5 comercios activos + 2 repartidores verificados |
| BR-15 | Plataforma autosustentable en 18 meses post-lanzamiento |

---

## 6. Tiers de Formalización de Comercios

El tier **no bloquea ninguna funcionalidad de ventas**. Solo determina la documentación tributaria que genera la plataforma. Un vendedor informal puede aceptar tarjetas desde el día 1 — la plataforma es el merchant of record ante Kushki.

### Tier 1 — Informal (Solo cédula + cuenta bancaria)

**Requisitos:** Cédula ecuatoriana vigente + número de celular + cuenta bancaria de cualquier tipo (personal, de ahorro, cooperativa)

**Lo que puede hacer:**
- Todo: catálogo, pedidos, efectivo, tarjetas, De Una
- Recibir liquidación diaria vía Kushki PayOuts a su cuenta
- Ver resumen diario de ventas
- Ver su saldo de deuda / crédito en el módulo "Mi Cuenta"

**Limitación única:** Sin comprobantes de venta propios. La transacción fiscal queda a nombre de la plataforma.

**Límite de transacciones digitales:** $800/mes. Al acercarse, la plataforma le notifica y ofrece ayuda para registrarse en RISE (gratis, 30 min en SRI).

---

### Tier 2 — RISE

**Requisitos:** RISE activo + cuenta bancaria vinculada

**Adicional al Tier 1:**
- Emite nota de venta (comprobante básico para el cliente)
- Límite de transacciones: $5.000/mes (límite legal del RISE)
- Badge "Vendedor verificado" en la plataforma

**Cómo sacar el RISE:** Gratis, con la cédula, en la oficina del SRI de Zamora. La plataforma incluye guía visual paso a paso.

---

### Tier 3 — RUC

**Requisitos:** RUC activo con obligación tributaria

**Adicional al Tier 2:**
- Facturación electrónica (RIDE XML — integración SRI)
- Sin límite de transacciones mensuales
- Reportes exportables para contabilidad
- Badge "Negocio certificado"

---

## 7. Requisitos Funcionales

### 7.1 Módulo de Clientes (RF-C)

| ID | Requisito |
|---|---|
| RF-C01 | Registro con número de teléfono (OTP por WhatsApp o SMS) — mínimo fricción, sin formularios largos |
| RF-C02 | Dirección de entrega: selección en mapa o descripción textual libre ("casa amarilla frente al parque") para zonas sin GPS preciso |
| RF-C03 | Explorar comercios por categoría, tiempo estimado, precio de delivery; sección separada "Vendedores Caseros" |
| RF-C04 | Búsqueda de productos y comercios (full-text) |
| RF-C05 | Carrito de compras (un pedido = un comercio); resumen visible: subtotal + costo delivery + **tarifa de servicio** + total |
| RF-C06 | Métodos de pago: efectivo, tarjeta crédito/débito (Kushki), De Una (Banco Pichincha), transferencia bancaria, Banco de Loja app |
| RF-C07 | Rastreo de pedido en tiempo real: mapa con posición del repartidor + estados en texto simple ("Tu pedido está en camino 🛵") |
| RF-C08 | Historial de pedidos con re-order con 1 tap |
| RF-C09 | Calificación de comercio y repartidor post-entrega (estrellitas; texto opcional) |
| RF-C10 | Notificaciones push Android (prioritario) de cambios de estado |
| RF-C11 | Notificación por WhatsApp como fallback (para clientes sin internet en el momento) |
| RF-C12 | Cupones de descuento y código de referido |
| RF-C13 | Tiempo estimado de entrega visible antes de confirmar pedido |
| RF-C14 | Cancelación libre antes de confirmación del comercio |
| RF-C15 | Chat básico con repartidor durante la entrega (texto y audios) |
| RF-C16 | Instrucciones especiales de entrega por pedido ("tocar timbre", "dejar en portería") |

### 7.2 Módulo de Comercios (RF-M)

| ID | Requisito |
|---|---|
| RF-M01 | Panel web **ultra-simple**: orientado a personas sin experiencia digital. Máximo 3 acciones en pantalla principal. Íconos grandes. Texto mínimo. Personas que solo saben usar WhatsApp deben aprenderlo en 2 minutos |
| RF-M02 | Gestión de catálogo: agregar producto con foto del celular, nombre y precio. Sin campos opcionales visibles por defecto |
| RF-M03 | Horarios de atención: "abierto ahora" toggle + configuración semanal básica |
| RF-M04 | Pedidos entrantes: **alerta de audio fuerte in-browser** (como timbre, asumiendo que el vendedor está cocinando) + pantalla grande con el detalle. Dos botones: ACEPTAR / RECHAZAR |
| RF-M05 | Confirmación del pedido: ingresar tiempo de preparación (opciones pre-definidas: 10/20/30/45 min) |
| RF-M06 | Marcar pedido como "Listo" cuando está preparado |
| RF-M07 | **Resumen del día:** 3 números en pantalla grande — ventas totales, número de pedidos, producto estrella. Sin gráficos complejos |
| RF-M08 | Gestión de disponibilidad por producto: marcar "agotado" con un tap |
| RF-M09 | Zona de cobertura: radio simple en mapa (arrastra círculo) o listar barrios atendidos |
| RF-M10 | Promociones básicas: % de descuento en producto o "delivery gratis desde $X" |
| RF-M11 | Historial de liquidaciones recibidas y comisiones cobradas |
| RF-M12 | Impresión de tickets (compatible con impresoras térmicas Bluetooth — muy comunes en locales de Zamora) |
| RF-M13 | Múltiples operarios por comercio (ej: dueño + quien atiende) con mismo acceso básico |
| RF-M14 | Onboarding guiado: 5 pasos visuales para configurar el local desde cero en < 10 minutos (foto, nombre, categoría, productos, zona) |
| RF-M15 | **Módulo "Mi Cuenta"**: visor grande del estado financiero — saldo a favor o deuda acumulada — con historial de movimientos y botón directo de pago vía De Una para saldar deuda y reactivar tienda |

### 7.3 Módulo de Repartidores (RF-R)

| ID | Requisito |
|---|---|
| RF-R01 | App Android nativa (Flutter); iOS fase 2 |
| RF-R02 | Registro: cédula + foto del repartidor + foto del vehículo + número de celular |
| RF-R03 | Toggle de disponibilidad (verde = disponible, rojo = fuera de servicio) |
| RF-R04 | Notificación de nueva asignación: sonido + vibración; ver: comercio, dirección de entrega, distancia, ganancia estimada |
| RF-R05 | Aceptar o rechazar asignación (máx 5 rechazos/día antes de pausa forzada) |
| RF-R06 | Navegación: botón directo que abre Google Maps o Waze con la dirección cargada |
| RF-R07 | Confirmación de recogida (tap en "Recogí el pedido") |
| RF-R08 | Confirmación de entrega (tap + foto opcional) |
| RF-R09 | Si pago en efectivo: pantalla muestra en grande — **COBRA: $X.xx / ENTREGA AL LOCAL: $Y.yy / TU GANANCIA: $Z.zz** — y confirmación de cobro obligatoria |
| RF-R10 | Dashboard de ganancias: hoy / esta semana / este mes |
| RF-R11 | Historial de entregas con mapa de ruta recorrida |
| RF-R12 | Calificación promedio visible |
| RF-R13 | Wallet del repartidor: ganancias por pedidos digitales se liquidan vía Kushki PayOuts a su cuenta bancaria; en efectivo ya recibió directamente durante la entrega |

### 7.4 Módulo de Administración (RF-A)

| ID | Requisito |
|---|---|
| RF-A01 | Dashboard: mapa con pedidos activos y repartidores en tiempo real |
| RF-A02 | KPIs del día: pedidos totales, monto facturado, comercios activos, repartidores activos |
| RF-A03 | Gestión de usuarios: ver, bloquear, desbloquear, notas internas |
| RF-A04 | Onboarding de comercios: revisar documentos, aprobar o rechazar, asignar tier |
| RF-A05 | Onboarding de repartidores: revisar documentos, aprobar |
| RF-A06 | Configuración de comisiones por tier y por categoría |
| RF-A07 | Liquidaciones: generar reporte de lo que corresponde pagar a cada comercio, registrar transferencia realizada |
| RF-A08 | Gestión de zonas de cobertura de la plataforma (polígono en mapa) |
| RF-A09 | Sistema de disputas: ver historial del pedido + chat entre partes + resolución |
| RF-A10 | Cupones globales: crear, activar, desactivar, ver uso |
| RF-A11 | Reportes: pedidos por periodo, comisiones cobradas, métodos de pago más usados (CSV) |
| RF-A12 | Logs de auditoría: toda acción admin con timestamp y usuario |
| RF-A13 | Notificaciones masivas: push o WhatsApp a segmentos (todos los clientes, todos los comercios, etc.) |
| RF-A14 | Visor del ledger de deudas: estado de deuda acumulada por comercio, historial de pagos de deuda, listado de tiendas ocultas por tope alcanzado |

### 7.5 Módulo de Pagos (RF-P)

| ID | Requisito |
|---|---|
| RF-P01 | **Tarjeta crédito/débito vía Kushki** — Visa, Mastercard, débito de bancos locales. Cliente tokeniza la tarjeta con Kushki SDK en la app (PCI DSS; datos nunca en servidor propio). Kushki Split Payments divide automáticamente: vendedor 88% + plataforma 12% en el momento del cobro |
| RF-P02 | **De Una (Banco Pichincha)** — link de cobro o QR generado por la plataforma. Cliente paga desde su app De Una; plataforma recibe webhook de confirmación. Neto se paga al vendedor vía Kushki PayOuts T+1 |
| RF-P03 | **Efectivo** — repartidor cobra monto exacto al cliente, entrega 100% al vendedor en mano. Plataforma registra la transacción sin retener nada; comisión queda como deuda acumulada en ledger |
| RF-P04 | **Liquidación diaria a vendedores (Kushki PayOuts)** — cada día hábil la plataforma ejecuta batch de transferencias a las cuentas bancarias de todos los vendedores con saldo pendiente, descontando deuda acumulada antes de depositar el neto |
| RF-P05 | **Tarifa de servicio al cliente** — $0.15–$0.25 por pedido cobrado al cliente; visible en el resumen del carrito antes de confirmar |
| RF-P06 | Registro completo de transacciones: monto bruto, comisión, tarifa de servicio, neto vendedor, método, estado (pendiente/confirmado/fallido/reembolsado), timestamp |
| RF-P07 | Reembolso automático a tarjeta vía Kushki si pedido cancelado antes de confirmación del comercio |
| RF-P08 | Pago diario a repartidores: Kushki PayOuts a su cuenta bancaria personal |
| RF-P09 | Comprobante de venta para el cliente: ticket digital por email/WhatsApp con detalle del pedido |
| RF-P10 | Nota de venta electrónica para Tier RISE; factura electrónica SRI (RIDE XML) para Tier RUC |
| RF-P11 | Dashboard de conciliación para admin: ver cada transacción, su estado, deuda de efectivo, y a qué vendedor se le pagó |
| RF-P12 | Ledger de deuda: registro inmutable por comercio de cada comisión de efectivo pendiente, pagos de deuda realizados, y compensaciones cruzadas aplicadas |

---

## 8. Requisitos No Funcionales (RNF)

### 8.1 Rendimiento

| ID | Requisito |
|---|---|
| RNF-P01 | Tiempo de respuesta API < 300ms en p95 bajo carga normal |
| RNF-P02 | Actualización de ubicación del repartidor cada 5 segundos durante pedido activo |
| RNF-P03 | Soporte para 200 usuarios concurrentes en MVP; arquitectura escalable a 5.000 |
| RNF-P04 | Disponibilidad 99.5% (SLA inicial) |
| RNF-P05 | App móvil funcional en conexiones 3G (≥1 Mbps) |

### 8.2 Seguridad

| ID | Requisito |
|---|---|
| RNF-S01 | Autenticación JWT con access token (15 min) + refresh token (30 días) |
| RNF-S02 | RBAC: `cliente`, `comercio_owner`, `comercio_staff`, `repartidor`, `admin`, `superadmin` |
| RNF-S03 | Toda comunicación HTTPS/TLS 1.3 |
| RNF-S04 | Datos de tarjeta nunca almacenados en servidor propio; tokenización 100% vía Kushki SDK |
| RNF-S05 | Rate limiting en endpoints de auth (5 intentos/min), pagos (10/min), y OTP (3 intentos) |
| RNF-S06 | Logs de auditoría inmutables para transacciones financieras y modificaciones al ledger |
| RNF-S07 | Validación y sanitización de todos los inputs en backend |

### 8.3 Usabilidad (crítico para contexto de Zamora)

| ID | Requisito |
|---|---|
| RNF-U01 | App cliente: onboarding completo en < 90 segundos. Solo teléfono + OTP + nombre |
| RNF-U02 | Panel de comercio: **diseño para no-técnicos**. Sin jerga de negocios. Sin menús de más de 3 niveles. Íconos grandes con etiqueta de texto debajo |
| RNF-U03 | Todo mensaje de error en lenguaje natural: "Tu tarjeta fue rechazada. Intenta con otra o paga en efectivo" (no "Error 402: card_declined") |
| RNF-U04 | Flujo de pedido (abrir app → confirmar pedido) en máximo 4 pasos y 2 minutos |
| RNF-U05 | El panel de comercio funciona en el navegador del celular (no solo computadora) |
| RNF-U06 | Notificación de nuevo pedido en el comercio tiene audio activado por defecto |
| RNF-U07 | App repartidor funcional con pantalla sucia o guantes (botones grandes, mínimo texto) |
| RNF-U08 | Modo offline básico en app cliente y repartidor: ver últimos pedidos y datos cacheados sin internet |

### 8.4 Mantenibilidad

| ID | Requisito |
|---|---|
| RNF-M01 | Cobertura de tests backend ≥ 80% (unit + integration) |
| RNF-M02 | API documentada con Swagger/OpenAPI |
| RNF-M03 | Toda configuración vía variables de entorno validadas al arranque |
| RNF-M04 | Logs estructurados JSON con niveles debug/info/warn/error |
| RNF-M05 | Monitoreo de errores en producción vía Sentry |

### 8.5 Cumplimiento Legal Ecuador

| ID | Requisito |
|---|---|
| RNF-L01 | Facturación electrónica SRI (formato RIDE XML) solo para Tier RUC; nota de venta para Tier RISE |
| RNF-L02 | Política de privacidad conforme a LOPDP (Ley Orgánica de Protección de Datos Personales) |
| RNF-L03 | Términos y condiciones diferenciados: clientes, comercios, repartidores |
| RNF-L04 | Repartidores firman contrato de prestación de servicios independientes (no relación laboral) |
| RNF-L05 | Vendedores Tier Informal notificados de límite de transacciones digitales ($800/mes) y proceso de formalización RISE |

---

## 9. Casos de Uso Principales

### CU-01: Realizar un Pedido (Cliente)

**Actor:** Cliente
**Precondición:** Registro completado (teléfono + nombre)

```
1. Abre app → ve pantalla de inicio con comercios cercanos abiertos ahora
2. Selecciona categoría o busca directamente
3. Entra al comercio, ve el catálogo con fotos y precios
4. Agrega productos al carrito (tap en "+" al lado del producto)
5. Ve resumen: subtotal + costo delivery + tarifa de servicio + total
6. Confirma dirección de entrega (la guarda para próxima vez)
7. Elige método de pago: efectivo / tarjeta / De Una
8. Si tarjeta: ingresa datos en pantalla segura (Kushki)
9. Confirma pedido
10. Comercio notificado → Cliente ve "Esperando confirmación..."
11. Comercio acepta → "Tu pedido está en preparación 🍳"
12. Repartidor asignado → ve nombre y foto del repartidor
13. Repartidor recoge → "En camino 🛵" + mapa con posición
14. Repartidor llega → "¡Tu pedido llegó!"
15. Entregado → pantalla de calificación (opcional, skip fácil)
```

**Flujos alternativos:**
- `10a` Comercio no confirma en 10 min → auto-cancelado, pago digital reembolsado, notificación al cliente
- `10b` Comercio rechaza con motivo → cliente notificado, puede pedir a otro comercio
- `12a` No hay repartidores disponibles → pedido en cola, ETA ajustado, cliente puede cancelar sin costo

### CU-02: Gestionar Pedido (Comercio)

**Actor:** Operador de comercio (puede ser el dueño o un empleado)

```
1. Suena el timbre fuerte en el celular/tablet del local
2. Pantalla grande: detalle del pedido (productos, nombres, dirección, método de pago)
3. Toca ACEPTAR → selecciona tiempo: 10 / 20 / 30 / 45 min
4. Prepara el pedido
5. Toca "LISTO PARA ENTREGAR" → repartidor recibe notificación
6. Repartidor llega, confirma recogida
7. En el resumen del día se suma la venta; si fue efectivo, la comisión se registra en ledger de deuda
```

**Flujo alternativo:**
- `3a` Toca RECHAZAR → elige motivo (agotado, cerrado, muy ocupado) → cliente notificado automáticamente

### CU-03: Entregar un Pedido (Repartidor)

**Actor:** Repartidor verificado con app activa y GPS encendido

```
1. Toggle a DISPONIBLE
2. Suena notificación: ve comercio, dirección cliente, ganancia estimada
3. ACEPTAR (3 minutos para decidir)
4. Botón NAVEGAR → abre Google Maps con el comercio como destino
5. Llega al comercio → toca "LLEGUÉ AL LOCAL"
6. Recoge el pedido, verifica productos con el vendedor
7. Toca "RECOGÍ EL PEDIDO"
8. Botón NAVEGAR → abre Google Maps con la dirección del cliente
9. Llega al cliente → entrega
10. Si efectivo: pantalla muestra COBRA $X / ENTREGA AL LOCAL $Y / TU GANANCIA $Z en grande
11. Toca "ENTREGUÉ EL PEDIDO" → opcional: foto
12. Ganancia se acredita en su wallet (si fue pago digital) o ya tiene el efectivo en mano
```

### CU-04: Onboarding de Vendedor Informal (Tier 1)

**Actor:** Persona que vende postres desde casa, sin experiencia digital

```
1. Descarga app (o entra al link enviado por WhatsApp)
2. Registro: número de celular → OTP por WhatsApp
3. Wizard de 5 pasos:
   Paso 1: "¿Cómo se llama tu negocio?" + foto del logo o producto
   Paso 2: "¿Qué vendes?" → selecciona categoría con íconos (comida, postres, bebidas...)
   Paso 3: "Agrega tu primer producto" → nombre + precio + foto del celular
   Paso 4: "¿A qué barrios entregas?" → selecciona en lista o dibuja en mapa
   Paso 5: "¿Cómo cobras?" → efectivo y/o tarjeta (la plataforma explica que puede cobrar con tarjeta)
4. Perfil creado → aparece en la plataforma como "Vendedor local verificado"
5. Cuando llega su primer pedido: WhatsApp con el detalle + notificación en app
```

### CU-05: Gestión de Deuda Acumulada (Vendedor)

**Actor:** Vendedor con ventas en efectivo que se acerca al tope de deuda

```
1. Sistema detecta deuda acumulada ≥ $7.00 → envía notificación de alerta
2. Vendedor abre módulo "Mi Cuenta" → ve saldo en rojo: "Debes $8.50 en comisiones"
3. Toca botón "Pagar ahora con De Una"
4. Redirigido a flujo De Una → paga $8.50
5. Sistema recibe webhook → deuda = $0 → tienda se reactiva automáticamente
6. Vendedor recibe confirmación: "Tu tienda está activa. ¡Gracias!"
```

---

## 10. Reglas de Negocio (RN)

| ID | Regla |
|---|---|
| RN-01 | Un pedido contiene productos de un único comercio |
| RN-02 | Repartidor: máximo 1 pedido activo simultáneo en MVP (fase 2: pedidos encadenados) |
| RN-03 | Comercio tiene 10 minutos para confirmar; sin respuesta → auto-cancelado + notificación al cliente |
| RN-04 | Repartidor tiene 3 minutos para aceptar asignación; sin respuesta → reasignado al siguiente disponible más cercano |
| RN-05 | Repartidor con calificación < 3.5 en últimas 20 entregas → suspensión automática + revisión de admin |
| RN-06 | Reembolso automático solo si: comercio rechaza, comercio no confirma en tiempo, o falla de pago. No aplica por "no me gustó el sabor" |
| RN-07 | Pedidos con pago digital deben completarse en < 30 minutos o el pago se revierte |
| RN-08 | **Tope de Deuda:** Si un comercio acumula > $10.00 en comisiones impagas por ventas en efectivo, su tienda se oculta automáticamente de la app hasta que el vendedor realice un abono por De Una |
| RN-09 | **Compensación Prioritaria:** Toda liquidación digital (T+1) descuenta automáticamente la deuda acumulada por ventas en efectivo antes de depositar el neto al vendedor |
| RN-10 | Alerta de deuda al 70% del tope ($7.00): notificación push + WhatsApp al vendedor |
| RN-11 | Un cliente con > 3 cancelaciones pagadas en 30 días recibe advertencia; > 5 → bloqueo temporal |
| RN-12 | Comisión se calcula sobre subtotal de productos únicamente; el costo de delivery no genera comisión |
| RN-13 | **Efectivo:** La plataforma no retiene ningún porcentaje del efectivo en el momento de la entrega física. El repartidor entrega 100% al vendedor. La comisión queda como deuda en el ledger |
| RN-14 | Tarjeta: Kushki hace el cobro al confirmar el pedido (no al entregarlo). Si se cancela antes de preparación → reembolso en 3–5 días hábiles |
| RN-15 | Vendedor Tier 1 con > $750 en transacciones digitales en el mes → alerta de acercamiento al límite de $800 y guía de formalización RISE |

---

## 11. Restricciones del Proyecto

| Tipo | Restricción |
|---|---|
| **Geografía** | Fase 1: perímetro urbano de Zamora (~5 km del parque central) |
| **Conectividad** | Funcional con 3G mínimo; degradar gracefully sin internet |
| **Pagos MVP** | Kushki (tarjetas crédito/débito) + De Una (Banco Pichincha). Otros métodos en fases posteriores |
| **Kushki merchant account** | La plataforma abre cuenta merchant con Kushki a nombre de la empresa/persona jurídica propietaria. Vendedores no necesitan cuenta propia |
| **Idioma** | Solo español |
| **Plataforma móvil** | Android prioritario; iOS fase 2 |
| **Infraestructura** | Railway/Render inicial (~$25/mes); migración a AWS cuando el tráfico lo justifique |

---

## 12. Preguntas Abiertas (a responder antes de Fase 0)

| # | Pregunta | Impacto |
|---|---|---|
| Q1 | ¿Tienes contacto con Banco de Loja para explorar integración de su app de pagos? | Medio — si no hay API, es transferencia manual en MVP |
| Q2 | ¿Puedes ir presencialmente a onboardear a los primeros comercios? El apoyo humano en Zamora es clave para vencer la resistencia tecnológica | ALTO |
| Q3 | ¿Los primeros repartidores son conocidos tuyos? La fase piloto requiere repartidores de confianza que soporten errores iniciales | ALTO |
| Q4 | ¿Tienes presupuesto para los primeros meses de Kushki? Cobran $0.30 + 3.5% por transacción con tarjeta | Bajo — pero hay que tenerlo claro |
| Q5 | ¿El tope de deuda de $10.00 para ocultar tienda es el correcto, o conviene subirlo a $15 para reducir fricciones iniciales? | Medio — afecta la experiencia del vendedor informal |
| Q6 | ¿La tarifa de servicio al cliente ($0.15–$0.25) es visible o está absorbida en el precio de delivery? | Medio — afecta la percepción de precio del cliente |
| Q7 | ¿Cómo manejar el caso de un vendedor cuya tienda se oculta por deuda y no tiene De Una? ¿Aceptar otra forma de pago de deuda? | ALTO — puede bloquear a vendedores Tier 1 |

---

## 13. Criterios de Aceptación del MVP

- [ ] Cliente se registra con teléfono (OTP WhatsApp), hace pedido con tarjeta de crédito y rastrea en tiempo real
- [ ] Vendedor informal (Tier 1) crea su perfil desde el celular en < 10 minutos y recibe primer pedido
- [ ] Vendedor informal Tier 1 recibe un pago en tarjeta (procesado por la app) y su dinero neto llega a su cuenta bancaria en T+1
- [ ] Pedido en efectivo funciona end-to-end con Ledger de Deuda: comisión se registra correctamente sin retener nada al momento de la entrega
- [ ] Bloqueo automático funcional: tienda se oculta al superar $10.00 de deuda acumulada y se reactiva tras pago
- [ ] Compensación cruzada funcional: liquidación digital descuenta deuda de efectivo antes de depositar neto
- [ ] Módulo "Mi Cuenta" muestra saldo/deuda correcto en tiempo real con botón de pago vía De Una
- [ ] Comercio formal recibe notificación de audio, confirma pedido con 1 tap, ve resumen del día
- [ ] Repartidor acepta asignación, navega con Google Maps integrado, ve pantalla explícita de COBRA/ENTREGA/GANANCIA en efectivo, confirma entrega con foto
- [ ] Pago con tarjeta (Kushki) funcional en producción end-to-end con reembolso probado
- [ ] Pago De Una funcional con webhook de confirmación
- [ ] Tarifa de servicio al cliente ($0.15–$0.25) aparece en carrito y se cobra correctamente
- [ ] Admin ve todos los pedidos activos en mapa en tiempo real
- [ ] Admin ve ledger de deudas por comercio y puede ver qué tiendas están ocultas
- [ ] Notificaciones push y WhatsApp funcionan para los 3 actores
- [ ] Panel de comercio funciona correctamente en Chrome móvil (Samsung Galaxy gama media)
- [ ] Al menos 3 comercios reales onboarded (incluyendo 1 vendedor informal Tier 1)
- [ ] Al menos 2 repartidores reales verificados y capacitados
- [ ] Sistema aguanta 50 pedidos simultáneos sin degradación medible
