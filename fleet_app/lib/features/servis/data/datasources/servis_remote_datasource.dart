import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/utils/pagination_meta.dart';
import '../models/servis_model.dart';

abstract class ServisRemoteDataSource {
  Future<({List<ServisModel> items, PaginationMeta meta})> getAll({
    int page = 1,
    int? kendaraanId,
    String? search,
  });
  Future<ServisModel> getById(int id);
  Future<ServisModel> create(FormData formData);
  Future<ServisModel> update(int id, FormData formData);
  Future<void> delete(int id);
}

class ServisRemoteDataSourceImpl implements ServisRemoteDataSource {
  final ApiClient _apiClient;
  ServisRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<ServisModel> items, PaginationMeta meta})> getAll({
    int page = 1,
    int? kendaraanId,
    String? search,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (kendaraanId != null) params['kendaraan_id'] = kendaraanId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final r = await _apiClient.get(ApiConstants.servisKendaraan,
        queryParameters: params);
    final body = r.data;
    return (
      items: (body['data'] as List)
          .map((e) => ServisModel.fromJson(e))
          .toList(),
      meta: PaginationMeta.fromJson(body['meta'] ?? body),
    );
  }

  @override
  Future<ServisModel> getById(int id) async {
    final r =
        await _apiClient.get('${ApiConstants.servisKendaraan}/$id');
    return ServisModel.fromJson(r.data['data']);
  }

  @override
  Future<ServisModel> create(FormData f) async {
    final r =
        await _apiClient.post(ApiConstants.servisKendaraan, data: f);
    return ServisModel.fromJson(r.data['data']);
  }

  @override
  Future<ServisModel> update(int id, FormData f) async {
    f.fields.add(const MapEntry('_method', 'PUT'));
    final r = await _apiClient
        .post('${ApiConstants.servisKendaraan}/$id', data: f);
    return ServisModel.fromJson(r.data['data']);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('${ApiConstants.servisKendaraan}/$id');
  }
}
