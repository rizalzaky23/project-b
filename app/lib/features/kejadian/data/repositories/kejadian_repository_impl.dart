import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/kejadian_entity.dart';
import '../../domain/repositories/kejadian_repository.dart';
import '../datasources/kejadian_remote_datasource.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../../../shared/utils/multipart_helper.dart';
import '../../../../shared/utils/pagination_meta.dart';

class KejadianRepositoryImpl implements KejadianRepository {
  final KejadianRemoteDataSource _remote;
  KejadianRepositoryImpl(this._remote);

  @override
  Future<({List<KejadianEntity> items, PaginationMeta meta})> getAll({int page=1, int? kendaraanId, String? search}) async {
    try { final r = await _remote.getAll(page: page, kendaraanId: kendaraanId, search: search); return (items: r.items.cast<KejadianEntity>(), meta: r.meta); }
    on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override Future<KejadianEntity> getById(int id) async { try { return await _remote.getById(id); } on DioException catch (e) { throw ApiHelper.handleError(e); } }

  @override
  Future<KejadianEntity> create({required int kendaraanId, required String tanggal, String? deskripsi, XFile? fotoKm, XFile? foto1, XFile? foto2}) async {
    try {
      final fields = <String,dynamic>{'kendaraan_id': kendaraanId.toString(), 'tanggal': tanggal};
      if (deskripsi != null) fields['deskripsi'] = deskripsi;
      final fd = FormData.fromMap(fields);
      for (final e in [('foto_km', fotoKm), ('foto_1', foto1), ('foto_2', foto2)]) {
        if (e.$2 != null) await addFileToForm(fd, e.$1, e.$2);
      }
      return await _remote.create(fd);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<KejadianEntity> update({required int id, String? tanggal, String? deskripsi, XFile? fotoKm, XFile? foto1, XFile? foto2, bool fotoKmDeleted = false, bool foto1Deleted = false, bool foto2Deleted = false}) async {
    try {
      final fields = <String,dynamic>{};
      if (tanggal != null) fields['tanggal'] = tanggal;
      if (deskripsi != null) fields['deskripsi'] = deskripsi;
      final fd = FormData.fromMap(fields);
      await addFileToForm(fd, 'foto_km', fotoKm, deleted: fotoKmDeleted, deleteKey: 'delete_foto_km');
      await addFileToForm(fd, 'foto_1', foto1, deleted: foto1Deleted, deleteKey: 'delete_foto_1');
      await addFileToForm(fd, 'foto_2', foto2, deleted: foto2Deleted, deleteKey: 'delete_foto_2');
      return await _remote.update(id, fd);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override Future<void> delete(int id) async { try { await _remote.delete(id); } on DioException catch (e) { throw ApiHelper.handleError(e); } }
}
