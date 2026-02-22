class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String storageBaseUrl = 'http://10.0.2.2:8000/storage/';
}