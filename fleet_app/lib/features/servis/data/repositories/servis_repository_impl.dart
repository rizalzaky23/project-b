import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/servis_entity.dart';
import '../../domain/repositories/servis_repository.dart';
import '../datasources/servis_remote_datasource.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../../../shared/utils/multipart_helper.dart';
import '../../../../shared/utils/pagination_meta.dart';

class ServisRepositoryImpl implements ServisRepository {
  final ServisRemoteDataSource _remote;
  ServisRepositoryImpl(this._remote);

  Future<FormData> _buildForm({
    int? kendaraanId,
    String? tanggalServis,
    int? kilometer,
    XFile? fotoKm,
    bool fotoKmDeleted = false,
    XFile? fotoInvoice,
    bool fotoInvoiceDeleted = false,
  }) async {
    final f = <String, dynamic>{};
    if (kendaraanId != null) f['kendaraan_id'] = kendaraanId.toString();
    if (tanggalServis != null) f['tanggal_servis'] = tanggalServis;
    if (kilometer != null) f['kilometer'] = kilometer.toString();
    
    // Default cash because the backend may still expect it
    f['jenis_pembayaran'] = 'cash';

    final formData = FormData.fromMap(f);
    
    await addFileToForm(formData, 'foto_km', fotoKm,
        deleted: fotoKmDeleted, deleteKey: 'delete_foto_km');
    await addFileToForm(formData, 'foto_invoice', fotoInvoice,
        deleted: fotoInvoiceDeleted, deleteKey: 'delete_foto_invoice');
    return formData;
  }

  @override
  Future<({List<ServisEntity> items, PaginationMeta meta})> getAll({
    int page = 1,
    int? kendaraanId,
    String? search,
  }) async {
    try {
      final r = await _remote.getAll(
          page: page, kendaraanId: kendaraanId, search: search);
      return (items: r.items.cast<ServisEntity>(), meta: r.meta);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<ServisEntity> getById(int id) async {
    try {
      return await _remote.getById(id);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<ServisEntity> create({
    required int kendaraanId,
    required String tanggalServis,
    required int kilometer,
    XFile? fotoKm,
    XFile? fotoInvoice,
  }) async {
    try {
      final form = await _buildForm(
        kendaraanId: kendaraanId,
        tanggalServis: tanggalServis,
        kilometer: kilometer,
        fotoKm: fotoKm,
        fotoInvoice: fotoInvoice,
      );
      return await _remote.create(form);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<ServisEntity> update({
    required int id,
    String? tanggalServis,
    int? kilometer,
    XFile? fotoKm,
    bool fotoKmDeleted = false,
    XFile? fotoInvoice,
    bool fotoInvoiceDeleted = false,
  }) async {
    try {
      final form = await _buildForm(
        tanggalServis: tanggalServis,
        kilometer: kilometer,
        fotoKm: fotoKm,
        fotoKmDeleted: fotoKmDeleted,
        fotoInvoice: fotoInvoice,
        fotoInvoiceDeleted: fotoInvoiceDeleted,
      );
      return await _remote.update(id, form);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _remote.delete(id);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }
}
