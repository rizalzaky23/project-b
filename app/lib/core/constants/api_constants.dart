
class ApiConstants {
  static const String _azureBaseUrl = 'http://20.39.196.239/api';
  static const String _storageBaseUrl = 'http://20.39.196.239';

  static String get baseUrl => _azureBaseUrl;

  static String? photoUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.contains('localhost')) {
      path = path.replaceAll('http://localhost', _storageBaseUrl);
      path = path.replaceAll('/storage/public/', '/storage/');
    }
    if (path.startsWith('http')) return path;
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
}
