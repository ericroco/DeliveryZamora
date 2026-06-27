import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class EditProfile {
  final ProfileRepository repository;

  EditProfile(this.repository);

  Future<ProfileEntity> call(String name, String email, String avatarUrl) async {
    return await repository.editProfile(name, email, avatarUrl);
  }
}

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<ProfileEntity> call() async {
    return await repository.getProfile();
  }
}
