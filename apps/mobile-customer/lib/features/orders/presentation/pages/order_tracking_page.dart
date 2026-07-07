import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/features/orders/domain/entities/order.dart';
import 'package:mobile_customer/features/orders/presentation/providers/order_tracking_provider.dart';

// Fallback coordinates (Zamora, Ecuador) — used when store coords are unavailable.
const _kFallbackStoreLng = LatLng(-4.0679, -78.9498);
const _kFallbackCustomerLatLng = LatLng(-4.0720, -78.9450);

class OrderTrackingPage extends ConsumerStatefulWidget {
  const OrderTrackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
  GoogleMapController? _mapCtrl;

  // Track the previous driver position so we can animate the camera smoothly.
  LatLng? _lastRiderLatLng;

  @override
  void dispose() {
    _mapCtrl?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController ctrl) {
    _mapCtrl = ctrl;
  }

  void _fitMapBounds(LatLng store, LatLng customer) {
    _mapCtrl?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            math.min(store.latitude, customer.latitude) - 0.002,
            math.min(store.longitude, customer.longitude) - 0.002,
          ),
          northeast: LatLng(
            math.max(store.latitude, customer.latitude) + 0.002,
            math.max(store.longitude, customer.longitude) + 0.002,
          ),
        ),
        60,
      ),
    );
  }

  void _animateCameraToPoint(LatLng point) {
    _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
  }

  @override
  Widget build(BuildContext context) {
    final asyncOrder = ref.watch(trackingProvider(widget.orderId));

    return asyncOrder.when(
      loading: () => const _LoadingScaffold(),
      error: (err, _) => _ErrorScaffold(
        onRetry: () => ref.read(trackingProvider(widget.orderId).notifier).refresh(),
      ),
      data: (order) => _TrackingScaffold(
        order: order,
        mapCtrl: _mapCtrl,
        onMapCreated: _onMapCreated,
        onFitBounds: _fitMapBounds,
        onAnimateToPoint: _animateCameraToPoint,
        lastRiderLatLng: _lastRiderLatLng,
        onRiderLatLngUpdated: (latlng) => _lastRiderLatLng = latlng,
      ),
    );
  }
}

// ── Scaffold variants ──────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Tu pedido',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Cargando tu pedido…',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Tu pedido',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.caseroBorder),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar el pedido',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Verifica tu conexión e intenta de nuevo.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Main scaffold with real data ───────────────────────────────────────────────

class _TrackingScaffold extends StatefulWidget {
  const _TrackingScaffold({
    required this.order,
    required this.mapCtrl,
    required this.onMapCreated,
    required this.onFitBounds,
    required this.onAnimateToPoint,
    required this.lastRiderLatLng,
    required this.onRiderLatLngUpdated,
  });

  final Order order;
  final GoogleMapController? mapCtrl;
  final void Function(GoogleMapController) onMapCreated;
  final void Function(LatLng store, LatLng customer) onFitBounds;
  final void Function(LatLng point) onAnimateToPoint;
  final LatLng? lastRiderLatLng;
  final void Function(LatLng) onRiderLatLngUpdated;

  @override
  State<_TrackingScaffold> createState() => _TrackingScaffoldState();
}

class _TrackingScaffoldState extends State<_TrackingScaffold> {
  bool _mapReady = false;

  LatLng get _storeLatLng => widget.order.storeLat != null && widget.order.storeLng != null
      ? LatLng(widget.order.storeLat!, widget.order.storeLng!)
      : _kFallbackStoreLng;

  LatLng get _customerLatLng => _kFallbackCustomerLatLng; // TODO: parse from deliveryAddress geocoding

  LatLng? get _riderLatLng {
    final lat = widget.order.driverLat;
    final lng = widget.order.driverLng;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  @override
  void didUpdateWidget(_TrackingScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newRider = _riderLatLng;
    final delivered = widget.order.status == OrderStatus.delivered;

    if (newRider != null && newRider != widget.lastRiderLatLng) {
      widget.onRiderLatLngUpdated(newRider);
      widget.onAnimateToPoint(newRider);
    }

    if (delivered && !_mapReady) {
      widget.onAnimateToPoint(_customerLatLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final delivered = order.status == OrderStatus.delivered;
    final cancelled = order.status == OrderStatus.cancelled;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Tu pedido',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        leading: (delivered || cancelled)
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/'),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _StatusCard(status: order.status),
            const SizedBox(height: 16),
            _TrackingMap(
              status: order.status,
              storeLatLng: _storeLatLng,
              customerLatLng: _customerLatLng,
              riderLatLng: _riderLatLng,
              onMapCreated: (ctrl) {
                widget.onMapCreated(ctrl);
                setState(() => _mapReady = true);
                widget.onFitBounds(_storeLatLng, _customerLatLng);
              },
            ),
            const SizedBox(height: 16),
            _StatusTimeline(currentStatus: order.status),
            const SizedBox(height: 16),
            _DriverCard(
              driverName: order.driverName,
              vehicleType: order.driverVehicleType,
              plate: order.driverPlate,
            ),
            const SizedBox(height: 24),
            if (delivered || cancelled)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.go('/'),
                  style: FilledButton.styleFrom(
                    backgroundColor: delivered ? AppColors.accent : AppColors.muted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    delivered ? 'Volver al inicio' : 'Cerrar',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Map ────────────────────────────────────────────────────────────────────────

class _TrackingMap extends StatelessWidget {
  const _TrackingMap({
    required this.status,
    required this.storeLatLng,
    required this.customerLatLng,
    required this.riderLatLng,
    required this.onMapCreated,
  });

  final OrderStatus status;
  final LatLng storeLatLng;
  final LatLng customerLatLng;
  final LatLng? riderLatLng;
  final void Function(GoogleMapController) onMapCreated;

  @override
  Widget build(BuildContext context) {
    final showRider = (status == OrderStatus.onTheWay || status == OrderStatus.delivered) &&
        riderLatLng != null;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('store'),
        position: storeLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Restaurante'),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: customerLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Tu dirección'),
      ),
      if (showRider)
        Marker(
          markerId: const MarkerId('rider'),
          position: riderLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(title: 'Repartidor'),
        ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: [storeLatLng, customerLatLng],
        color: AppColors.primary,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              (storeLatLng.latitude + customerLatLng.latitude) / 2,
              (storeLatLng.longitude + customerLatLng.longitude) / 2,
            ),
            zoom: 14.5,
          ),
          markers: markers,
          polylines: polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ),
      ),
    );
  }
}

// ── Status card ────────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final OrderStatus status;

  static const _icons = {
    OrderStatus.confirmed: Icons.check_circle_outline,
    OrderStatus.preparing: Icons.restaurant_outlined,
    OrderStatus.ready: Icons.inventory_2_outlined,
    OrderStatus.onTheWay: Icons.two_wheeler,
    OrderStatus.delivered: Icons.celebration_outlined,
    OrderStatus.cancelled: Icons.cancel_outlined,
  };

  static const _messages = {
    OrderStatus.confirmed: '¡Pedido confirmado!',
    OrderStatus.preparing: 'Preparando tu pedido',
    OrderStatus.ready: 'Pedido listo — esperando repartidor',
    OrderStatus.onTheWay: 'El repartidor está en camino',
    OrderStatus.delivered: '¡Pedido entregado!',
    OrderStatus.cancelled: 'Pedido cancelado',
  };

  @override
  Widget build(BuildContext context) {
    final delivered = status == OrderStatus.delivered;
    final cancelled = status == OrderStatus.cancelled;

    Color bgColor;
    if (cancelled) {
      bgColor = AppColors.muted;
    } else if (delivered) {
      bgColor = AppColors.accent;
    } else {
      bgColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _icons[status] ?? Icons.hourglass_empty,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _messages[status] ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  delivered
                      ? 'Califica tu experiencia'
                      : cancelled
                          ? 'Contacta al soporte si necesitas ayuda'
                          : 'Estimado: ~15 min',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timeline ───────────────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.currentStatus});

  final OrderStatus currentStatus;

  static const _steps = [
    (status: OrderStatus.confirmed, label: 'Confirmado'),
    (status: OrderStatus.preparing, label: 'Preparando'),
    (status: OrderStatus.ready, label: 'Listo'),
    (status: OrderStatus.onTheWay, label: 'En camino'),
    (status: OrderStatus.delivered, label: 'Entregado'),
  ];

  bool _isDone(OrderStatus s) {
    final currentIdx = _steps.indexWhere((e) => e.status == currentStatus);
    final stepIdx = _steps.indexWhere((e) => e.status == s);
    if (currentIdx < 0 || stepIdx < 0) return false;
    return stepIdx <= currentIdx;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftDone = _isDone(_steps[i ~/ 2].status);
            return Expanded(
              child: Container(
                height: 2,
                color: leftDone ? AppColors.primary : AppColors.caseroBorder,
              ),
            );
          }
          final step = _steps[i ~/ 2];
          final done = _isDone(step.status);
          final active = step.status == currentStatus;
          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done ? AppColors.primary : AppColors.caseroBorder,
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(color: AppColors.primary, width: 3)
                      : null,
                ),
                child: Icon(
                  Icons.check,
                  size: 14,
                  color: done ? Colors.white : AppColors.caseroBorder,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: done ? AppColors.text : AppColors.muted,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Driver card ────────────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    this.driverName,
    this.vehicleType,
    this.plate,
  });

  final String? driverName;
  final String? vehicleType;
  final String? plate;

  @override
  Widget build(BuildContext context) {
    final hasDriver = driverName != null;
    final vehicleLabel =
        (vehicleType != null && plate != null) ? '$vehicleType • $plate' : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: hasDriver
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      if (vehicleLabel != null)
                        Text(
                          vehicleLabel,
                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                    ],
                  )
                : const Text(
                    'Esperando asignación de repartidor…',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
          ),
          if (hasDriver)
            IconButton(
              onPressed: () {/* TODO: launch phone dialer */},
              icon: const Icon(Icons.phone_outlined),
              color: AppColors.primary,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.caseroBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
