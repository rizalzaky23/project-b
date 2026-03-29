import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/penyewaan_entity.dart';
import '../../domain/repositories/penyewaan_repository.dart';
import '../datasources/penyewaan_remote_datasource.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../../../shared/utils/multipart_helper.dart';
import '../../../../shared/utils/pagination_meta.dart';

class PenyewaanRepositoryImpl implements PenyewaanRepository {
  final PenyewaanRemoteDataSource _remote;
  PenyewaanRepositoryImpl(this._remote);

  Future<FormData> _buildForm({int? kendaraanId, String? namaPenyewa, bool? group, int? masaSewa, String? tanggalMulai, String? tanggalSelesai, String? penanggungJawab, String? lokasiSewa, double? nilaiSewa, XFile? suratPerjanjian, bool suratPerjanjianDeleted = false}) async {
    final f = <String, dynamic>{};
    if (kendaraanId != null) f['kendaraan_id'] = kendaraanId.toString();
    if (namaPenyewa != null) f['nama_penyewa'] = namaPenyewa;
    if (group != null) f['group'] = group ? '1' : '0';
    if (masaSewa != null) f['masa_sewa'] = masaSewa.toString();
    if (tanggalMulai != null) f['tanggal_mulai'] = tanggalMulai;
    if (tanggalSelesai != null) f['tanggal_selesai'] = tanggalSelesai;
    if (penanggungJawab != null) f['penanggung_jawab'] = penanggungJawab;
    if (lokasiSewa != null) f['lokasi_sewa'] = lokasiSewa;
    if (nilaiSewa != null) f['nilai_sewa'] = nilaiSewa.toString();
    
    final formData = FormData.fromMap(f);
    await addPdfToForm(formData, 'surat_perjanjian', suratPerjanjian, deleted: suratPerjanjianDeleted, deleteKey: 'delete_surat_perjanjian');
    return formData;
  }

  @override
  Future<({List<PenyewaanEntity> items, PaginationMeta meta})> getAll({int page=1, int? kendaraanId, String? search, bool? aktif}) async {
    try { final r = await _remote.getAll(page: page, kendaraanId: kendaraanId, search: search, aktif: aktif); return (items: r.items.cast<PenyewaanEntity>(), meta: r.meta); }
    on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override Future<PenyewaanEntity> getById(int id) async { try { return await _remote.getById(id); } on DioException catch (e) { throw ApiHelper.handleError(e); } }

  @override
  Future<PenyewaanEntity> create({required int kendaraanId, required String namaPenyewa, required bool group, required int masaSewa, required String tanggalMulai, required String tanggalSelesai, required String penanggungJawab, String? lokasiSewa, required double nilaiSewa, XFile? suratPerjanjian}) async {
    try {
      final form = await _buildForm(kendaraanId: kendaraanId, namaPenyewa: namaPenyewa, group: group, masaSewa: masaSewa, tanggalMulai: tanggalMulai, tanggalSelesai: tanggalSelesai, penanggungJawab: penanggungJawab, lokasiSewa: lokasiSewa, nilaiSewa: nilaiSewa, suratPerjanjian: suratPerjanjian);
      return await _remote.create(form);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<PenyewaanEntity> update({required int id, String? namaPenyewa, bool? group, int? masaSewa, String? tanggalMulai, String? tanggalSelesai, String? penanggungJawab, String? lokasiSewa, double? nilaiSewa, XFile? suratPerjanjian, bool suratPerjanjianDeleted = false}) async {
    try {
      final form = await _buildForm(namaPenyewa: namaPenyewa, group: group, masaSewa: masaSewa, tanggalMulai: tanggalMulai, tanggalSelesai: tanggalSelesai, penanggungJawab: penanggungJawab, lokasiSewa: lokasiSewa, nilaiSewa: nilaiSewa, suratPerjanjian: suratPerjanjian, suratPerjanjianDeleted: suratPerjanjianDeleted);
      return await _remote.update(id, form);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override Future<void> delete(int id) async { try { await _remote.delete(id); } on DioException catch (e) { throw ApiHelper.handleError(e); } }
}
