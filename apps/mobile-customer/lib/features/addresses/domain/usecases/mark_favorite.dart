import '../repositories/addresses_repository.dart';

class MarkFavorite {
  final AddressesRepository repository;

  MarkFavorite(this.repository);

  Future<void> call(String id) async {
    return await repository.markAsFavorite(id);
  }
}
