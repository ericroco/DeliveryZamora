import '../entities/address_entity.dart';
import '../repositories/addresses_repository.dart';

class GetAddresses {
  final AddressesRepository repository;

  GetAddresses(this.repository);

  Future<List<AddressEntity>> call() async {
    return await repository.getAddresses();
  }
}
