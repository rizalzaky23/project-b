import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/utils/pagination_meta.dart';
import '../models/penyewaan_model.dart';

abstract class PenyewaanRemoteDataSource {
  Future<({List<PenyewaanModel> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search, bool? aktif});
  Future<PenyewaanModel> getById(int id);
  Future<PenyewaanModel> create(Map<String, dynamic> data);
  Future<PenyewaanModel> update(int id, Map<String, dynamic> data);
  Future<void> delete(int id);
}

class PenyewaanRemoteDataSourceImpl implements PenyewaanRemoteDataSource {
  final ApiClient _apiClient;
  PenyewaanRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<PenyewaanModel> items, PaginationMeta meta})> getAll({int page = 1, int? kendaraanId, String? search, bool? aktif}) async {
    final params = <String, dynamic>{'page': page};
    if (kendaraanId != null) params['kendaraan_id'] = kendaraanId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (aktif != null) params['aktif'] = aktif ? 1 : 0;
    final r = await _apiClient.get(ApiConstants.penyewaan, queryParameters: params);
    final body = r.data;
    return (
      items: (body['data'] as List).map((e) => PenyewaanModel.fromJson(e)).toList(),
      meta: PaginationMeta.fromJson(body['meta'] ?? body),
    );
  }

  @override Future<PenyewaanModel> getById(int id) async {
    final r = await _apiClient.get('${ApiConstants.penyewaan}/$id');
    return PenyewaanModel.fromJson(r.data['data']);
  }

  @override Future<PenyewaanModel> create(Map<String, dynamic> data) async {
    final r = await _apiClient.post(ApiConstants.penyewaan, data: data);
    return PenyewaanModel.fromJson(r.data['data']);
  }

  @override Future<PenyewaanModel> update(int id, Map<String, dynamic> data) async {
    final r = await _apiClient.put('${ApiConstants.penyewaan}/$id', data: data);
    return PenyewaanModel.fromJson(r.data['data']);
  }

  @override Future<void> delete(int id) async {
    await _apiClient.delete('${ApiConstants.penyewaan}/$id');
  }
}
