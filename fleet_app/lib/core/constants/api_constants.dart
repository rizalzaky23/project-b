class ApiConstants {
  // Azure VM - digunakan untuk semua platform
  static const String _azureBaseUrl = 'http://20.39.196.239/api';
  // Base URL untuk file storage (tanpa /api)
  static const String storageUrl = 'http://20.39.196.239/storage';

  static String get baseUrl => _azureBaseUrl;

  /// Konversi path relatif dari API menjadi URL lengkap.
  /// Jika sudah berupa URL lengkap (http/https), dikembalikan apa adanya.
  static String? resolveFileUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    // Hapus leading slash jika ada
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return 'http://20.39.196.239/$clean';
  }

  // Gunakan int biasa, bukan const, karena baseUrl sudah getter
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
