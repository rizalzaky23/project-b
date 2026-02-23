import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/kendaraan_entity.dart';
import '../../domain/repositories/kendaraan_repository.dart';
import '../datasources/kendaraan_remote_datasource.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../../../shared/utils/pagination_meta.dart';

class KendaraanRepositoryImpl implements KendaraanRepository {
  final KendaraanRemoteDataSource _remote;

  KendaraanRepositoryImpl(this._remote);

  @override
  Future<({List<KendaraanEntity> items, PaginationMeta meta})> getAll({
    int page = 1,
    String? search,
    String? merk,
    String? warna,
    int? tahunPembuatan,
  }) async {
    try {
      final result = await _remote.getAll(
        page: page,
        search: search,
        merk: merk,
        warna: warna,
        tahunPembuatan: tahunPembuatan,
      );
      return (items: result.items as List<KendaraanEntity>, meta: result.meta);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<KendaraanEntity> getById(int id) async {
    try {
      return await _remote.getById(id);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
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
  }) async {
    try {
      final formData = await _buildFormData(
        kodeKendaraan: kodeKendaraan,
        merk: merk,
        tipe: tipe,
        warna: warna,
        noChasis: noChasis,
        noMesin: noMesin,
        tahunPerolehan: tahunPerolehan,
        tahunPembuatan: tahunPembuatan,
        hargaPerolehan: hargaPerolehan,
        dealer: dealer,
        fotoDepan: fotoDepan,
        fotoKiri: fotoKiri,
        fotoKanan: fotoKanan,
        fotoBelakang: fotoBelakang,
      );
      return await _remote.create(formData);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
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
  }) async {
    try {
      final formData = await _buildFormData(
        kodeKendaraan: kodeKendaraan,
        merk: merk,
        tipe: tipe,
        warna: warna,
        noChasis: noChasis,
        noMesin: noMesin,
        tahunPerolehan: tahunPerolehan,
        tahunPembuatan: tahunPembuatan,
        hargaPerolehan: hargaPerolehan,
        dealer: dealer,
        fotoDepan: fotoDepan,
        fotoKiri: fotoKiri,
        fotoKanan: fotoKanan,
        fotoBelakang: fotoBelakang,
      );
      return await _remote.update(id, formData);
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

  Future<FormData> _buildFormData({
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
  }) async {
    final fields = <String, dynamic>{};
    if (kodeKendaraan != null) fields['kode_kendaraan'] = kodeKendaraan;
    if (merk != null) fields['merk'] = merk;
    if (tipe != null) fields['tipe'] = tipe;
    if (warna != null) fields['warna'] = warna;
    if (noChasis != null) fields['no_chasis'] = noChasis;
    if (noMesin != null) fields['no_mesin'] = noMesin;
    if (tahunPerolehan != null) fields['tahun_perolehan'] = tahunPerolehan.toString();
    if (tahunPembuatan != null) fields['tahun_pembuatan'] = tahunPembuatan.toString();
    if (hargaPerolehan != null) fields['harga_perolehan'] = hargaPerolehan.toString();
    if (dealer != null) fields['dealer'] = dealer;

    final formData = FormData.fromMap(fields);

    Future<void> addPhoto(String key, XFile? file) async {
      if (file != null) {
        formData.files.add(MapEntry(
          key,
          await MultipartFile.fromFile(file.path, filename: file.name),
        ));
      }
    }

    await addPhoto('foto_depan', fotoDepan);
    await addPhoto('foto_kiri', fotoKiri);
    await addPhoto('foto_kanan', fotoKanan);
    await addPhoto('foto_belakang', fotoBelakang);

    return formData;
  }
}
