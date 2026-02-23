import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/utils/pagination_meta.dart';
import '../models/asuransi_model.dart';

abstract class AsuransiRemoteDataSource {
  Future<({List<AsuransiModel> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search});
  Future<AsuransiModel> getById(int id);
  Future<AsuransiModel> create(FormData formData);
  Future<AsuransiModel> update(int id, FormData formData);
  Future<void> delete(int id);
}

class AsuransiRemoteDataSourceImpl implements AsuransiRemoteDataSource {
  final ApiClient _apiClient;
  AsuransiRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<AsuransiModel> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search}) async {
    final params = <String, dynamic>{'page': page};
    if (kendaraanId != null) params['kendaraan_id'] = kendaraanId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final r = await _apiClient.get(ApiConstants.asuransiKendaraan, queryParameters: params);
    final body = r.data;
    return (
      items: (body['data'] as List).map((e) => AsuransiModel.fromJson(e)).toList(),
      meta: PaginationMeta.fromJson(body['meta'] ?? body),
    );
  }

  @override Future<AsuransiModel> getById(int id) async {
    final r = await _apiClient.get('${ApiConstants.asuransiKendaraan}/$id');
    return AsuransiModel.fromJson(r.data['data']);
  }

  @override Future<AsuransiModel> create(FormData f) async {
    final r = await _apiClient.post(ApiConstants.asuransiKendaraan, data: f);
    return AsuransiModel.fromJson(r.data['data']);
  }

  @override Future<AsuransiModel> update(int id, FormData f) async {
    f.fields.add(const MapEntry('_method', 'PUT'));
    final r = await _apiClient.post('${ApiConstants.asuransiKendaraan}/$id', data: f);
    return AsuransiModel.fromJson(r.data['data']);
  }

  @override Future<void> delete(int id) async {
    await _apiClient.delete('${ApiConstants.asuransiKendaraan}/$id');
  }
}
