import 'package:image_picker/image_picker.dart';
import '../entities/kejadian_entity.dart';
import '../../../../shared/utils/pagination_meta.dart';
abstract class KejadianRepository {
  Future<({List<KejadianEntity> items, PaginationMeta meta})> getAll({int page=1, int? kendaraanId, String? search});
  Future<KejadianEntity> getById(int id);
  Future<KejadianEntity> create({required int kendaraanId, required String tanggal, String? jenisKejadian, String? lokasi, String? deskripsi, String? status, XFile? fotoKm, XFile? foto1, XFile? foto2});
  Future<KejadianEntity> update({required int id, String? tanggal, String? jenisKejadian, String? lokasi, String? deskripsi, String? status, XFile? fotoKm, XFile? foto1, XFile? foto2, bool fotoKmDeleted, bool foto1Deleted, bool foto2Deleted});
  Future<void> delete(int id);
}
