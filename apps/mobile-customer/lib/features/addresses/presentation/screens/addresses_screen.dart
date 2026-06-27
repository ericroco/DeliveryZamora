import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/addresses_provider.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesState = ref.watch(addressesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Direcciones'),
      ),
      body: addressesState.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return const Center(child: Text('No tienes direcciones guardadas.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(
                    address.isFavorite ? Icons.star : Icons.location_on_outlined,
                    color: address.isFavorite ? Colors.orange : theme.colorScheme.primary,
                  ),
                  title: Text(address.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${address.fullAddress}\n${address.details}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push('/addresses/add', extra: address);
                      } else if (value == 'delete') {
                        ref.read(addressesProvider.notifier).deleteAddress(address.id);
                      } else if (value == 'favorite') {
                        ref.read(addressesProvider.notifier).markAsFavorite(address.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'favorite', child: Text('Marcar Favorita')),
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/addresses/add'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Dirección'),
      ),
    );
  }
}
