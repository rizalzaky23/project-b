import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/utils/pagination_meta.dart';
import '../models/kendaraan_model.dart';

abstract class KendaraanRemoteDataSource {
  Future<({List<KendaraanModel> items, PaginationMeta meta})> getAll({
    int page = 1,
    String? search,
    String? merk,
    String? warna,
    int? tahunPembuatan,
  });
  Future<KendaraanModel> getById(int id);
  Future<KendaraanModel> create(FormData formData);
  Future<KendaraanModel> update(int id, FormData formData);
  Future<void> delete(int id);
}

class KendaraanRemoteDataSourceImpl implements KendaraanRemoteDataSource {
  final ApiClient _apiClient;

  KendaraanRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<KendaraanModel> items, PaginationMeta meta})> getAll({
    int page = 1,
    String? search,
    String? merk,
    String? warna,
    int? tahunPembuatan,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (merk != null) params['merk'] = merk;
    if (warna != null) params['warna'] = warna;
    if (tahunPembuatan != null) params['tahun_pembuatan'] = tahunPembuatan;

    final response = await _apiClient.get(ApiConstants.kendaraan, queryParameters: params);
    final data = response.data['data'];
    final items = (data['data'] as List).map((e) => KendaraanModel.fromJson(e)).toList();
    final meta = PaginationMeta.fromJson(data);
    return (items: items, meta: meta);
  }

  @override
  Future<KendaraanModel> getById(int id) async {
    final response = await _apiClient.get('${ApiConstants.kendaraan}/$id');
    return KendaraanModel.fromJson(response.data['data']);
  }

  @override
  Future<KendaraanModel> create(FormData formData) async {
    final response = await _apiClient.post(ApiConstants.kendaraan, data: formData);
    return KendaraanModel.fromJson(response.data['data']);
  }

  @override
  Future<KendaraanModel> update(int id, FormData formData) async {
    // Laravel needs _method=PUT for multipart
    formData.fields.add(const MapEntry('_method', 'PUT'));
    final response = await _apiClient.post('${ApiConstants.kendaraan}/$id', data: formData);
    return KendaraanModel.fromJson(response.data['data']);
  }

  @override
  Future<void> delete(int id) async {
    await _apiClient.delete('${ApiConstants.kendaraan}/$id');
  }
}
