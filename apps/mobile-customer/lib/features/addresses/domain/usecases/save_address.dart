import '../entities/address_entity.dart';
import '../repositories/addresses_repository.dart';

class SaveAddress {
  final AddressesRepository repository;

  SaveAddress(this.repository);

  Future<AddressEntity> call(AddressEntity address) async {
    return await repository.saveAddress(address);
  }
}
