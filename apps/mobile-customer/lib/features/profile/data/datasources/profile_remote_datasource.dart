import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> editProfile(String name, String email, String avatarUrl);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileModel _mockProfile = ProfileModel(
    id: 'user_123',
    name: 'Juan Pérez',
    email: 'juan.perez@example.com',
    avatarUrl: 'https://i.pravatar.cc/300',
  );

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<ProfileModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockProfile;
  }

  @override
  Future<ProfileModel> editProfile(String name, String email, String avatarUrl) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockProfile = ProfileModel(
      id: _mockProfile.id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
    return _mockProfile;
  }
}
