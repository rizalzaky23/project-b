import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/kendaraan/presentation/bloc/kendaraan_bloc.dart';
import 'features/kendaraan/presentation/screens/kendaraan_list_screen.dart';
import 'features/kendaraan/presentation/screens/kendaraan_form_screen.dart';
import 'features/kendaraan/presentation/screens/kendaraan_detail_screen.dart';
import 'features/detail_kendaraan/presentation/bloc/detail_kendaraan_bloc.dart';
import 'features/detail_kendaraan/presentation/screens/detail_kendaraan_list_screen.dart';
import 'features/detail_kendaraan/presentation/screens/detail_kendaraan_form_screen.dart';
import 'features/asuransi/presentation/bloc/asuransi_bloc.dart';
import 'features/asuransi/presentation/screens/asuransi_list_screen.dart';
import 'features/asuransi/presentation/screens/asuransi_form_screen.dart';
import 'features/kejadian/presentation/bloc/kejadian_bloc.dart';
import 'features/kejadian/presentation/screens/kejadian_list_screen.dart';
import 'features/kejadian/presentation/screens/kejadian_form_screen.dart';
import 'features/penyewaan/presentation/bloc/penyewaan_bloc.dart';
import 'features/penyewaan/presentation/screens/penyewaan_list_screen.dart';
import 'features/penyewaan/presentation/screens/penyewaan_form_screen.dart';
import 'injection_container.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;
    final isLoading = authState is AuthLoading || authState is AuthInitial;
    final isLoginPage = state.matchedLocation == '/login';

    if (isLoading) return null;
    if (!isLoggedIn && !isLoginPage) return '/login';
    if (isLoggedIn && isLoginPage) return '/dashboard';
    return null;
  },
  refreshListenable: _AuthStateListenable(),
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => MultiBlocProvider(providers: [
        BlocProvider(create: (_) => sl<KendaraanBloc>()),
        BlocProvider(create: (_) => sl<PenyewaanBloc>()),
        BlocProvider(create: (_) => sl<AsuransiBloc>()),
        BlocProvider(create: (_) => sl<KejadianBloc>()),
      ], child: const DashboardScreen()),
    ),
    GoRoute(
      path: '/kendaraan',
      builder: (_, __) => BlocProvider(create: (_) => sl<KendaraanBloc>(), child: const KendaraanListScreen()),
    ),
    GoRoute(
      path: '/kendaraan/create',
      builder: (_, __) => BlocProvider(create: (_) => sl<KendaraanBloc>(), child: const KendaraanFormScreen()),
    ),
    GoRoute(
      path: '/kendaraan/:id',
      builder: (ctx, state) {
        // Detail view - needs KendaraanBloc to load the entity
        // We pass from navigation extras or re-fetch
        return BlocProvider(create: (_) => sl<KendaraanBloc>(), child: _KendaraanDetailWrapper(id: int.parse(state.pathParameters['id']!)));
      },
    ),
    GoRoute(
      path: '/kendaraan/:id/edit',
      builder: (ctx, state) {
        return BlocProvider(create: (_) => sl<KendaraanBloc>(), child: _KendaraanEditWrapper(id: int.parse(state.pathParameters['id']!)));
      },
    ),
    GoRoute(
      path: '/detail-kendaraan',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(create: (_) => sl<DetailKendaraanBloc>(), child: DetailKendaraanListScreen(kendaraanId: kendaraanId != null ? int.parse(kendaraanId) : null));
      },
    ),
    GoRoute(
      path: '/detail-kendaraan/create',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(create: (_) => sl<DetailKendaraanBloc>(), child: DetailKendaraanFormScreen(kendaraanId: kendaraanId != null ? int.parse(kendaraanId) : null));
      },
    ),
    GoRoute(
      path: '/detail-kendaraan/:id/edit',
      builder: (ctx, state) => BlocProvider(create: (_) => sl<DetailKendaraanBloc>(), child: _DetailKendaraanEditWrapper(id: int.parse(state.pathParameters['id']!))),
    ),
    GoRoute(
      path: '/asuransi',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(create: (_) => sl<AsuransiBloc>(), child: AsuransiListScreen(kendaraanId: kendaraanId != null ? int.parse(kendaraanId) : null));
      },
    ),
    GoRoute(
      path: '/asuransi/create',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(create: (_) => sl<AsuransiBloc>(), child: AsuransiFormScreen(kendaraanId: kendaraanId != null ? int.parse(kendaraanId) : null));
      },
    ),
    GoRoute(
      path: '/asuransi/:id/edit',
      builder: (ctx, state) => BlocProvider(create: (_) => sl<AsuransiBloc>(), child: _AsuransiEditWrapper(id: int.parse(state.pathParameters['id']!))),
    ),
    GoRoute(
      path: '/kejadian',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(create: (_) => sl<KejadianBloc>(), child: KejadianListScreen(kendaraanId: kendaraanId != null ? int.parse(kendaraanId) : null));
      },
    ),
    GoRoute(
      path: '/kejadian/create',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(create: (_) => sl<KejadianBloc>(), child: KejadianFormScreen(kendaraanId: kendaraanId != null ? int.parse(kendaraanId) : null));
      },
    ),
    GoRoute(
      path: '/kejadian/:id/edit',
      builder: (ctx, state) => BlocProvider(create: (_) => sl<KejadianBloc>(), child: _KejadianEditWrapper(id: int.parse(state.pathParameters['id']!))),
    ),
    GoRoute(
      path: '/penyewaan',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(create: (_) => sl<PenyewaanBloc>(), child: PenyewaanListScreen(kendaraanId: kendaraanId != null ? int.parse(kendaraanId) : null));
      },
    ),
    GoRoute(
      path: '/penyewaan/create',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(create: (_) => sl<PenyewaanBloc>(), child: PenyewaanFormScreen(kendaraanId: kendaraanId != null ? int.parse(kendaraanId) : null));
      },
    ),
    GoRoute(
      path: '/penyewaan/:id/edit',
      builder: (ctx, state) => BlocProvider(create: (_) => sl<PenyewaanBloc>(), child: _PenyewaanEditWrapper(id: int.parse(state.pathParameters['id']!))),
    ),
  ],
);

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable() {
    sl<AuthBloc>().stream.listen((_) => notifyListeners());
  }
}

// Wrapper widgets to load entity then show form/detail

class _KendaraanDetailWrapper extends StatefulWidget {
  final int id;
  const _KendaraanDetailWrapper({required this.id});
  @override State<_KendaraanDetailWrapper> createState() => _KendaraanDetailWrapperState();
}

class _KendaraanDetailWrapperState extends State<_KendaraanDetailWrapper> {
  @override
  void initState() { super.initState(); context.read<KendaraanBloc>().add(KendaraanLoadRequested()); }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KendaraanBloc, KendaraanState>(
      builder: (ctx, state) {
        if (state is KendaraanLoaded) {
          final item = state.items.where((k) => k.id == widget.id).isNotEmpty ? state.items.firstWhere((k) => k.id == widget.id) : null;
          if (item != null) return KendaraanDetailScreen(kendaraan: item);
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _KendaraanEditWrapper extends StatefulWidget {
  final int id;
  const _KendaraanEditWrapper({required this.id});
  @override State<_KendaraanEditWrapper> createState() => _KendaraanEditWrapperState();
}

class _KendaraanEditWrapperState extends State<_KendaraanEditWrapper> {
  @override
  void initState() { super.initState(); context.read<KendaraanBloc>().add(KendaraanLoadRequested()); }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KendaraanBloc, KendaraanState>(
      builder: (ctx, state) {
        if (state is KendaraanLoaded) {
          final item = state.items.where((k) => k.id == widget.id).isNotEmpty ? state.items.firstWhere((k) => k.id == widget.id) : null;
          if (item != null) return KendaraanFormScreen(existing: item);
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _DetailKendaraanEditWrapper extends StatefulWidget {
  final int id;
  const _DetailKendaraanEditWrapper({required this.id});
  @override State<_DetailKendaraanEditWrapper> createState() => _DetailKendaraanEditWrapperState();
}

class _DetailKendaraanEditWrapperState extends State<_DetailKendaraanEditWrapper> {
  @override
  void initState() { super.initState(); context.read<DetailKendaraanBloc>().add(DetailKendaraanLoadRequested()); }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailKendaraanBloc, DetailKendaraanState>(
      builder: (ctx, state) {
        if (state is DetailKendaraanLoaded) {
          final item = state.items.where((k) => k.id == widget.id).isNotEmpty ? state.items.firstWhere((k) => k.id == widget.id) : null;
          if (item != null) return DetailKendaraanFormScreen(existing: item);
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _AsuransiEditWrapper extends StatefulWidget {
  final int id;
  const _AsuransiEditWrapper({required this.id});
  @override State<_AsuransiEditWrapper> createState() => _AsuransiEditWrapperState();
}

class _AsuransiEditWrapperState extends State<_AsuransiEditWrapper> {
  @override
  void initState() { super.initState(); context.read<AsuransiBloc>().add(AsuransiLoadRequested()); }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AsuransiBloc, AsuransiState>(
      builder: (ctx, state) {
        if (state is AsuransiLoaded) {
          final item = state.items.where((k) => k.id == widget.id).isNotEmpty ? state.items.firstWhere((k) => k.id == widget.id) : null;
          if (item != null) return AsuransiFormScreen(existing: item);
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _KejadianEditWrapper extends StatefulWidget {
  final int id;
  const _KejadianEditWrapper({required this.id});
  @override State<_KejadianEditWrapper> createState() => _KejadianEditWrapperState();
}

class _KejadianEditWrapperState extends State<_KejadianEditWrapper> {
  @override
  void initState() { super.initState(); context.read<KejadianBloc>().add(KejadianLoadRequested()); }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KejadianBloc, KejadianState>(
      builder: (ctx, state) {
        if (state is KejadianLoaded) {
          final item = state.items.where((k) => k.id == widget.id).isNotEmpty ? state.items.firstWhere((k) => k.id == widget.id) : null;
          if (item != null) return KejadianFormScreen(existing: item);
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _PenyewaanEditWrapper extends StatefulWidget {
  final int id;
  const _PenyewaanEditWrapper({required this.id});
  @override State<_PenyewaanEditWrapper> createState() => _PenyewaanEditWrapperState();
}

class _PenyewaanEditWrapperState extends State<_PenyewaanEditWrapper> {
  @override
  void initState() { super.initState(); context.read<PenyewaanBloc>().add(PenyewaanLoadRequested()); }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PenyewaanBloc, PenyewaanState>(
      builder: (ctx, state) {
        if (state is PenyewaanLoaded) {
          final item = state.items.where((k) => k.id == widget.id).isNotEmpty ? state.items.firstWhere((k) => k.id == widget.id) : null;
          if (item != null) return PenyewaanFormScreen(existing: item);
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
