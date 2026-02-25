import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/asuransi_entity.dart';
import '../../domain/repositories/asuransi_repository.dart';
import '../datasources/asuransi_remote_datasource.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../../../shared/utils/multipart_helper.dart';
import '../../../../shared/utils/pagination_meta.dart';

class AsuransiRepositoryImpl implements AsuransiRepository {
  final AsuransiRemoteDataSource _remote;
  AsuransiRepositoryImpl(this._remote);

  Future<FormData> _buildForm({int? kendaraanId, String? perusahaanAsuransi, String? jenisAsuransi, String? tanggalMulai, String? tanggalAkhir, String? noPolis, double? nilaiPremi, double? nilaiPertanggungan, XFile? fotoDepan, XFile? fotoKiri, XFile? fotoKanan, XFile? fotoBelakang, XFile? fotoDashboard, XFile? fotoKm}) async {
    final f = <String, dynamic>{};
    if (kendaraanId != null) f['kendaraan_id'] = kendaraanId.toString();
    if (perusahaanAsuransi != null) f['perusahaan_asuransi'] = perusahaanAsuransi;
    if (jenisAsuransi != null) f['jenis_asuransi'] = jenisAsuransi;
    if (tanggalMulai != null) f['tanggal_mulai'] = tanggalMulai;
    if (tanggalAkhir != null) f['tanggal_akhir'] = tanggalAkhir;
    if (noPolis != null) f['no_polis'] = noPolis;
    if (nilaiPremi != null) f['nilai_premi'] = nilaiPremi.toString();
    if (nilaiPertanggungan != null) f['nilai_pertanggungan'] = nilaiPertanggungan.toString();
    final formData = FormData.fromMap(f);
    for (final e in [('foto_depan', fotoDepan), ('foto_kiri', fotoKiri), ('foto_kanan', fotoKanan), ('foto_belakang', fotoBelakang), ('foto_dashboard', fotoDashboard), ('foto_km', fotoKm)]) {
      if (e.$2 != null) await addFileToForm(formData, e.$1, e.$2);
    }
    return formData;
  }

  @override
  Future<({List<AsuransiEntity> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search}) async {
    try { final r = await _remote.getAll(page: page, kendaraanId: kendaraanId, search: search); return (items: r.items.cast<AsuransiEntity>(), meta: r.meta); }
    on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override Future<AsuransiEntity> getById(int id) async { try { return await _remote.getById(id); } on DioException catch (e) { throw ApiHelper.handleError(e); } }

  @override
  Future<AsuransiEntity> create({required int kendaraanId, required String perusahaanAsuransi, required String jenisAsuransi, required String tanggalMulai, required String tanggalAkhir, required String noPolis, required double nilaiPremi, required double nilaiPertanggungan, XFile? fotoDepan, XFile? fotoKiri, XFile? fotoKanan, XFile? fotoBelakang, XFile? fotoDashboard, XFile? fotoKm}) async {
    try {
      final form = await _buildForm(kendaraanId: kendaraanId, perusahaanAsuransi: perusahaanAsuransi, jenisAsuransi: jenisAsuransi, tanggalMulai: tanggalMulai, tanggalAkhir: tanggalAkhir, noPolis: noPolis, nilaiPremi: nilaiPremi, nilaiPertanggungan: nilaiPertanggungan, fotoDepan: fotoDepan, fotoKiri: fotoKiri, fotoKanan: fotoKanan, fotoBelakang: fotoBelakang, fotoDashboard: fotoDashboard, fotoKm: fotoKm);
      return await _remote.create(form);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<AsuransiEntity> update({required int id, String? perusahaanAsuransi, String? jenisAsuransi, String? tanggalMulai, String? tanggalAkhir, String? noPolis, double? nilaiPremi, double? nilaiPertanggungan, XFile? fotoDepan, XFile? fotoKiri, XFile? fotoKanan, XFile? fotoBelakang, XFile? fotoDashboard, XFile? fotoKm}) async {
    try {
      final form = await _buildForm(perusahaanAsuransi: perusahaanAsuransi, jenisAsuransi: jenisAsuransi, tanggalMulai: tanggalMulai, tanggalAkhir: tanggalAkhir, noPolis: noPolis, nilaiPremi: nilaiPremi, nilaiPertanggungan: nilaiPertanggungan, fotoDepan: fotoDepan, fotoKiri: fotoKiri, fotoKanan: fotoKanan, fotoBelakang: fotoBelakang, fotoDashboard: fotoDashboard, fotoKm: fotoKm);
      return await _remote.update(id, form);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override Future<void> delete(int id) async { try { await _remote.delete(id); } on DioException catch (e) { throw ApiHelper.handleError(e); } }
}
