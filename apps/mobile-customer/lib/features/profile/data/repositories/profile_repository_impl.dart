import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<ProfileEntity> editProfile(String name, String email, String avatarUrl) async {
    return await remoteDataSource.editProfile(name, email, avatarUrl);
  }
}
