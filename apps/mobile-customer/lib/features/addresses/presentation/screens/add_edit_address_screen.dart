import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../domain/entities/address_entity.dart';
import '../providers/addresses_provider.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final AddressEntity? addressToEdit;

  const AddEditAddressScreen({super.key, this.addressToEdit});

  @override
  ConsumerState<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  MapLibreMapController? _mapController;
  LatLng _selectedLocation = const LatLng(-4.0679, -78.9498); // Zamora, Ecuador
  
  final _nameController = TextEditingController();
  final _detailsController = TextEditingController();
  final _addressTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.addressToEdit != null) {
      _selectedLocation = LatLng(widget.addressToEdit!.latitude, widget.addressToEdit!.longitude);
      _nameController.text = widget.addressToEdit!.name;
      _detailsController.text = widget.addressToEdit!.details;
      _addressTextController.text = widget.addressToEdit!.fullAddress;
    }
  }

  // Estilo Dark Matter de CARTO (usado por mapcn para el tema oscuro)
  final String _cartoStyle = 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.addressToEdit != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Mapa con MapLibre GL
          MapLibreMap(
            initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 15),
            styleString: _cartoStyle,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onCameraIdle: () {
              if (_mapController != null) {
                // Actualizar ubicación al centro
                _selectedLocation = _mapController!.cameraPosition!.target;
              }
            },
            myLocationEnabled: true,
            compassEnabled: false,
          ),
          
          // Marcador Central Fijo
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35.0),
              child: Icon(Icons.location_pin, size: 40, color: Colors.black),
            ),
          ),

          // Controles flotantes estilo mapcn / shadcn
          Positioned(
            right: 16,
            bottom: 300,
            child: Column(
              children: [
                _buildMapControl(Icons.my_location, () {
                  //TODO: get user location plugin
                }, theme),
                const SizedBox(height: 8),
                _buildMapControl(Icons.add, () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                }, theme),
                const SizedBox(height: 8),
                _buildMapControl(Icons.remove, () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                }, theme),
              ],
            ),
          ),

          // Panel inferior estilo bottom sheet persistente
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'Editar Dirección' : 'Nueva Dirección',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre (ej: Casa, Trabajo)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressTextController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección completa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _detailsController,
                    decoration: const InputDecoration(
                      labelText: 'Detalles (Piso, Puerta, Referencia)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: _saveAddress,
                    child: Text(isEditing ? 'Guardar Cambios' : 'Guardar Dirección'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onTap,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  void _saveAddress() {
    final entity = AddressEntity(
      id: widget.addressToEdit?.id ?? '',
      name: _nameController.text.isNotEmpty ? _nameController.text : 'Mi Dirección',
      fullAddress: _addressTextController.text.isNotEmpty ? _addressTextController.text : 'Ubicación en mapa',
      details: _detailsController.text,
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      isFavorite: widget.addressToEdit?.isFavorite ?? false,
    );

    ref.read(addressesProvider.notifier).saveAddress(entity);
    context.pop();
  }
}
