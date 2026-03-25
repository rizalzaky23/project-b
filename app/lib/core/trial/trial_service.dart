import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mengelola status trial aplikasi.
/// Menyimpan tanggal install pertama di secure storage agar tidak bisa
/// direset hanya dengan hapus cache aplikasi.
class TrialService {
  TrialService._();
  static final TrialService instance = TrialService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyInstallDate = 'fleet_trial_install_date';

  /// Durasi trial dalam hari. Ubah nilai ini sesuai kebutuhan.
  final int trialDays = 30;

  /// Inisialisasi — simpan tanggal install jika belum ada.
  /// Panggil sekali di main() sebelum runApp.
  Future<void> init() async {
    final existing = await _storage.read(key: _keyInstallDate);
    if (existing == null) {
      await _storage.write(
        key: _keyInstallDate,
        value: DateTime.now().toIso8601String(),
      );
    }
  }

  /// Tanggal pertama install.
  Future<DateTime?> getInstallDate() async {
    final raw = await _storage.read(key: _keyInstallDate);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Apakah trial masih aktif.
  Future<bool> isTrialActive() async {
    final installDate = await getInstallDate();
    if (installDate == null) return false;
    final elapsed = DateTime.now().difference(installDate).inDays;
    return elapsed < trialDays;
  }

  /// Sisa hari trial (0 jika sudah habis).
  Future<int> getRemainingDays() async {
    final installDate = await getInstallDate();
    if (installDate == null) return 0;
    final elapsed = DateTime.now().difference(installDate).inDays;
    return (trialDays - elapsed).clamp(0, trialDays);
  }

  /// Persentase trial yang sudah terpakai (0.0 – 1.0).
  Future<double> getUsedFraction() async {
    final installDate = await getInstallDate();
    if (installDate == null) return 1.0;
    final elapsed = DateTime.now().difference(installDate).inDays;
    return (elapsed / trialDays).clamp(0.0, 1.0);
  }

  /// Tanggal berakhirnya trial.
  Future<DateTime?> getExpiryDate() async {
    final installDate = await getInstallDate();
    if (installDate == null) return null;
    return installDate.add(Duration(days: trialDays));
  }

  /// Reset trial — HANYA untuk keperluan testing/debug.
  Future<void> resetForTesting() async {
    await _storage.delete(key: _keyInstallDate);
    await init();
  }
}
