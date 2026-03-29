import 'package:image_picker/image_picker.dart';
import '../entities/servis_entity.dart';
import '../../../../shared/utils/pagination_meta.dart';

abstract class ServisRepository {
  Future<({List<ServisEntity> items, PaginationMeta meta})> getAll({
    int page = 1,
    int? kendaraanId,
    String? search,
  });

  Future<ServisEntity> getById(int id);

  Future<ServisEntity> create({
    required int kendaraanId,
    required String tanggalServis,
    required int kilometer,
    XFile? fotoKm,
    XFile? fotoInvoice,
  });

  Future<ServisEntity> update({
    required int id,
    String? tanggalServis,
    int? kilometer,
    XFile? fotoKm,
    bool fotoKmDeleted = false,
    XFile? fotoInvoice,
    bool fotoInvoiceDeleted = false,
  });

  Future<void> delete(int id);
}
