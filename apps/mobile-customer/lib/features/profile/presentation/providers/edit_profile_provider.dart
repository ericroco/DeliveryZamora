import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';

// Dependencias
final dioProvider = Provider<Dio>((ref) => Dio());

final profileDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(ref.read(dioProvider));
});

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepositoryImpl(ref.read(profileDataSourceProvider));
});

final getProfileProvider = Provider((ref) {
  return GetProfile(ref.read(profileRepositoryProvider));
});

final editProfileUseCaseProvider = Provider((ref) {
  return EditProfile(ref.read(profileRepositoryProvider));
});

// Notifier
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileEntity>> {
  final GetProfile _getProfile;
  final EditProfile _editProfile;

  ProfileNotifier(this._getProfile, this._editProfile) : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(String name, String email, String avatarUrl) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      final updatedProfile = await _editProfile(name, email, avatarUrl);
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = previousState; // Revert on failure
      // Optionally handle error logic
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileEntity>>((ref) {
  return ProfileNotifier(
    ref.read(getProfileProvider),
    ref.read(editProfileUseCaseProvider),
  );
});
