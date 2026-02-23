import 'package:dio/dio.dart';
import '../../domain/entities/penyewaan_entity.dart';
import '../../domain/repositories/penyewaan_repository.dart';
import '../datasources/penyewaan_remote_datasource.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../../../shared/utils/pagination_meta.dart';

class PenyewaanRepositoryImpl implements PenyewaanRepository {
  final PenyewaanRemoteDataSource _remote;
  PenyewaanRepositoryImpl(this._remote);

  @override
  Future<({List<PenyewaanEntity> items, PaginationMeta meta})> getAll({int page=1, int? kendaraanId, String? search, bool? aktif}) async {
    try { final r = await _remote.getAll(page: page, kendaraanId: kendaraanId, search: search, aktif: aktif); return (items: r.items as List<PenyewaanEntity>, meta: r.meta); }
    on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override Future<PenyewaanEntity> getById(int id) async { try { return await _remote.getById(id); } on DioException catch (e) { throw ApiHelper.handleError(e); } }

  @override
  Future<PenyewaanEntity> create({required int kendaraanId, required String kodePenyewa, required bool group, required int masaSewa, required String tanggalMulai, required String tanggalSelesai, required String penanggungJawab, String? lokasiSewa, String? sales, required double nilaiSewa}) async {
    try {
      final data = {'kendaraan_id': kendaraanId, 'kode_penyewa': kodePenyewa, 'group': group, 'masa_sewa': masaSewa, 'tanggal_mulai': tanggalMulai, 'tanggal_selesai': tanggalSelesai, 'penanggung_jawab': penanggungJawab, 'nilai_sewa': nilaiSewa};
      if (lokasiSewa != null) data['lokasi_sewa'] = lokasiSewa as Object;
      if (sales != null) data['sales'] = sales as Object;
      return await _remote.create(data.map((k, v) => MapEntry(k, v)));
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override
  Future<PenyewaanEntity> update({required int id, String? kodePenyewa, bool? group, int? masaSewa, String? tanggalMulai, String? tanggalSelesai, String? penanggungJawab, String? lokasiSewa, String? sales, double? nilaiSewa}) async {
    try {
      final data = <String, dynamic>{};
      if (kodePenyewa != null) data['kode_penyewa'] = kodePenyewa;
      if (group != null) data['group'] = group;
      if (masaSewa != null) data['masa_sewa'] = masaSewa;
      if (tanggalMulai != null) data['tanggal_mulai'] = tanggalMulai;
      if (tanggalSelesai != null) data['tanggal_selesai'] = tanggalSelesai;
      if (penanggungJawab != null) data['penanggung_jawab'] = penanggungJawab;
      if (lokasiSewa != null) data['lokasi_sewa'] = lokasiSewa;
      if (sales != null) data['sales'] = sales;
      if (nilaiSewa != null) data['nilai_sewa'] = nilaiSewa;
      return await _remote.update(id, data);
    } on DioException catch (e) { throw ApiHelper.handleError(e); }
  }

  @override Future<void> delete(int id) async { try { await _remote.delete(id); } on DioException catch (e) { throw ApiHelper.handleError(e); } }
}
