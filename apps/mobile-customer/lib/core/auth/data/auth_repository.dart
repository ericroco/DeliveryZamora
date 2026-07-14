import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_customer/core/auth/domain/token_pair.dart';
import 'package:mobile_customer/core/auth/domain/user_profile.dart';
import 'package:mobile_customer/core/constants/api_constants.dart';

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

class AuthRepository {
  AuthRepository()
      : _dio = Dio(BaseOptions(baseUrl: kBaseUrl)),
        _storage = const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<String?> _readToken(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _storage.read(key: key);
  }

  Future<void> _writeToken(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  Future<void> _deleteToken(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _storage.delete(key: key);
    }
  }

  Future<UserProfile> login(String phone, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    final tokens = TokenPair.fromJson(res.data!);
    await _saveTokens(tokens);
    return _fetchMe(tokens.accessToken);
  }

  Future<UserProfile> register(String phone, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'phone': phone, 'password': password, 'role': 'CLIENT'},
    );
    final tokens = TokenPair.fromJson(res.data!);
    await _saveTokens(tokens);
    return _fetchMe(tokens.accessToken);
  }

  Future<UserProfile?> restoreSession() async {
    final access = await _readToken(_kAccessToken);
    if (access == null) return null;
    try {
      return await _fetchMe(access);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return _tryRefresh();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final refresh = await _readToken(_kRefreshToken);
    final access = await _readToken(_kAccessToken);
    if (refresh != null && access != null) {
      try {
        await _dio.post<void>(
          '/auth/logout',
          data: {'refreshToken': refresh},
          options: Options(headers: {'Authorization': 'Bearer $access'}),
        );
      } on DioException {
        // best-effort — clear local state regardless
      }
    }
    await _clearTokens();
  }

  Future<String?> getAccessToken() => _readToken(_kAccessToken);

  Future<UserProfile?> _tryRefresh() async {
    final refresh = await _readToken(_kRefreshToken);
    if (refresh == null) return null;
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      final tokens = TokenPair.fromJson(res.data!);
      await _saveTokens(tokens);
      return _fetchMe(tokens.accessToken);
    } on DioException {
      await _clearTokens();
      return null;
    }
  }

  Future<UserProfile> _fetchMe(String accessToken) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserProfile.fromJson(res.data!);
  }

  Future<void> _saveTokens(TokenPair tokens) async {
    await Future.wait([
      _writeToken(_kAccessToken, tokens.accessToken),
      _writeToken(_kRefreshToken, tokens.refreshToken),
    ]);
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      _deleteToken(_kAccessToken),
      _deleteToken(_kRefreshToken),
    ]);
  }
}
