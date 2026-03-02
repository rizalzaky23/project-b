import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/detail_kendaraan_entity.dart';
import '../../domain/repositories/detail_kendaraan_repository.dart';
import '../datasources/detail_kendaraan_remote_datasource.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../../../shared/utils/multipart_helper.dart';
import '../../../../shared/utils/pagination_meta.dart';

class DetailKendaraanRepositoryImpl implements DetailKendaraanRepository {
  final DetailKendaraanRemoteDataSource _remote;
  DetailKendaraanRepositoryImpl(this._remote);

  @override
  Future<({List<DetailKendaraanEntity> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search}) async {
    try {
      final r = await _remote.getAll(page: page, kendaraanId: kendaraanId, search: search);
      return (items: r.items.cast<DetailKendaraanEntity>(), meta: r.meta);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<DetailKendaraanEntity> getById(int id) async {
    try { return await _remote.getById(id); }
    on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<DetailKendaraanEntity> create({required int kendaraanId, required String noPolisi, required String namaPemilik, String? berlakuMulai, XFile? fotoStnk, XFile? fotoBpkb, XFile? fotoNomor, XFile? fotoKm}) async {
    try {
      final fields = <String, dynamic>{'kendaraan_id': kendaraanId.toString(), 'no_polisi': noPolisi, 'nama_pemilik': namaPemilik};
      if (berlakuMulai != null) fields['berlaku_mulai'] = berlakuMulai;
      final formData = FormData.fromMap(fields);
      for (final entry in [('foto_stnk', fotoStnk), ('foto_bpkb', fotoBpkb), ('foto_nomor', fotoNomor), ('foto_km', fotoKm)]) {
        if (entry.$2 != null) await addFileToForm(formData, entry.$1, entry.$2);
      }
      return await _remote.create(formData);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<DetailKendaraanEntity> update({required int id, String? noPolisi, String? namaPemilik, String? berlakuMulai, XFile? fotoStnk, XFile? fotoBpkb, XFile? fotoNomor, XFile? fotoKm, bool fotoStnkDeleted = false, bool fotoBpkbDeleted = false, bool fotoNomorDeleted = false, bool fotoKmDeleted = false}) async {
    try {
      final fields = <String, dynamic>{};
      if (noPolisi != null) fields['no_polisi'] = noPolisi;
      if (namaPemilik != null) fields['nama_pemilik'] = namaPemilik;
      if (berlakuMulai != null) fields['berlaku_mulai'] = berlakuMulai;
      final formData = FormData.fromMap(fields);
      await addFileToForm(formData, 'foto_stnk', fotoStnk, deleted: fotoStnkDeleted, deleteKey: 'delete_foto_stnk');
      await addFileToForm(formData, 'foto_bpkb', fotoBpkb, deleted: fotoBpkbDeleted, deleteKey: 'delete_foto_bpkb');
      await addFileToForm(formData, 'foto_nomor', fotoNomor, deleted: fotoNomorDeleted, deleteKey: 'delete_foto_nomor');
      await addFileToForm(formData, 'foto_km', fotoKm, deleted: fotoKmDeleted, deleteKey: 'delete_foto_km');
      return await _remote.update(id, formData);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<void> delete(int id) async {
    try { await _remote.delete(id); }
    on DioException catch (e) { throw ApiHelper.handleError(e); }
  }
}
