import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import 'kendaraan_model.dart';

class KendaraanRepository {
  final ApiClient api;

  KendaraanRepository(this.api);

  Future<List<Kendaraan>> fetchPage(int page, {int perPage = 15}) async {
    final resp = await api.get('/kendaraan', queryParameters: {'page': page, 'per_page': perPage});
    
    if (resp.statusCode != 200 || resp.data == null) {
      throw Exception('Failed to fetch kendaraan');
    }
    
    final data = resp.data as Map<String, dynamic>;
    final dataList = data['data'];
    if (dataList == null || dataList is! List<dynamic>) {
      return [];
    }
    
    final items = (dataList as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((e) => Kendaraan.fromJson(e))
        .toList();
    return items;
  }

  Future<Kendaraan> getDetail(int id) async {
    final resp = await api.get('/kendaraan/$id');
    
    if (resp.statusCode != 200 || resp.data == null) {
      throw Exception('Failed to fetch kendaraan detail');
    }
    
    final data = resp.data as Map<String, dynamic>;
    final detailData = data['data'] ?? data;
    return Kendaraan.fromJson(detailData as Map<String, dynamic>);
  }

  Future<Kendaraan> create(Map<String, dynamic> payload, {List<File>? photos}) async {
    final form = FormData.fromMap(payload);
    if (photos != null) {
      for (final p in photos) {
        form.files.add(MapEntry('photos[]', await MultipartFile.fromFile(p.path, filename: p.path.split(Platform.pathSeparator).last)));
      }
    }
    final resp = await api.post('/kendaraan', data: form);
    
    if (resp.statusCode != 201 || resp.data == null) {
      throw Exception('Failed to create kendaraan');
    }
    
    final data = resp.data as Map<String, dynamic>;
    final createdData = data['data'] ?? data;
    return Kendaraan.fromJson(createdData as Map<String, dynamic>);
  }

  Future<Kendaraan> update(int id, Map<String, dynamic> payload, {List<File>? photos}) async {
    final form = FormData.fromMap(payload);
    if (photos != null) {
      for (final p in photos) {
        form.files.add(MapEntry('photos[]', await MultipartFile.fromFile(p.path, filename: p.path.split(Platform.pathSeparator).last)));
      }
    }
    final resp = await api.post('/kendaraan/$id?_method=PUT', data: form);
    
    if (resp.statusCode != 200 || resp.data == null) {
      throw Exception('Failed to update kendaraan');
    }
    
    final data = resp.data as Map<String, dynamic>;
    final updatedData = data['data'] ?? data;
    return Kendaraan.fromJson(updatedData as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await api.delete('/kendaraan/$id');
  }
}
