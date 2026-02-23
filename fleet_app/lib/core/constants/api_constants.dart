import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import: gunakan dart:io hanya di non-web
import 'api_constants_stub.dart'
    if (dart.library.io) 'api_constants_io.dart' as platform_helper;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web: akses langsung ke localhost
      return 'http://127.0.0.1:8000/api';
    }
    // Native (Android, iOS, macOS, Windows, Linux)
    return platform_helper.getBaseUrl();
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Auth
  static const String login    = '/auth/login';
  static const String logout   = '/auth/logout';
  static const String me       = '/auth/me';
  static const String register = '/auth/register';

  // Resources
  static const String kendaraan         = '/kendaraan';
  static const String detailKendaraan   = '/detail-kendaraan';
  static const String asuransiKendaraan = '/asuransi-kendaraan';
  static const String kejadianKendaraan = '/kejadian-kendaraan';
  static const String penyewaan         = '/penyewaan';
}
