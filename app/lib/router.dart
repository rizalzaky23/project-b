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
import 'features/kendaraan/domain/entities/kendaraan_entity.dart';
import 'features/detail_kendaraan/presentation/screens/detail_kendaraan_detail_screen.dart';
import 'features/asuransi/presentation/screens/asuransi_detail_screen.dart';
import 'features/kejadian/presentation/screens/kejadian_detail_screen.dart';
import 'features/penyewaan/presentation/screens/penyewaan_detail_screen.dart';
import 'features/detail_kendaraan/presentation/bloc/detail_kendaraan_bloc.dart';
import 'features/detail_kendaraan/presentation/screens/detail_kendaraan_list_screen.dart';
import 'features/detail_kendaraan/presentation/screens/detail_kendaraan_form_screen.dart';
import 'features/detail_kendaraan/domain/entities/detail_kendaraan_entity.dart';
import 'features/asuransi/presentation/bloc/asuransi_bloc.dart';
import 'features/asuransi/presentation/screens/asuransi_list_screen.dart';
import 'features/asuransi/presentation/screens/asuransi_form_screen.dart';
import 'features/asuransi/domain/entities/asuransi_entity.dart';
import 'features/kejadian/presentation/bloc/kejadian_bloc.dart';
import 'features/kejadian/presentation/screens/kejadian_list_screen.dart';
import 'features/kejadian/presentation/screens/kejadian_form_screen.dart';
import 'features/kejadian/domain/entities/kejadian_entity.dart';
import 'features/penyewaan/presentation/bloc/penyewaan_bloc.dart';
import 'features/penyewaan/presentation/screens/penyewaan_list_screen.dart';
import 'features/penyewaan/presentation/screens/penyewaan_form_screen.dart';
import 'features/penyewaan/domain/entities/penyewaan_entity.dart';
import 'core/trial/trial_service.dart';
import 'core/trial/trial_expired_screen.dart';
import 'injection_container.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/dashboard',
  redirect: (context, state) async {
    final authState = context.read<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;
    final isLoading = authState is AuthLoading || authState is AuthInitial;
    final isLoginPage = state.matchedLocation == '/login';
    final isTrialExpiredPage = state.matchedLocation == '/trial-expired';

    if (isLoading) return null;
    if (!isLoggedIn && !isLoginPage) return '/login';
    if (isLoggedIn && isLoginPage) return '/dashboard';

    // Cek trial hanya untuk halaman yang memerlukan akses penuh
    if (isLoggedIn && !isTrialExpiredPage) {
      final trialActive = await TrialService.instance.isTrialActive();
      if (!trialActive) return '/trial-expired';
    }

    return null;
  },
  refreshListenable: _AuthStateListenable(),
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    // ── Trial Expired ──────────────────────────────────────────────────────
    GoRoute(
      path: '/trial-expired',
      builder: (_, __) => const TrialExpiredScreen(),
    ),

    // ── Dashboard ──────────────────────────────────────────────────────────
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => MultiBlocProvider(providers: [
        BlocProvider(create: (_) => sl<KendaraanBloc>()),
        BlocProvider(create: (_) => sl<PenyewaanBloc>()),
        BlocProvider(create: (_) => sl<AsuransiBloc>()),
        BlocProvider(create: (_) => sl<KejadianBloc>()),
      ], child: const DashboardScreen()),
    ),

    // ── Kendaraan ──────────────────────────────────────────────────────────
    GoRoute(
      path: '/kendaraan',
      builder: (_, __) => BlocProvider(
          create: (_) => sl<KendaraanBloc>(),
          child: const KendaraanListScreen()),
    ),
    GoRoute(
      path: '/kendaraan/create',
      builder: (_, __) => BlocProvider(
          create: (_) => sl<KendaraanBloc>(),
          child: const KendaraanFormScreen()),
    ),
    GoRoute(
      path: '/kendaraan/:id',
      builder: (ctx, state) {
        final entity = state.extra as KendaraanEntity?;
        if (entity != null) {
          return KendaraanDetailScreen(kendaraan: entity);
        }
        return BlocProvider(
          create: (_) => sl<KendaraanBloc>(),
          child: _FetchAndShowKendaraanDetail(
              id: int.parse(state.pathParameters['id']!)),
        );
      },
    ),
    GoRoute(
      path: '/kendaraan/:id/edit',
      builder: (ctx, state) {
        final entity = state.extra as KendaraanEntity?;
        return BlocProvider(
          create: (_) => sl<KendaraanBloc>(),
          child: KendaraanFormScreen(existing: entity),
        );
      },
    ),

    // ── Detail Kendaraan ───────────────────────────────────────────────────
    GoRoute(
      path: '/detail-kendaraan',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(
          create: (_) => sl<DetailKendaraanBloc>(),
          child: DetailKendaraanListScreen(
              kendaraanId:
                  kendaraanId != null ? int.parse(kendaraanId) : null),
        );
      },
    ),
    GoRoute(
      path: '/detail-kendaraan/create',
      builder: (ctx, state) {
        // Support both extra map (new pattern) and query params (fallback)
        final extra = state.extra as Map<String, dynamic>?;
        final kendaraanId = extra?['kendaraanId'] as int? ??
            (state.uri.queryParameters['kendaraan_id'] != null
                ? int.parse(state.uri.queryParameters['kendaraan_id']!)
                : null);
        return BlocProvider(
          create: (_) => sl<DetailKendaraanBloc>(),
          child: DetailKendaraanFormScreen(kendaraanId: kendaraanId),
        );
      },
    ),
    GoRoute(
      path: '/detail-kendaraan/:id',
      builder: (ctx, state) {
        final entity = state.extra as DetailKendaraanEntity?;
        if (entity != null) {
          return DetailKendaraanDetailScreen(item: entity);
        }
        return BlocProvider(
          create: (_) => sl<DetailKendaraanBloc>(),
          child: _FetchAndShowDetailKendaraan(
              id: int.parse(state.pathParameters['id']!)),
        );
      },
    ),
    GoRoute(
      path: '/detail-kendaraan/:id/edit',
      builder: (ctx, state) {
        final entity = state.extra as DetailKendaraanEntity?;
        return BlocProvider(
          create: (_) => sl<DetailKendaraanBloc>(),
          child: DetailKendaraanFormScreen(existing: entity),
        );
      },
    ),

    // ── Asuransi ───────────────────────────────────────────────────────────
    GoRoute(
      path: '/asuransi',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(
          create: (_) => sl<AsuransiBloc>(),
          child: AsuransiListScreen(
              kendaraanId:
                  kendaraanId != null ? int.parse(kendaraanId) : null),
        );
      },
    ),
    GoRoute(
      path: '/asuransi/create',
      builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final kendaraanId = extra?['kendaraanId'] as int?;
        return BlocProvider(
          create: (_) => sl<AsuransiBloc>(),
          child: AsuransiFormScreen(kendaraanId: kendaraanId),
        );
      },
    ),
    GoRoute(
      path: '/asuransi/:id',
      builder: (ctx, state) {
        final entity = state.extra as AsuransiEntity?;
        if (entity != null) {
          return AsuransiDetailScreen(item: entity);
        }
        return BlocProvider(
          create: (_) => sl<AsuransiBloc>(),
          child: _FetchAndShowAsuransi(
              id: int.parse(state.pathParameters['id']!)),
        );
      },
    ),
    GoRoute(
      path: '/asuransi/:id/edit',
      builder: (ctx, state) {
        final entity = state.extra as AsuransiEntity?;
        return BlocProvider(
          create: (_) => sl<AsuransiBloc>(),
          child: AsuransiFormScreen(existing: entity),
        );
      },
    ),

    // ── Kejadian ───────────────────────────────────────────────────────────
    GoRoute(
      path: '/kejadian',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(
          create: (_) => sl<KejadianBloc>(),
          child: KejadianListScreen(
              kendaraanId:
                  kendaraanId != null ? int.parse(kendaraanId) : null),
        );
      },
    ),
    GoRoute(
      path: '/kejadian/create',
      builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final kendaraanId = extra?['kendaraanId'] as int?;
        return BlocProvider(
          create: (_) => sl<KejadianBloc>(),
          child: KejadianFormScreen(kendaraanId: kendaraanId),
        );
      },
    ),
    GoRoute(
      path: '/kejadian/:id',
      builder: (ctx, state) {
        final entity = state.extra as KejadianEntity?;
        if (entity != null) {
          return KejadianDetailScreen(item: entity);
        }
        return BlocProvider(
          create: (_) => sl<KejadianBloc>(),
          child: _FetchAndShowKejadian(
              id: int.parse(state.pathParameters['id']!)),
        );
      },
    ),
    GoRoute(
      path: '/kejadian/:id/edit',
      builder: (ctx, state) {
        final entity = state.extra as KejadianEntity?;
        return BlocProvider(
          create: (_) => sl<KejadianBloc>(),
          child: KejadianFormScreen(existing: entity),
        );
      },
    ),

    // ── Penyewaan ──────────────────────────────────────────────────────────
    GoRoute(
      path: '/penyewaan',
      builder: (ctx, state) {
        final kendaraanId = state.uri.queryParameters['kendaraan_id'];
        return BlocProvider(
          create: (_) => sl<PenyewaanBloc>(),
          child: PenyewaanListScreen(
              kendaraanId:
                  kendaraanId != null ? int.parse(kendaraanId) : null),
        );
      },
    ),
    GoRoute(
      path: '/penyewaan/create',
      builder: (ctx, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final kendaraanId = extra?['kendaraanId'] as int?;
        return BlocProvider(
          create: (_) => sl<PenyewaanBloc>(),
          child: PenyewaanFormScreen(kendaraanId: kendaraanId),
        );
      },
    ),
    GoRoute(
      path: '/penyewaan/:id',
      builder: (ctx, state) {
        final entity = state.extra as PenyewaanEntity?;
        if (entity != null) {
          return PenyewaanDetailScreen(item: entity);
        }
        return BlocProvider(
          create: (_) => sl<PenyewaanBloc>(),
          child: _FetchAndShowPenyewaan(
              id: int.parse(state.pathParameters['id']!)),
        );
      },
    ),
    GoRoute(
      path: '/penyewaan/:id/edit',
      builder: (ctx, state) {
        final entity = state.extra as PenyewaanEntity?;
        return BlocProvider(
          create: (_) => sl<PenyewaanBloc>(),
          child: PenyewaanFormScreen(existing: entity),
        );
      },
    ),
  ],
);

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable() {
    sl<AuthBloc>().stream.listen((_) => notifyListeners());
  }
}

// ─── Fallback fetch widgets ────────────────────────────────────────────────

class _FetchAndShowKendaraanDetail extends StatefulWidget {
  final int id;
  const _FetchAndShowKendaraanDetail({required this.id});
  @override
  State<_FetchAndShowKendaraanDetail> createState() =>
      _FetchAndShowKendaraanDetailState();
}

class _FetchAndShowKendaraanDetailState
    extends State<_FetchAndShowKendaraanDetail> {
  @override
  void initState() {
    super.initState();
    context.read<KendaraanBloc>().add(KendaraanLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KendaraanBloc, KendaraanState>(
      builder: (ctx, state) {
        if (state is KendaraanLoaded) {
          try {
            final item = state.items.firstWhere((k) => k.id == widget.id);
            return KendaraanDetailScreen(kendaraan: item);
          } catch (_) {}
        }
        if (state is KendaraanError) {
          return Scaffold(body: Center(child: Text(state.failure.message)));
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _FetchAndShowDetailKendaraan extends StatefulWidget {
  final int id;
  const _FetchAndShowDetailKendaraan({required this.id});
  @override
  State<_FetchAndShowDetailKendaraan> createState() =>
      _FetchAndShowDetailKendaraanState();
}

class _FetchAndShowDetailKendaraanState
    extends State<_FetchAndShowDetailKendaraan> {
  @override
  void initState() {
    super.initState();
    context.read<DetailKendaraanBloc>().add(DetailKendaraanLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailKendaraanBloc, DetailKendaraanState>(
      builder: (ctx, state) {
        if (state is DetailKendaraanLoaded) {
          try {
            final item = state.items.firstWhere((k) => k.id == widget.id);
            return DetailKendaraanDetailScreen(item: item);
          } catch (_) {}
        }
        if (state is DetailKendaraanError) {
          return Scaffold(body: Center(child: Text(state.failure.message)));
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _FetchAndShowAsuransi extends StatefulWidget {
  final int id;
  const _FetchAndShowAsuransi({required this.id});
  @override
  State<_FetchAndShowAsuransi> createState() => _FetchAndShowAsuransiState();
}

class _FetchAndShowAsuransiState extends State<_FetchAndShowAsuransi> {
  @override
  void initState() {
    super.initState();
    context.read<AsuransiBloc>().add(AsuransiLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AsuransiBloc, AsuransiState>(
      builder: (ctx, state) {
        if (state is AsuransiLoaded) {
          try {
            final item = state.items.firstWhere((k) => k.id == widget.id);
            return AsuransiDetailScreen(item: item);
          } catch (_) {}
        }
        if (state is AsuransiError) {
          return Scaffold(body: Center(child: Text(state.failure.message)));
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _FetchAndShowKejadian extends StatefulWidget {
  final int id;
  const _FetchAndShowKejadian({required this.id});
  @override
  State<_FetchAndShowKejadian> createState() => _FetchAndShowKejadianState();
}

class _FetchAndShowKejadianState extends State<_FetchAndShowKejadian> {
  @override
  void initState() {
    super.initState();
    context.read<KejadianBloc>().add(KejadianLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KejadianBloc, KejadianState>(
      builder: (ctx, state) {
        if (state is KejadianLoaded) {
          try {
            final item = state.items.firstWhere((k) => k.id == widget.id);
            return KejadianDetailScreen(item: item);
          } catch (_) {}
        }
        if (state is KejadianError) {
          return Scaffold(body: Center(child: Text(state.failure.message)));
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class _FetchAndShowPenyewaan extends StatefulWidget {
  final int id;
  const _FetchAndShowPenyewaan({required this.id});
  @override
  State<_FetchAndShowPenyewaan> createState() =>
      _FetchAndShowPenyewaanState();
}

class _FetchAndShowPenyewaanState extends State<_FetchAndShowPenyewaan> {
  @override
  void initState() {
    super.initState();
    context.read<PenyewaanBloc>().add(PenyewaanLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PenyewaanBloc, PenyewaanState>(
      builder: (ctx, state) {
        if (state is PenyewaanLoaded) {
          try {
            final item = state.items.firstWhere((k) => k.id == widget.id);
            return PenyewaanDetailScreen(item: item);
          } catch (_) {}
        }
        if (state is PenyewaanError) {
          return Scaffold(body: Center(child: Text(state.failure.message)));
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
