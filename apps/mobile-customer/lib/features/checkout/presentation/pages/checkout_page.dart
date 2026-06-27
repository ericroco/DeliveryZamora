import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/features/cart/presentation/providers/cart_provider.dart';

enum _PaymentMethod { card, cash }

const _kZamoraCenter = LatLng(-4.0679, -78.9498);

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _noteCtrl = TextEditingController();
  _PaymentMethod _payment = _PaymentMethod.card;
  bool _loading = false;
  LatLng _deliveryLatLng = _kZamoraCenter;
  String _deliveryAddress = 'Av. del Ejército y Diego de Vaca';

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => _loading = true);
    // TODO: POST /orders with cart items, address, payment method
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    ref.read(cartProvider.notifier).clear();
    setState(() => _loading = false);
    context.go('/orders/tracking/mock-order-id');
  }

  Future<void> _openAddressPicker() async {
    final result = await Navigator.of(context).push<(LatLng, String)>(
      MaterialPageRoute(
        builder: (_) => _AddressPickerPage(
          initial: _deliveryLatLng,
          initialLabel: _deliveryAddress,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _deliveryLatLng = result.$1;
        _deliveryAddress = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = ref.watch(cartTotalProvider) + 1.75;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Confirmar pedido',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: 'Dirección de entrega',
              child: _AddressMapCard(
                latLng: _deliveryLatLng,
                address: _deliveryAddress,
                onEdit: _openAddressPicker,
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Método de pago',
              child: _PaymentSelector(
                selected: _payment,
                onChanged: (v) => setState(() => _payment = v),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Nota para el repartidor (opcional)',
              child: TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ej: Timbre roto, llama al llegar',
                  hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _loading ? null : _placeOrder,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Hacer pedido · \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Address map card ───────────────────────────────────────────────────────────

class _AddressMapCard extends StatefulWidget {
  const _AddressMapCard({
    required this.latLng,
    required this.address,
    required this.onEdit,
  });

  final LatLng latLng;
  final String address;
  final VoidCallback onEdit;

  @override
  State<_AddressMapCard> createState() => _AddressMapCardState();
}

class _AddressMapCardState extends State<_AddressMapCard> {
  GoogleMapController? _ctrl;

  @override
  void didUpdateWidget(covariant _AddressMapCard old) {
    super.didUpdateWidget(old);
    if (old.latLng != widget.latLng) {
      _ctrl?.animateCamera(CameraUpdate.newLatLng(widget.latLng));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onEdit,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            SizedBox(
              height: 140,
                child: IgnorePointer(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.latLng,
                      zoom: 15,
                    ),
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('delivery'),
                        position: widget.latLng,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueOrange,
                        ),
                      ),
                    },
                    onMapCreated: (c) => _ctrl = c,
                  ),
                ),
            ),
            Container(
              color: AppColors.card,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.address,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.caseroBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Cambiar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Full-screen address picker ─────────────────────────────────────────────────

class _AddressPickerPage extends StatefulWidget {
  const _AddressPickerPage({
    required this.initial,
    required this.initialLabel,
  });

  final LatLng initial;
  final String initialLabel;

  @override
  State<_AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends State<_AddressPickerPage> {
  late LatLng _selected;
  GoogleMapController? _ctrl;

  // Mock address labels for Zamora area
  static const _addresses = [
    (pos: LatLng(-4.0679, -78.9498), label: 'Av. del Ejército y Diego de Vaca'),
    (pos: LatLng(-4.0720, -78.9450), label: 'Calle Sevilla de Oro'),
    (pos: LatLng(-4.0650, -78.9510), label: 'Barrio La Playa, Zamora'),
    (pos: LatLng(-4.0700, -78.9530), label: 'Parque Central de Zamora'),
    (pos: LatLng(-4.0740, -78.9460), label: 'Av. 24 de Mayo'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Elige tu dirección',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _selected,
                zoom: 15.5,
              ),
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selected,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
                )
              },
              onMapCreated: (c) => _ctrl = c,
              onCameraMove: (pos) {
                _selected = pos.target;
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                border: Border(
                  top: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Direcciones frecuentes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final addr = _addresses[i];
                        final isSelected = addr.pos == _selected;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.location_on,
                            size: 20,
                            color: isSelected ? AppColors.primary : AppColors.muted,
                          ),
                          title: Text(
                            addr.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.text,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  size: 18, color: AppColors.primary)
                              : null,
                          onTap: () {
                            setState(() => _selected = addr.pos);
                            _ctrl?.animateCamera(
                              CameraUpdate.newLatLngZoom(addr.pos, 15.5),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: () {
                          final label = _addresses
                              .firstWhere(
                                (a) => a.pos == _selected,
                                orElse: () => _addresses.first,
                              )
                              .label;
                          Navigator.of(context).pop((_selected, label));
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirmar dirección',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _PaymentSelector extends StatelessWidget {
  const _PaymentSelector({
    required this.selected,
    required this.onChanged,
  });

  final _PaymentMethod selected;
  final ValueChanged<_PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PaymentOption(
          method: _PaymentMethod.card,
          icon: Icons.credit_card,
          label: 'Tarjeta de débito / crédito',
          subtitle: 'Pago seguro vía Kushki',
          selected: selected == _PaymentMethod.card,
          onTap: () => onChanged(_PaymentMethod.card),
        ),
        const SizedBox(height: 8),
        _PaymentOption(
          method: _PaymentMethod.cash,
          icon: Icons.payments_outlined,
          label: 'Efectivo',
          subtitle: 'Paga al repartidor al recibir',
          selected: selected == _PaymentMethod.cash,
          onTap: () => onChanged(_PaymentMethod.cash),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.method,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final _PaymentMethod method;
  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.caseroBg : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.inputBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.primary : AppColors.text,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
