import '../entities/address_entity.dart';

abstract class AddressesRepository {
  Future<List<AddressEntity>> getAddresses();
  Future<AddressEntity> saveAddress(AddressEntity address);
  Future<void> deleteAddress(String id);
  Future<void> markAsFavorite(String id);
}
