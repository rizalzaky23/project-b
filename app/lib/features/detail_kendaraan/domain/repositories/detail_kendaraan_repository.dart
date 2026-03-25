import 'package:image_picker/image_picker.dart';
import '../entities/detail_kendaraan_entity.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class DetailKendaraanRepository {
  Future<({List<DetailKendaraanEntity> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search});
  Future<DetailKendaraanEntity> getById(int id);
  Future<DetailKendaraanEntity> create({required int kendaraanId, required String noPolisi, required String namaPemilik, String? berlakuMulai, XFile? fotoStnk, XFile? fotoBpkb, XFile? fotoNomor, XFile? fotoKm});
  Future<DetailKendaraanEntity> update({required int id, String? noPolisi, String? namaPemilik, String? berlakuMulai, XFile? fotoStnk, XFile? fotoBpkb, XFile? fotoNomor, XFile? fotoKm, bool fotoStnkDeleted, bool fotoBpkbDeleted, bool fotoNomorDeleted, bool fotoKmDeleted});
  Future<void> delete(int id);
}
