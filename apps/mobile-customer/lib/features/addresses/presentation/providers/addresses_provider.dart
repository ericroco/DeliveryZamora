import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/get_addresses.dart';
import '../../domain/usecases/save_address.dart';
import '../../domain/usecases/delete_address.dart';
import '../../domain/usecases/mark_favorite.dart';
import '../../data/datasources/addresses_remote_datasource.dart';
import '../../data/repositories/addresses_repository_impl.dart';

// Dependencias
final dioProvider = Provider<Dio>((ref) => Dio());

final addressesDataSourceProvider = Provider<AddressesRemoteDataSource>((ref) {
  return AddressesRemoteDataSourceImpl(ref.read(dioProvider));
});

final addressesRepositoryProvider = Provider((ref) {
  return AddressesRepositoryImpl(ref.read(addressesDataSourceProvider));
});

final getAddressesProvider = Provider((ref) {
  return GetAddresses(ref.read(addressesRepositoryProvider));
});

final saveAddressProvider = Provider((ref) {
  return SaveAddress(ref.read(addressesRepositoryProvider));
});

final deleteAddressProvider = Provider((ref) {
  return DeleteAddress(ref.read(addressesRepositoryProvider));
});

final markFavoriteProvider = Provider((ref) {
  return MarkFavorite(ref.read(addressesRepositoryProvider));
});

// Notifier
class AddressesNotifier extends StateNotifier<AsyncValue<List<AddressEntity>>> {
  final GetAddresses _getAddresses;
  final SaveAddress _saveAddress;
  final DeleteAddress _deleteAddress;
  final MarkFavorite _markFavorite;

  AddressesNotifier(
    this._getAddresses,
    this._saveAddress,
    this._deleteAddress,
    this._markFavorite,
  ) : super(const AsyncValue.loading()) {
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    state = const AsyncValue.loading();
    try {
      final addresses = await _getAddresses();
      state = AsyncValue.data(addresses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveAddress(AddressEntity address) async {
    try {
      final newAddress = await _saveAddress(address);
      if (state.value != null) {
        final currentList = List<AddressEntity>.from(state.value!);
        final index = currentList.indexWhere((a) => a.id == newAddress.id);
        if (index >= 0) {
          currentList[index] = newAddress;
        } else {
          currentList.add(newAddress);
        }
        state = AsyncValue.data(currentList);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _deleteAddress(id);
      if (state.value != null) {
        final currentList = List<AddressEntity>.from(state.value!);
        currentList.removeWhere((a) => a.id == id);
        state = AsyncValue.data(currentList);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAsFavorite(String id) async {
    try {
      await _markFavorite(id);
      if (state.value != null) {
        final currentList = List<AddressEntity>.from(state.value!);
        for (int i = 0; i < currentList.length; i++) {
          currentList[i] = currentList[i].copyWith(
            isFavorite: currentList[i].id == id,
          );
        }
        state = AsyncValue.data(currentList);
      }
    } catch (e) {
      // Handle error
    }
  }
}

final addressesProvider = StateNotifierProvider<AddressesNotifier, AsyncValue<List<AddressEntity>>>((ref) {
  return AddressesNotifier(
    ref.read(getAddressesProvider),
    ref.read(saveAddressProvider),
    ref.read(deleteAddressProvider),
    ref.read(markFavoriteProvider),
  );
});
