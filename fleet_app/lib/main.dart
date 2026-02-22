import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/dark_theme.dart';
import 'core/storage/token_storage.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/kendaraan/data/kendaraan_repository.dart';
import 'features/kendaraan/presentation/kendaraan_cubit.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/kendaraan/presentation/kendaraan_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();

  late final ApiClient apiClient;

  final authRepo = AuthRepository(() => apiClient, tokenStorage);

  apiClient = ApiClient(
    baseUrl: 'http://10.0.2.2:8000/api',
    tokenStorage: tokenStorage,
    onUnauthorized: () async => await authRepo.logout(),
  );

  final kendaraanRepo = KendaraanRepository(apiClient);

  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: authRepo),
      RepositoryProvider.value(value: kendaraanRepo),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepo)),
        BlocProvider(create: (_) => KendaraanCubit(kendaraanRepo)),
      ],
      child: const FleetApp(),
    ),
  ));
}

class FleetApp extends StatelessWidget {
  const FleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fleet Management',
      theme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: const RootRouter(),
    );
  }
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      if (state is Authenticated) {
        return const KendaraanListScreen();
      }
      return const LoginScreen();
    });
  }
}
