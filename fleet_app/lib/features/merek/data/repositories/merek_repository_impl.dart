import 'package:dio/dio.dart';
import '../../../../shared/utils/api_helper.dart';
import '../../domain/entities/merek_entity.dart';
import '../../domain/repositories/merek_repository.dart';
import '../datasources/merek_remote_datasource.dart';

class MerekRepositoryImpl implements MerekRepository {
  final MerekRemoteDataSource remoteDataSource;

  MerekRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MerekEntity>> getAll() async {
    try {
      return await remoteDataSource.getAll();
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<MerekEntity> create(String nama) async {
    try {
      return await remoteDataSource.create(nama);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<MerekEntity> update(int id, String nama) async {
    try {
      return await remoteDataSource.update(id, nama);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await remoteDataSource.delete(id);
    } on DioException catch (e) {
      throw ApiHelper.handleError(e);
    }
  }
}
