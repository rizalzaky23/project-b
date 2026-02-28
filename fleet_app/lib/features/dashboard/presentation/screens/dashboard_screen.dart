import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../core/theme/theme_notifier.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../kendaraan/presentation/bloc/kendaraan_bloc.dart';
import '../../../penyewaan/presentation/bloc/penyewaan_bloc.dart';
import '../../../asuransi/presentation/bloc/asuransi_bloc.dart';
import '../../../kejadian/presentation/bloc/kejadian_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<KendaraanBloc>().add(KendaraanLoadRequested());
    context.read<PenyewaanBloc>().add(PenyewaanLoadRequested(aktif: true));
    context.read<AsuransiBloc>().add(AsuransiLoadRequested());
    context.read<KejadianBloc>().add(KejadianLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final user = (context.read<AuthBloc>().state is AuthAuthenticated)
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Management'),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
                icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                onPressed: () {
                  themeNotifier.value =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, size: 18, color: AppTheme.error),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: AppTheme.error)),
                ]),
              ),
            ],
            onSelected: (val) {
              if (val == 'logout') {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<KendaraanBloc>().add(KendaraanLoadRequested());
          context.read<PenyewaanBloc>().add(PenyewaanLoadRequested(aktif: true));
          context.read<AsuransiBloc>().add(AsuransiLoadRequested());
          context.read<KejadianBloc>().add(KejadianLoadRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 16, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1000 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user?.name ?? 'User'),
                const SizedBox(height: 24),
                _buildStats(isDesktop),
                const SizedBox(height: 32),
                _buildNavGrid(context, isDesktop),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Halo, $name 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Berikut ringkasan armada kendaraan Anda', style: TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildStats(bool isDesktop) {
    return BlocBuilder<KendaraanBloc, KendaraanState>(
      builder: (_, kState) {
        final totalKendaraan = kState is KendaraanLoaded ? kState.meta.total : 0;
        return BlocBuilder<PenyewaanBloc, PenyewaanState>(
          builder: (_, pState) {
            final aktifSewa = pState is PenyewaanLoaded ? pState.meta.total : 0;
            return BlocBuilder<AsuransiBloc, AsuransiState>(
              builder: (_, aState) {
                final totalAsuransi = aState is AsuransiLoaded ? aState.meta.total : 0;
                return BlocBuilder<KejadianBloc, KejadianState>(
                  builder: (_, kjState) {
                    final totalKejadian = kjState is KejadianLoaded ? kjState.meta.total : 0;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isDesktop ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isDesktop ? 1.4 : 1.2,
                      children: [
                        StatCard(title: 'Total Kendaraan', value: totalKendaraan.toString(), icon: Icons.directions_car_outlined, color: AppTheme.primary, onTap: () => context.go('/kendaraan')),
                        StatCard(title: 'Sewa Aktif', value: aktifSewa.toString(), icon: Icons.assignment_outlined, color: AppTheme.secondary, onTap: () => context.go('/penyewaan')),
                        StatCard(title: 'Asuransi', value: totalAsuransi.toString(), icon: Icons.health_and_safety_outlined, color: AppTheme.success, onTap: () => context.go('/asuransi')),
                        StatCard(title: 'Kejadian', value: totalKejadian.toString(), icon: Icons.report_problem_outlined, color: AppTheme.warning, onTap: () => context.go('/kejadian')),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNavGrid(BuildContext context, bool isDesktop) {
    final items = [
      _NavItem('Kendaraan', Icons.directions_car_outlined, AppTheme.primary, '/kendaraan'),
      _NavItem('Detail Kendaraan', Icons.description_outlined, const Color(0xFF4DB6AC), '/detail-kendaraan'),
      _NavItem('Asuransi', Icons.health_and_safety_outlined, AppTheme.success, '/asuransi'),
      _NavItem('Kejadian', Icons.report_problem_outlined, AppTheme.warning, '/kejadian'),
      _NavItem('Penyewaan', Icons.assignment_outlined, AppTheme.secondary, '/penyewaan'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Menu Utama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 5 : 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            return GestureDetector(
              onTap: () => context.go(item.route),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: item.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(item.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NavItem {
  final String label, route;
  final IconData icon;
  final Color color;

  _NavItem(this.label, this.icon, this.color, this.route);
}
