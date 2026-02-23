import '../entities/penyewaan_entity.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class PenyewaanRepository {
  Future<({List<PenyewaanEntity> items, PaginationMeta meta})> getAll({int page=1, int? kendaraanId, String? search, bool? aktif});
  Future<PenyewaanEntity> getById(int id);
  Future<PenyewaanEntity> create({required int kendaraanId, required String kodePenyewa, required bool group, required int masaSewa, required String tanggalMulai, required String tanggalSelesai, required String penanggungJawab, String? lokasiSewa, String? sales, required double nilaiSewa});
  Future<PenyewaanEntity> update({required int id, String? kodePenyewa, bool? group, int? masaSewa, String? tanggalMulai, String? tanggalSelesai, String? penanggungJawab, String? lokasiSewa, String? sales, double? nilaiSewa});
  Future<void> delete(int id);
}
