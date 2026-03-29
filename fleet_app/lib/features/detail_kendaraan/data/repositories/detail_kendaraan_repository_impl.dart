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
  Future<DetailKendaraanEntity> create({
    required int kendaraanId,
    required String noPolisi,
    required String namaPemilik,
    String? pemilikKomersial,
    String? pemilikFiskal,
    XFile? fotoStnk,
    String? stnkBerlakuMulai,
    String? stnkBerlakuAkhir,
    XFile? fotoBpkb,
    XFile? fotoNomor,
    XFile? fotoKm,
    XFile? kartuKir,
    XFile? lembarKir,
  }) async {
    try {
      final fields = <String, dynamic>{
        'kendaraan_id': kendaraanId.toString(),
        'no_polisi': noPolisi,
        'pemilik_komersial': namaPemilik,
      };
      if (pemilikFiskal != null) fields['pemilik_viskal'] = pemilikFiskal;
      if (stnkBerlakuMulai != null) fields['stnk_berlaku_mulai'] = stnkBerlakuMulai;
      if (stnkBerlakuAkhir != null) fields['stnk_berlaku_akhir'] = stnkBerlakuAkhir;
      final formData = FormData.fromMap(fields);
      for (final entry in [('foto_stnk', fotoStnk), ('foto_bpkb', fotoBpkb), ('foto_nomor', fotoNomor), ('foto_km', fotoKm)]) {
        if (entry.$2 != null) await addFileToForm(formData, entry.$1, entry.$2);
      }
      if (kartuKir != null) await addPdfToForm(formData, 'kartu_kir', kartuKir);
      if (lembarKir != null) await addPdfToForm(formData, 'lembar_kir', lembarKir);
      return await _remote.create(formData);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<DetailKendaraanEntity> update({
    required int id,
    String? noPolisi,
    String? namaPemilik,
    String? pemilikKomersial,
    String? pemilikFiskal,
    XFile? fotoStnk,
    String? stnkBerlakuMulai,
    String? stnkBerlakuAkhir,
    XFile? fotoBpkb,
    XFile? fotoNomor,
    XFile? fotoKm,
    XFile? kartuKir,
    XFile? lembarKir,
    bool fotoStnkDeleted = false,
    bool fotoBpkbDeleted = false,
    bool fotoNomorDeleted = false,
    bool fotoKmDeleted = false,
    bool kartuKirDeleted = false,
    bool lembarKirDeleted = false,
  }) async {
    try {
      final fields = <String, dynamic>{};
      if (noPolisi != null) fields['no_polisi'] = noPolisi;
      if (namaPemilik != null) fields['pemilik_komersial'] = namaPemilik;
      if (pemilikFiskal != null) fields['pemilik_viskal'] = pemilikFiskal;
      if (stnkBerlakuMulai != null) fields['stnk_berlaku_mulai'] = stnkBerlakuMulai;
      if (stnkBerlakuAkhir != null) fields['stnk_berlaku_akhir'] = stnkBerlakuAkhir;
      final formData = FormData.fromMap(fields);
      await addFileToForm(formData, 'foto_stnk', fotoStnk, deleted: fotoStnkDeleted, deleteKey: 'delete_foto_stnk');
      await addFileToForm(formData, 'foto_bpkb', fotoBpkb, deleted: fotoBpkbDeleted, deleteKey: 'delete_foto_bpkb');
      await addFileToForm(formData, 'foto_nomor', fotoNomor, deleted: fotoNomorDeleted, deleteKey: 'delete_foto_nomor');
      await addFileToForm(formData, 'foto_km', fotoKm, deleted: fotoKmDeleted, deleteKey: 'delete_foto_km');
      await addPdfToForm(formData, 'kartu_kir', kartuKir, deleted: kartuKirDeleted, deleteKey: 'delete_kartu_kir');
      await addPdfToForm(formData, 'lembar_kir', lembarKir, deleted: lembarKirDeleted, deleteKey: 'delete_lembar_kir');
      return await _remote.update(id, formData);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<void> delete(int id) async {
    try { await _remote.delete(id); }
    on DioException catch (e) { throw ApiHelper.handleError(e); }
  }
}
