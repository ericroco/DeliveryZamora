import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/features/orders/domain/entities/order.dart';

// Zamora, Ecuador reference coordinates
const _kStoreLatLng = LatLng(-4.0679, -78.9498);   // store origin
const _kCustomerLatLng = LatLng(-4.0720, -78.9450); // delivery destination

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  static const _flow = [
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  int _statusIdx = 0;
  Timer? _statusTimer;
  Timer? _riderTimer;
  double _riderProgress = 0.0; // 0.0 → 1.0 along store→customer path
  GoogleMapController? _mapCtrl;

  @override
  void initState() {
    super.initState();
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_statusIdx < _flow.length - 1) {
        setState(() => _statusIdx++);
        if (_flow[_statusIdx] == OrderStatus.onTheWay) _startRiderAnimation();
        if (_flow[_statusIdx] == OrderStatus.delivered) {
          _riderTimer?.cancel();
          setState(() => _riderProgress = 1.0);
          _animateCameraToCustomer();
        }
      } else {
        _statusTimer?.cancel();
      }
    });
  }

  void _startRiderAnimation() {
    _riderProgress = 0.0;
    _riderTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_riderProgress >= 1.0) {
        _riderTimer?.cancel();
        return;
      }
      setState(() => _riderProgress = math.min(1.0, _riderProgress + 0.012));
    });
  }

  void _animateCameraToCustomer() {
    _mapCtrl?.animateCamera(
      CameraUpdate.newLatLngZoom(_kCustomerLatLng, 16),
    );
  }

  LatLng get _riderLatLng => LatLng(
        _kStoreLatLng.latitude +
            (_kCustomerLatLng.latitude - _kStoreLatLng.latitude) * _riderProgress,
        _kStoreLatLng.longitude +
            (_kCustomerLatLng.longitude - _kStoreLatLng.longitude) * _riderProgress,
      );

  OrderStatus get _currentStatus => _flow[_statusIdx];

  @override
  void dispose() {
    _statusTimer?.cancel();
    _riderTimer?.cancel();
    _mapCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delivered = _currentStatus == OrderStatus.delivered;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Tu pedido',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        leading: delivered
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
            _StatusCard(status: _currentStatus),
            const SizedBox(height: 16),
            _TrackingMap(
              status: _currentStatus,
              riderLatLng: _riderLatLng,
              onMapCreated: (ctrl) {
                _mapCtrl = ctrl;
                ctrl.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: LatLng(
                        math.min(_kStoreLatLng.latitude, _kCustomerLatLng.latitude) - 0.002,
                        math.min(_kStoreLatLng.longitude, _kCustomerLatLng.longitude) - 0.002,
                      ),
                      northeast: LatLng(
                        math.max(_kStoreLatLng.latitude, _kCustomerLatLng.latitude) + 0.002,
                        math.max(_kStoreLatLng.longitude, _kCustomerLatLng.longitude) + 0.002,
                      ),
                    ),
                    60,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _StatusTimeline(currentStatus: _currentStatus),
            const SizedBox(height: 16),
            const _DriverCard(),
            const SizedBox(height: 24),
            if (delivered)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.go('/'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
    required this.riderLatLng,
    required this.onMapCreated,
  });

  final OrderStatus status;
  final LatLng riderLatLng;
  final void Function(GoogleMapController) onMapCreated;

  @override
  Widget build(BuildContext context) {
    final showRider = status == OrderStatus.onTheWay || status == OrderStatus.delivered;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('store'),
        position: _kStoreLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'Restaurante'),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: _kCustomerLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Tu dirección'),
      ),
      if (showRider)
        Marker(
          markerId: const MarkerId('rider'),
          position: riderLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(title: 'Repartidor'),
        ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: const [_kStoreLatLng, _kCustomerLatLng],
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
          initialCameraPosition: const CameraPosition(
            target: LatLng(-4.0700, -78.9474),
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
    OrderStatus.onTheWay: Icons.two_wheeler,
    OrderStatus.delivered: Icons.celebration_outlined,
  };

  static const _messages = {
    OrderStatus.confirmed: '¡Pedido confirmado!',
    OrderStatus.preparing: 'Preparando tu pedido',
    OrderStatus.onTheWay: 'El repartidor está en camino',
    OrderStatus.delivered: '¡Pedido entregado!',
  };

  @override
  Widget build(BuildContext context) {
    final delivered = status == OrderStatus.delivered;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: delivered ? AppColors.accent : AppColors.primary,
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
                  delivered ? 'Califica tu experiencia' : 'Estimado: ~15 min',
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
    (status: OrderStatus.onTheWay, label: 'En camino'),
    (status: OrderStatus.delivered, label: 'Entregado'),
  ];

  bool _isDone(OrderStatus s) {
    final currentIdx = _steps.indexWhere((e) => e.status == currentStatus);
    final stepIdx = _steps.indexWhere((e) => e.status == s);
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
  const _DriverCard();

  @override
  Widget build(BuildContext context) {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carlos Pereira',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  'Honda Wave • BFC-0234',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
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
