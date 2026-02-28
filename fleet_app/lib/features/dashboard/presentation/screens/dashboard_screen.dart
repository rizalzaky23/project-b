import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../core/theme/theme_notifier.dart';
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

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<KendaraanBloc>().add(KendaraanLoadRequested());
    context.read<PenyewaanBloc>().add(PenyewaanLoadRequested(aktif: true));
    context.read<AsuransiBloc>().add(AsuransiLoadRequested());
    context.read<KejadianBloc>().add(KejadianLoadRequested());
  }

  void _refresh() {
    context.read<KendaraanBloc>().add(KendaraanLoadRequested());
    context.read<PenyewaanBloc>().add(PenyewaanLoadRequested(aktif: true));
    context.read<AsuransiBloc>().add(AsuransiLoadRequested());
    context.read<KejadianBloc>().add(KejadianLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final user = (context.read<AuthBloc>().state is AuthAuthenticated)
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user
        : null;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context, user?.name ?? 'User', isDesktop),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop
                    ? 48
                    : isTablet
                        ? 32
                        : 20,
                vertical: 24,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _AnimatedIn(
                      delay: 0, child: _buildStats(isTablet, isDesktop)),
                  const SizedBox(height: 36),
                  _AnimatedIn(
                      delay: 150,
                      child: _buildMenuSection(context, isTablet, isDesktop)),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String name, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 200 : 185,
      floating: false,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _HeroBanner(name: name),
      ),
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF8B84FF)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Fleet Management',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: Colors.white,
              )),
        ],
      ),
      actions: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            final isDark = mode == ThemeMode.dark;
            return IconButton(
              tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                  size: 22,
                ),
              ),
              onPressed: () => themeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark,
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.4), width: 2),
            ),
            child: const CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 16),
            ),
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(children: [
                Icon(Icons.logout_rounded, size: 18, color: AppTheme.error),
                SizedBox(width: 10),
                Text('Logout',
                    style: TextStyle(
                        color: AppTheme.error, fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
          onSelected: (val) {
            if (val == 'logout')
              context.read<AuthBloc>().add(AuthLogoutRequested());
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStats(bool isTablet, bool isDesktop) {
    final cols = (isDesktop || isTablet) ? 4 : 2;
    final ratio = isDesktop
        ? 1.5
        : isTablet
            ? 1.3
            : 1.1;
    return BlocBuilder<KendaraanBloc, KendaraanState>(
      builder: (_, kState) {
        final total = kState is KendaraanLoaded ? kState.meta.total : 0;
        return BlocBuilder<PenyewaanBloc, PenyewaanState>(
          builder: (_, pState) {
            final sewa = pState is PenyewaanLoaded ? pState.meta.total : 0;
            return BlocBuilder<AsuransiBloc, AsuransiState>(
              builder: (_, aState) {
                final asuransi =
                    aState is AsuransiLoaded ? aState.meta.total : 0;
                return BlocBuilder<KejadianBloc, KejadianState>(
                  builder: (_, kjState) {
                    final kejadian =
                        kjState is KejadianLoaded ? kjState.meta.total : 0;
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: cols,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: ratio,
                      children: [
                        _StatCard(
                            title: 'Total Kendaraan',
                            value: '$total',
                            icon: Icons.directions_car_rounded,
                            color: AppTheme.primary,
                            gradColors: [
                              const Color(0xFF6C63FF),
                              const Color(0xFF8B84FF)
                            ],
                            onTap: () => context.go('/kendaraan'),
                            delay: 0),
                        _StatCard(
                            title: 'Sewa Aktif',
                            value: '$sewa',
                            icon: Icons.assignment_rounded,
                            color: AppTheme.secondary,
                            gradColors: [
                              const Color(0xFF03DAC6),
                              const Color(0xFF00BFA5)
                            ],
                            onTap: () => context.go('/penyewaan'),
                            delay: 60),
                        _StatCard(
                            title: 'Asuransi',
                            value: '$asuransi',
                            icon: Icons.health_and_safety_rounded,
                            color: AppTheme.success,
                            gradColors: [
                              const Color(0xFF4CAF50),
                              const Color(0xFF66BB6A)
                            ],
                            onTap: () => context.go('/asuransi'),
                            delay: 120),
                        _StatCard(
                            title: 'Kejadian',
                            value: '$kejadian',
                            icon: Icons.warning_rounded,
                            color: AppTheme.warning,
                            gradColors: [
                              const Color(0xFFFF9800),
                              const Color(0xFFFFB74D)
                            ],
                            onTap: () => context.go('/kejadian'),
                            delay: 180),
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

  Widget _buildMenuSection(
      BuildContext context, bool isTablet, bool isDesktop) {
    final items = [
      _NavItem('Kendaraan', Icons.directions_car_rounded, AppTheme.primary,
          '/kendaraan', 'Kelola armada'),
      _NavItem('Detail Kendaraan', Icons.description_rounded,
          const Color(0xFF4DB6AC), '/detail-kendaraan', 'STNK & BPKB'),
      _NavItem('Asuransi', Icons.health_and_safety_rounded, AppTheme.success,
          '/asuransi', 'Polis & premi'),
      _NavItem('Kejadian', Icons.warning_rounded, AppTheme.warning, '/kejadian',
          'Laporan insiden'),
      _NavItem('Penyewaan', Icons.assignment_rounded, AppTheme.secondary,
          '/penyewaan', 'Kontrak sewa'),
    ];

    final cols = isDesktop
        ? 5
        : isTablet
            ? 5
            : 3;
    final ratio = isDesktop
        ? 0.95
        : isTablet
            ? 0.88
            : 0.80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Menu Utama',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2)),
        ]),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: ratio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _AnimatedIn(
            delay: 200 + i * 60,
            child: _MenuCard(item: items[i]),
          ),
        ),
      ],
    );
  }
}

// ─── Hero Banner ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String name;
  const _HeroBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  const Color(0xFF1F3460)
                ]
              : [
                  const Color(0xFF6C63FF),
                  const Color(0xFF5B86E5),
                  const Color(0xFF48C9B0)
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
              top: -40,
              right: -40,
              child: _DecoCircle(size: 160, opacity: 0.07)),
          Positioned(
              bottom: -30,
              right: 60,
              child: _DecoCircle(size: 100, opacity: 0.05)),
          Positioned(
              top: 30, right: 130, child: _DecoCircle(size: 55, opacity: 0.09)),
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Halo, $name 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 5),
                Text('Berikut ringkasan armada kendaraan Anda',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 14,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecoCircle extends StatelessWidget {
  final double size, opacity;
  const _DecoCircle({required this.size, required this.opacity});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withOpacity(opacity), width: 2),
        ),
      );
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatefulWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final List<Color> gradColors;
  final VoidCallback onTap;
  final int delay;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradColors,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: widget.color.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(isDark ? 0.12 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: widget.gradColors),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 20),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: widget.color.withOpacity(0.4)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.value,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: widget.color,
                          height: 1)),
                  const SizedBox(height: 4),
                  Text(widget.title,
                      style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item & Menu Card ─────────────────────────────────────────────────────

class _NavItem {
  final String label, route, subtitle;
  final IconData icon;
  final Color color;
  const _NavItem(this.label, this.icon, this.color, this.route, this.subtitle);
}

class _MenuCard extends StatefulWidget {
  final _NavItem item;
  const _MenuCard({required this.item});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        context.go(widget.item.route);
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: widget.item.color.withOpacity(0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: widget.item.color.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.item.color.withOpacity(0.2)),
                ),
                child:
                    Icon(widget.item.icon, color: widget.item.color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                widget.item.label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                widget.item.subtitle,
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Animated Fade+Slide In ───────────────────────────────────────────────────

class _AnimatedIn extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedIn({required this.child, required this.delay});

  @override
  State<_AnimatedIn> createState() => _AnimatedInState();
}

class _AnimatedInState extends State<_AnimatedIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
        position: _slide,
        child: FadeTransition(opacity: _fade, child: widget.child),
      );
}
