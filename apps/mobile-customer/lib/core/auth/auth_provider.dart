import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_customer/core/auth/data/auth_repository.dart';
import 'package:mobile_customer/core/auth/domain/user_profile.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, UserProfile?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    return ref.read(authRepositoryProvider).restoreSession();
  }

  Future<void> login(String phone, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(phone, password),
    );
  }

  Future<void> register(String phone, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(phone, password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
