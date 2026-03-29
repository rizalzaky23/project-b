import 'api_constants_stub.dart'
    if (dart.library.io) 'api_constants_io.dart';

class ApiConstants {
  static String get baseUrl => getBaseUrl();

  static String get _storageBaseUrl {
    // Ambil base host dari baseUrl (hapus '/api' di akhir)
    return baseUrl.replaceAll('/api', '');
  }

  static String? photoUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    // Jika sudah URL lengkap, kembalikan apa adanya
    if (path.startsWith('http')) return path;
    // Tambahkan base host (tanpa /api)
    return '$_storageBaseUrl$path';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String login    = '/auth/login';
  static const String logout   = '/auth/logout';
  static const String me       = '/auth/me';
  static const String register = '/auth/register';

  static const String kendaraan         = '/kendaraan';
  static const String detailKendaraan   = '/detail-kendaraan';
  static const String asuransiKendaraan = '/asuransi-kendaraan';
  static const String kejadianKendaraan = '/kejadian-kendaraan';
  static const String penyewaan         = '/penyewaan';
  static const String servisKendaraan   = '/servis-kendaraan';
}
