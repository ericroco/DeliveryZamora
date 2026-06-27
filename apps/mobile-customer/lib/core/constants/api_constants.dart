import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

String get kBaseUrl {
  const String envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (envUrl.isNotEmpty) return envUrl;

  if (kIsWeb) {
    return 'http://localhost:3000/api/v1';
  }
  
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api/v1'; 
  }
  
  return 'http://localhost:3000/api/v1'; 
}

class ApiEndpoints {
  // Notifications
  static const String notifications = '/notifications';
  static String readNotification(String id) => '/notifications/$id/read';

  // Profile
  static const String profile = '/clients/profile';

  // Addresses
  static const String addresses = '/clients/addresses';
  static String addressAction(String id) => '/clients/addresses/$id';
}
