import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/addresses_repository.dart';
import '../datasources/addresses_remote_datasource.dart';
import '../models/address_model.dart';

class AddressesRepositoryImpl implements AddressesRepository {
  final AddressesRemoteDataSource remoteDataSource;

  AddressesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AddressEntity>> getAddresses() async {
    return await remoteDataSource.getAddresses();
  }

  @override
  Future<void> deleteAddress(String id) async {
    return await remoteDataSource.deleteAddress(id);
  }

  @override
  Future<void> markAsFavorite(String id) async {
    return await remoteDataSource.markAsFavorite(id);
  }

  @override
  Future<AddressEntity> saveAddress(AddressEntity address) async {
    final model = AddressModel.fromEntity(address);
    return await remoteDataSource.saveAddress(model);
  }
}
