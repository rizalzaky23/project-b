import 'package:image_picker/image_picker.dart';
import '../entities/penyewaan_entity.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class PenyewaanRepository {
  Future<({List<PenyewaanEntity> items, PaginationMeta meta})> getAll({int page=1, int? kendaraanId, String? search, bool? aktif});
  Future<PenyewaanEntity> getById(int id);
  Future<PenyewaanEntity> create({required int kendaraanId, required String namaPenyewa, required bool group, required int masaSewa, required String tanggalMulai, required String tanggalSelesai, required String penanggungJawab, String? lokasiSewa, required double nilaiSewa, XFile? suratPerjanjian});
  Future<PenyewaanEntity> update({required int id, String? namaPenyewa, bool? group, int? masaSewa, String? tanggalMulai, String? tanggalSelesai, String? penanggungJawab, String? lokasiSewa, double? nilaiSewa, XFile? suratPerjanjian, bool suratPerjanjianDeleted});
  Future<void> delete(int id);
}
