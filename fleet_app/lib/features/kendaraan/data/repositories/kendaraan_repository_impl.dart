import 'package:dio/dio.dart';

import 'package:image_picker/image_picker.dart';
import '../../domain/entities/kendaraan_entity.dart';
import '../../domain/repositories/kendaraan_repository.dart';
import '../datasources/kendaraan_remote_datasource.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../../../shared/utils/multipart_helper.dart';
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
    String? kepemilikan,
    String? status,
  }) async {
    try {
      final result = await _remote.getAll(
        page: page,
        search: search,
        merk: merk,
        warna: warna,
        tahunPembuatan: tahunPembuatan,
        kepemilikan: kepemilikan,
        status: status,
      );
      return (items: result.items.cast<KendaraanEntity>(), meta: result.meta);
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
    String? kepemilikan,
    String? jenisPembayaran,
    String? jenisKredit,
    int? tenor,
    XFile? fileKontrak,
    bool fileKontrakDeleted = false,
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
        kepemilikan: kepemilikan,
        jenisPembayaran: jenisPembayaran,
        jenisKredit: jenisKredit,
        tenor: tenor,
        fileKontrak: fileKontrak,
        fileKontrakDeleted: fileKontrakDeleted,
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
    String? kepemilikan,
    String? jenisPembayaran,
    String? jenisKredit,
    int? tenor,
    XFile? fileKontrak,
    bool fileKontrakDeleted = false,
    XFile? fotoDepan,
    XFile? fotoKiri,
    XFile? fotoKanan,
    XFile? fotoBelakang,
    bool fotoDepanDeleted = false,
    bool fotoKiriDeleted = false,
    bool fotoKananDeleted = false,
    bool fotoBelakangDeleted = false,
    String? status,
    String? tanggalJual,
    double? hargaJual,
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
        kepemilikan: kepemilikan,
        jenisPembayaran: jenisPembayaran,
        jenisKredit: jenisKredit,
        tenor: tenor,
        fileKontrak: fileKontrak,
        fileKontrakDeleted: fileKontrakDeleted,
        fotoDepan: fotoDepan,
        fotoKiri: fotoKiri,
        fotoKanan: fotoKanan,
        fotoBelakang: fotoBelakang,
        fotoDepanDeleted: fotoDepanDeleted,
        fotoKiriDeleted: fotoKiriDeleted,
        fotoKananDeleted: fotoKananDeleted,
        fotoBelakangDeleted: fotoBelakangDeleted,
        status: status,
        tanggalJual: tanggalJual,
        hargaJual: hargaJual,
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
    String? kepemilikan,
    String? jenisPembayaran,
    String? jenisKredit,
    int? tenor,
    XFile? fileKontrak,
    bool fileKontrakDeleted = false,
    XFile? fotoDepan,
    XFile? fotoKiri,
    XFile? fotoKanan,
    XFile? fotoBelakang,
    bool fotoDepanDeleted = false,
    bool fotoKiriDeleted = false,
    bool fotoKananDeleted = false,
    bool fotoBelakangDeleted = false,
    String? status,
    String? tanggalJual,
    double? hargaJual,
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
    if (kepemilikan != null) fields['kepemilikan'] = kepemilikan;
    if (jenisPembayaran != null) fields['jenis_pembayaran'] = jenisPembayaran;
    if (jenisKredit != null) fields['jenis_kredit'] = jenisKredit;
    if (tenor != null) fields['tenor'] = tenor.toString();
    if (status != null) fields['status'] = status;
    if (tanggalJual != null) fields['tanggal_jual'] = tanggalJual;
    if (hargaJual != null) fields['harga_jual'] = hargaJual.toString();

    final formData = FormData.fromMap(fields);

    // Upload PDF kontrak — gunakan addPdfToForm agar content-type PDF benar
    await addPdfToForm(
      formData, 'file_kontrak', fileKontrak,
      deleted: fileKontrakDeleted, deleteKey: 'delete_file_kontrak',
    );

    await addFileToForm(formData, 'foto_depan', fotoDepan,
        deleted: fotoDepanDeleted, deleteKey: 'delete_foto_depan');
    await addFileToForm(formData, 'foto_kiri', fotoKiri,
        deleted: fotoKiriDeleted, deleteKey: 'delete_foto_kiri');
    await addFileToForm(formData, 'foto_kanan', fotoKanan,
        deleted: fotoKananDeleted, deleteKey: 'delete_foto_kanan');
    await addFileToForm(formData, 'foto_belakang', fotoBelakang,
        deleted: fotoBelakangDeleted, deleteKey: 'delete_foto_belakang');

    return formData;
  }
}
