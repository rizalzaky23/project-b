import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/utils/pagination_meta.dart';
import '../models/kejadian_model.dart';

abstract class KejadianRemoteDataSource {
  Future<({List<KejadianModel> items, PaginationMeta meta})> getAll({int page=1, int? kendaraanId, String? search});
  Future<KejadianModel> getById(int id);
  Future<KejadianModel> create(FormData f);
  Future<KejadianModel> update(int id, FormData f);
  Future<void> delete(int id);
}

class KejadianRemoteDataSourceImpl implements KejadianRemoteDataSource {
  final ApiClient _apiClient;
  KejadianRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<KejadianModel> items, PaginationMeta meta})> getAll({int page=1, int? kendaraanId, String? search}) async {
    final params = <String,dynamic>{'page': page};
    if (kendaraanId != null) params['kendaraan_id'] = kendaraanId;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final r = await _apiClient.get(ApiConstants.kejadianKendaraan, queryParameters: params);
    final data = r.data['data'];
    return (items: (data['data'] as List).map((e) => KejadianModel.fromJson(e)).toList(), meta: PaginationMeta.fromJson(data));
  }

  @override Future<KejadianModel> getById(int id) async { final r = await _apiClient.get('${ApiConstants.kejadianKendaraan}/$id'); return KejadianModel.fromJson(r.data['data']); }
  @override Future<KejadianModel> create(FormData f) async { final r = await _apiClient.post(ApiConstants.kejadianKendaraan, data: f); return KejadianModel.fromJson(r.data['data']); }
  @override Future<KejadianModel> update(int id, FormData f) async { f.fields.add(const MapEntry('_method','PUT')); final r = await _apiClient.post('${ApiConstants.kejadianKendaraan}/$id', data: f); return KejadianModel.fromJson(r.data['data']); }
  @override Future<void> delete(int id) async { await _apiClient.delete('${ApiConstants.kejadianKendaraan}/$id'); }
}
