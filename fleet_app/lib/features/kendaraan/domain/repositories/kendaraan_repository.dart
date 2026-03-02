import 'package:image_picker/image_picker.dart';
import '../entities/kendaraan_entity.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class KendaraanRepository {
  Future<({List<KendaraanEntity> items, PaginationMeta meta})> getAll({
    int page = 1,
    String? search,
    String? merk,
    String? warna,
    int? tahunPembuatan,
  });

  Future<KendaraanEntity> getById(int id);

  Future<KendaraanEntity> create({
    required String kodeKendaraan,
    required String merk,
    required String tipe,
    required String warna,
    required String noChasis,
    required String noMesin,
    required int tahunPerolehan,
    required int tahunPembuatan,
    required double hargaPerolehan,
    String? dealer,
    XFile? fotoDepan,
    XFile? fotoKiri,
    XFile? fotoKanan,
    XFile? fotoBelakang,
  });

  Future<KendaraanEntity> update({
    required int id,
    String? kodeKendaraan,
    String? merk,
    String? tipe,
    String? warna,
    String? noChasis,
    String? noMesin,
    int? tahunPerolehan,
    int? tahunPembuatan,
    double? hargaPerolehan,
    String? dealer,
    XFile? fotoDepan,
    XFile? fotoKiri,
    XFile? fotoKanan,
    XFile? fotoBelakang,
    bool fotoDepanDeleted,
    bool fotoKiriDeleted,
    bool fotoKananDeleted,
    bool fotoBelakangDeleted,
  });

  Future<void> delete(int id);
}
