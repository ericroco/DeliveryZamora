import '../repositories/addresses_repository.dart';

class DeleteAddress {
  final AddressesRepository repository;

  DeleteAddress(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteAddress(id);
  }
}
