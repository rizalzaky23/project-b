import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/utils/pagination_meta.dart';
import '../models/detail_kendaraan_model.dart';

abstract class DetailKendaraanRemoteDataSource {
  Future<({List<DetailKendaraanModel> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search});
  Future<DetailKendaraanModel> getById(int id);
  Future<DetailKendaraanModel> create(FormData formData);
  Future<DetailKendaraanModel> update(int id, FormData formData);
  Future<void> delete(int id);
}

class DetailKendaraanRemoteDataSourceImpl implements DetailKendaraanRemoteDataSource {
  final ApiClient _apiClient;
  DetailKendaraanRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<DetailKendaraanModel> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search}) async {
    final params = <String, dynamic>{'page': page};
    if (kendaraanId != null) params['kendaraan_id'] = kendaraanId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final response = await _apiClient.get(ApiConstants.detailKendaraan, queryParameters: params);
    final data = response.data['data'];
    return (
      items: (data['data'] as List).map((e) => DetailKendaraanModel.fromJson(e)).toList(),
      meta: PaginationMeta.fromJson(data),
    );
  }

  @override
  Future<DetailKendaraanModel> getById(int id) async {
    final r = await _apiClient.get('${ApiConstants.detailKendaraan}/$id');
    return DetailKendaraanModel.fromJson(r.data['data']);
  }

  @override
  Future<DetailKendaraanModel> create(FormData formData) async {
    final r = await _apiClient.post(ApiConstants.detailKendaraan, data: formData);
    return DetailKendaraanModel.fromJson(r.data['data']);
  }

  @override
  Future<DetailKendaraanModel> update(int id, FormData formData) async {
    formData.fields.add(const MapEntry('_method', 'PUT'));
    final r = await _apiClient.post('${ApiConstants.detailKendaraan}/$id', data: formData);
    return DetailKendaraanModel.fromJson(r.data['data']);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('${ApiConstants.detailKendaraan}/$id');
  }
}
