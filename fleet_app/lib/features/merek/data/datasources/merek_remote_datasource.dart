import '../../../../core/network/api_client.dart';
import '../models/merek_model.dart';

abstract class MerekRemoteDataSource {
  Future<List<MerekModel>> getAll();
  Future<MerekModel> create(String nama);
  Future<MerekModel> update(int id, String nama);
  Future<void> delete(int id);
}

class MerekRemoteDataSourceImpl implements MerekRemoteDataSource {
  final ApiClient client;
  MerekRemoteDataSourceImpl(this.client);

  @override
  Future<List<MerekModel>> getAll() async {
    final response = await client.get('/mereks');
    return (response.data['data'] as List)
        .map((x) => MerekModel.fromJson(x))
        .toList();
  }

  @override
  Future<MerekModel> create(String nama) async {
    final response = await client.post('/mereks', data: {'nama': nama});
    return MerekModel.fromJson(response.data['data']);
  }

  @override
  Future<MerekModel> update(int id, String nama) async {
    final response = await client.put('/mereks/$id', data: {'nama': nama});
    return MerekModel.fromJson(response.data['data']);
  }

  @override
  Future<void> delete(int id) async {
    await client.delete('/mereks/$id');
  }
}
