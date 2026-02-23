import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/utils/pagination_meta.dart';
import '../models/kendaraan_model.dart';

abstract class KendaraanRemoteDataSource {
  Future<({List<KendaraanModel> items, PaginationMeta meta})> getAll({int page = 1, String? search, String? merk, String? warna, int? tahunPembuatan});
  Future<KendaraanModel> getById(int id);
  Future<KendaraanModel> create(FormData formData);
  Future<KendaraanModel> update(int id, FormData formData);
  Future<void> delete(int id);
}

class KendaraanRemoteDataSourceImpl implements KendaraanRemoteDataSource {
  final ApiClient _apiClient;
  KendaraanRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<KendaraanModel> items, PaginationMeta meta})> getAll({int page = 1, String? search, String? merk, String? warna, int? tahunPembuatan}) async {
    final params = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (merk != null) params['merk'] = merk;
    if (warna != null) params['warna'] = warna;
    if (tahunPembuatan != null) params['tahun_pembuatan'] = tahunPembuatan;

    final response = await _apiClient.get(ApiConstants.kendaraan, queryParameters: params);
    // paginatedResponse: { "data": [...], "meta": {...} }
    final body = response.data;
    final items = (body['data'] as List).map((e) => KendaraanModel.fromJson(e)).toList();
    final meta = PaginationMeta.fromJson(body['meta'] ?? body);
    return (items: items, meta: meta);
  }

  @override Future<KendaraanModel> getById(int id) async {
    final r = await _apiClient.get('${ApiConstants.kendaraan}/$id');
    return KendaraanModel.fromJson(r.data['data']);
  }

  @override Future<KendaraanModel> create(FormData formData) async {
    final r = await _apiClient.post(ApiConstants.kendaraan, data: formData);
    return KendaraanModel.fromJson(r.data['data']);
  }

  @override Future<KendaraanModel> update(int id, FormData formData) async {
    formData.fields.add(const MapEntry('_method', 'PUT'));
    final r = await _apiClient.post('${ApiConstants.kendaraan}/$id', data: formData);
    return KendaraanModel.fromJson(r.data['data']);
  }

  @override Future<void> delete(int id) async {
    await _apiClient.delete('${ApiConstants.kendaraan}/$id');
  }
}
