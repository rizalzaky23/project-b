import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/kendaraan/data/datasources/kendaraan_remote_datasource.dart';
import '../features/kendaraan/data/repositories/kendaraan_repository_impl.dart';
import '../features/kendaraan/domain/repositories/kendaraan_repository.dart';
import '../features/kendaraan/presentation/bloc/kendaraan_bloc.dart';
import '../features/detail_kendaraan/data/datasources/detail_kendaraan_remote_datasource.dart';
import '../features/detail_kendaraan/data/repositories/detail_kendaraan_repository_impl.dart';
import '../features/detail_kendaraan/domain/repositories/detail_kendaraan_repository.dart';
import '../features/detail_kendaraan/presentation/bloc/detail_kendaraan_bloc.dart';
import '../features/asuransi/data/datasources/asuransi_remote_datasource.dart';
import '../features/asuransi/data/repositories/asuransi_repository_impl.dart';
import '../features/asuransi/domain/repositories/asuransi_repository.dart';
import '../features/asuransi/presentation/bloc/asuransi_bloc.dart';
import '../features/kejadian/data/datasources/kejadian_remote_datasource.dart';
import '../features/kejadian/data/repositories/kejadian_repository_impl.dart';
import '../features/kejadian/domain/repositories/kejadian_repository.dart';
import '../features/kejadian/presentation/bloc/kejadian_bloc.dart';
import '../features/penyewaan/data/datasources/penyewaan_remote_datasource.dart';
import '../features/penyewaan/data/repositories/penyewaan_repository_impl.dart';
import '../features/penyewaan/domain/repositories/penyewaan_repository.dart';
import '../features/penyewaan/presentation/bloc/penyewaan_bloc.dart';
import '../features/servis/data/datasources/servis_remote_datasource.dart';
import '../features/servis/data/repositories/servis_repository_impl.dart';
import '../features/servis/domain/repositories/servis_repository.dart';
import '../features/servis/presentation/bloc/servis_bloc.dart';
import '../features/user_management/data/datasources/user_remote_datasource.dart';
import '../features/user_management/data/repositories/user_repository_impl.dart';
import '../features/user_management/domain/repositories/user_repository.dart';
import '../features/user_management/presentation/bloc/user_bloc.dart';
import '../features/merek/data/datasources/merek_remote_datasource.dart';
import '../features/merek/data/repositories/merek_repository_impl.dart';
import '../features/merek/domain/repositories/merek_repository.dart';
import '../features/merek/presentation/bloc/merek_bloc.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenStorage(sl()));
  sl.registerLazySingleton(() => ApiClient(sl(), onUnauthorized: () {
    // Hanya logout jika AuthBloc sudah terdaftar dan sudah authenticated
    if (sl.isRegistered<AuthBloc>()) {
      sl<AuthBloc>().add(AuthLogoutRequested());
    }
  }));

  // Auth — kirim ApiClient ke AuthRepositoryImpl untuk kontrol flag authenticating
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => AuthBloc(sl())); // singleton agar router & UI pakai instance yang sama

  // Kendaraan
  sl.registerLazySingleton<KendaraanRemoteDataSource>(() => KendaraanRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<KendaraanRepository>(() => KendaraanRepositoryImpl(sl()));
  sl.registerFactory(() => KendaraanBloc(sl()));

  // Detail Kendaraan
  sl.registerLazySingleton<DetailKendaraanRemoteDataSource>(() => DetailKendaraanRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<DetailKendaraanRepository>(() => DetailKendaraanRepositoryImpl(sl()));
  sl.registerFactory(() => DetailKendaraanBloc(sl()));

  // Asuransi
  sl.registerLazySingleton<AsuransiRemoteDataSource>(() => AsuransiRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AsuransiRepository>(() => AsuransiRepositoryImpl(sl()));
  sl.registerFactory(() => AsuransiBloc(sl()));

  // Kejadian
  sl.registerLazySingleton<KejadianRemoteDataSource>(() => KejadianRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<KejadianRepository>(() => KejadianRepositoryImpl(sl()));
  sl.registerFactory(() => KejadianBloc(sl()));

  // Penyewaan
  sl.registerLazySingleton<PenyewaanRemoteDataSource>(() => PenyewaanRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<PenyewaanRepository>(() => PenyewaanRepositoryImpl(sl()));
  sl.registerFactory(() => PenyewaanBloc(sl()));

  // Servis
  sl.registerLazySingleton<ServisRemoteDataSource>(() => ServisRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ServisRepository>(() => ServisRepositoryImpl(sl()));
  sl.registerFactory(() => ServisBloc(sl()));

  // User Management
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerFactory(() => UserBloc(sl()));

  // Merek
  sl.registerLazySingleton<MerekRemoteDataSource>(() => MerekRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MerekRepository>(() => MerekRepositoryImpl(sl()));
  sl.registerFactory(() => MerekBloc(sl()));
}
