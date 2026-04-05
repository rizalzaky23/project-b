import '../entities/merek_entity.dart';

abstract class MerekRepository {
  Future<List<MerekEntity>> getAll();
  Future<MerekEntity> create(String nama);
  Future<MerekEntity> update(int id, String nama);
  Future<void> delete(int id);
}
