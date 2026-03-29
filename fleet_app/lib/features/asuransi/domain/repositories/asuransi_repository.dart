import 'package:image_picker/image_picker.dart';
import '../entities/asuransi_entity.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class AsuransiRepository {
  Future<({List<AsuransiEntity> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search});
  Future<AsuransiEntity> getById(int id);
  Future<AsuransiEntity> create({required int kendaraanId, required String perusahaanAsuransi, required String jenisAsuransi, required String tanggalMulai, required String tanggalAkhir, required String noPolis, required double nilaiPremi, required double nilaiPertanggungan, XFile? fotoDepan, XFile? fotoKiri, XFile? fotoKanan, XFile? fotoBelakang, XFile? fotoDashboard});
  Future<AsuransiEntity> update({required int id, String? perusahaanAsuransi, String? jenisAsuransi, String? tanggalMulai, String? tanggalAkhir, String? noPolis, double? nilaiPremi, double? nilaiPertanggungan, XFile? fotoDepan, XFile? fotoKiri, XFile? fotoKanan, XFile? fotoBelakang, XFile? fotoDashboard, bool fotoDepanDeleted, bool fotoKiriDeleted, bool fotoKananDeleted, bool fotoBelakangDeleted, bool fotoDashboardDeleted});
  Future<void> delete(int id);
}
