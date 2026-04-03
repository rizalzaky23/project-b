import 'dart:async';
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

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Keluar Aplikasi'),
              content:
                  const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child:
                      const Text('Keluar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (shouldExit == true && context.mounted) {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          // ─ Stack: slider sebagai background, konten di atas ──────────────────
          body: Stack(
            children: [
              // Layer 1: background slider (seluruh layar)
              const Positioned.fill(child: _BodySlider()),

              // Layer 2: konten scroll di atasnya
              RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(
                        context, user?.name ?? 'User', isDesktop),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            isDesktop ? 48 : (isTablet ? 32 : 24),
                            24,
                            24,
                            8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${user?.name ?? 'User'} 👋',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Berikut ringkasan armada kendaraan Anda',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                              delay: 0,
                              child: _buildStats(isTablet, isDesktop)),
                          const SizedBox(height: 36),
                          _AnimatedIn(
                              delay: 150,
                              child: _buildMenuSection(
                                  context, isTablet, isDesktop)),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildSliverAppBar(BuildContext context, String name, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: isDesktop ? 200 : 160,
      floating: false,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
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
                  color: Colors.white,
                  letterSpacing: -0.3)),
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
          itemBuilder: (ctx) {
            final authState = ctx.read<AuthBloc>().state;
            final isSuperAdmin = authState is AuthAuthenticated &&
                authState.user.role == 'super_admin';
            return [
              if (isSuperAdmin)
                const PopupMenuItem(
                  value: 'users',
                  child: Row(children: [
                    Icon(Icons.manage_accounts_rounded,
                        size: 18, color: Color(0xFF6C63FF)),
                    SizedBox(width: 10),
                    Text('Kelola User',
                        style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w500)),
                  ]),
                ),
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
            ];
          },
          onSelected: (val) {
            if (val == 'logout') {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            } else if (val == 'users') {
              context.push('/users');
            }
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
                            gradColors: const [
                              Color(0xFF6C63FF),
                              Color(0xFF8B84FF)
                            ],
                            onTap: () => context.push('/kendaraan'),
                            delay: 0),
                        _StatCard(
                            title: 'Sewa Aktif',
                            value: '$sewa',
                            icon: Icons.assignment_rounded,
                            color: AppTheme.secondary,
                            gradColors: const [
                              Color(0xFF03DAC6),
                              Color(0xFF00BFA5)
                            ],
                            onTap: () => context.push('/penyewaan'),
                            delay: 60),
                        _StatCard(
                            title: 'Asuransi',
                            value: '$asuransi',
                            icon: Icons.health_and_safety_rounded,
                            color: AppTheme.success,
                            gradColors: const [
                              Color(0xFF4CAF50),
                              Color(0xFF66BB6A)
                            ],
                            onTap: () => context.push('/asuransi'),
                            delay: 120),
                        _StatCard(
                            title: 'Kejadian',
                            value: '$kejadian',
                            icon: Icons.warning_rounded,
                            color: AppTheme.warning,
                            gradColors: const [
                              Color(0xFFFF9800),
                              Color(0xFFFFB74D)
                            ],
                            onTap: () => context.push('/kejadian'),
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
      _NavItem('Kendaraan', Icons.directions_car_rounded,
          AppTheme.primary, 'Kelola armada',
          onTap: () => context.push('/kendaraan')),
      _NavItem('Mobil Terjual', Icons.sell_rounded,
          const Color(0xFFE53935), 'Filter terjual',
          onTap: () => context.push('/kendaraan?status=Terjual')),
      _NavItem('Detail Kendaraan', Icons.description_rounded,
          const Color(0xFF4DB6AC), 'STNK & BPKB',
          onTap: () => context.push('/detail-kendaraan')),
      _NavItem('Asuransi', Icons.health_and_safety_rounded,
          AppTheme.success, 'Polis & premi',
          onTap: () => context.push('/asuransi')),
      _NavItem('Kejadian', Icons.warning_rounded, AppTheme.warning,
          'Laporan insiden',
          onTap: () => context.push('/kejadian')),
      _NavItem('Penyewaan', Icons.assignment_rounded, AppTheme.secondary,
          'Kontrak sewa',
          onTap: () => context.push('/penyewaan')),
    ];

    // Tambah menu Kelola User untuk super_admin
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated &&
        authState.user.role == 'super_admin') {
      items.add(_NavItem(
        'Kelola User',
        Icons.manage_accounts_rounded,
        const Color(0xFF6C63FF),
        'Tambah & atur akun',
        onTap: () => context.push('/users'),
      ));
    }

    final cols = isDesktop
        ? 6
        : isTablet
            ? 6
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

// ─── Hero Banner (3 Logo PT) ──────────────────────────────────────────────────
// 📁 Logo PT  →  assets/images/logo1.png | logo2.png | logo3.png

class _HeroBanner extends StatelessWidget {
  final String name;
  const _HeroBanner({required this.name});

  static const _logos = [
    'assets/images/logo1.png',
    'assets/images/logo2.png',
    'assets/images/logo3.png',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.15);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Gradient gelap khas banner
          colors: isDark
              ? [const Color(0xFF0D0D1C), const Color(0xFF151525)]
              : [const Color(0xFF0D1B6E), const Color(0xFF1A237E)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_logos.length, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    _logos[i],
                    height: 130, // Ukuran logo fix lebih besar
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.business_rounded,
                      color: Colors.white.withOpacity(0.5),
                      size: 64,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Body Slider (Background) ────────────────────────────────────────────────

class _BodySlider extends StatefulWidget {
  const _BodySlider();
  @override
  State<_BodySlider> createState() => _BodySliderState();
}

class _BodySliderState extends State<_BodySlider> {
  static const _slides = [
    'assets/images/slide1.png',
    'assets/images/slide2.png',
    'assets/images/slide3.png',
  ];

  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        PageView.builder(
          controller: _pageCtrl,
          onPageChanged: (p) => setState(() => _currentPage = p),
          itemCount: _slides.length,
          itemBuilder: (_, i) => Image.asset(
            _slides[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF2D2B55)]
                      : [const Color(0xFF3949AB), const Color(0xFF1E88E5)],
                ),
              ),
            ),
          ),
        ),
        
        // Gradient gelap untuk memastikan konten tetap jelas
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.85),
              ],
              stops: const [0.1, 0.9],
            ),
          ),
        ),
      ],
    );
  }
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
  final String label, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _NavItem(this.label, this.icon, this.color, this.subtitle,
      {required this.onTap});
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
    final color = widget.item.color;
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.item.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full-card gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      Color.lerp(color, Colors.black, 0.28)!,
                    ],
                  ),
                ),
              ),

              // Decorative circle top-right
              Positioned(
                top: -14,
                right: -14,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
              ),

              // Content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon – large, white
                    Expanded(
                      child: Center(
                        child: Icon(
                          widget.item.icon,
                          color: Colors.white,
                          size: 36,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                            )
                          ],
                        ),
                      ),
                    ),

                    // Divider line
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 7),

                    // Label
                    Text(
                      widget.item.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.item.subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 9,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
