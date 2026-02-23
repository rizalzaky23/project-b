import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/dark_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'injection_container.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  setupDependencies();

  // Trigger AuthCheckRequested pada singleton AuthBloc setelah dependencies siap
  sl<AuthBloc>().add(AuthCheckRequested());

  runApp(const FleetApp());
}

class FleetApp extends StatelessWidget {
  const FleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // Gunakan singleton yang sama, BUKAN buat instance baru
      value: sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Fleet Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
