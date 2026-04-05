import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../merek/presentation/bloc/merek_bloc.dart';
import '../bloc/kendaraan_bloc.dart';
import '../widgets/kendaraan_card.dart';

class KendaraanListScreen extends StatefulWidget {
  final String? initialStatus;
  final String? initialKepemilikan;

  const KendaraanListScreen({
    super.key,
    this.initialStatus,
    this.initialKepemilikan,
  });

  @override
  State<KendaraanListScreen> createState() => _KendaraanListScreenState();
}

class _KendaraanListScreenState extends State<KendaraanListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Filter state
  String? _selectedMerk;
  String? _selectedKepemilikan; // null = semua, 'PT1', 'PT2', 'PT3'
  String? _selectedStatus; // null = semua, 'Tersedia', 'Terjual'

  // Daftar pilihan kepemilikan PT (sama dengan saat input kendaraan)
  static const _kepemilikanOptions = ['PT1', 'PT2', 'PT3'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedKepemilikan = widget.initialKepemilikan;
    _loadData();
    context.read<MerekBloc>().add(MerekLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<KendaraanBloc>().add(KendaraanLoadRequested(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          merk: _selectedMerk,
          kepemilikan: _selectedKepemilikan,
          status: _selectedStatus,
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<KendaraanBloc>().add(KendaraanLoadMoreRequested());
    }
  }

  void _onSearch(String value) {
    setState(() {});
    context.read<KendaraanBloc>().add(KendaraanLoadRequested(
          search: value.isEmpty ? null : value,
          merk: _selectedMerk,
          kepemilikan: _selectedKepemilikan,
          status: _selectedStatus,
        ));
  }

  void _onMerkFilter(String? value) {
    setState(() => _selectedMerk = value);
    context.read<KendaraanBloc>().add(KendaraanLoadRequested(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          merk: value,
          kepemilikan: _selectedKepemilikan,
          status: _selectedStatus,
        ));
  }

  void _onStatusFilter(String? value) {
    setState(() => _selectedStatus = value);
    context.read<KendaraanBloc>().add(KendaraanLoadRequested(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          merk: _selectedMerk,
          kepemilikan: _selectedKepemilikan,
          status: value,
        ));
  }

  void _onKepemilikanFilter(String? value) {
    setState(() => _selectedKepemilikan = value);
    context.read<KendaraanBloc>().add(KendaraanLoadRequested(
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
          merk: _selectedMerk,
          kepemilikan: value,
          status: _selectedStatus,
        ));
  }

  Future<void> _onAddMerkRequested() async {
    await context.push('/mereks');
    if (mounted) {
      context.read<MerekBloc>().add(MerekLoadRequested());
    }
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _selectedMerk = null;
      _selectedKepemilikan = null;
      _selectedStatus = null;
    });
    context.read<KendaraanBloc>().add(KendaraanLoadRequested());
  }

  bool get _hasActiveFilter =>
      _selectedMerk != null ||
      _selectedKepemilikan != null ||
      _selectedStatus != null ||
      _searchController.text.isNotEmpty;

  Future<void> _goCreate() async {
    await context.push('/kendaraan/create');
    if (mounted) _loadData();
  }

  Future<void> _refresh() async {
    _loadData();
    context.read<MerekBloc>().add(MerekLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final hPad = isDesktop
        ? 48.0
        : isTablet
            ? 24.0
            : 16.0;
    final int crossAxisCount = isDesktop
        ? 4
        : isTablet
            ? 3
            : 2;
    final authState = context.read<AuthBloc>().state;
    final isSuperAdmin =
        authState is AuthAuthenticated && authState.user.role == 'super_admin';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/dashboard');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF8B84FF)]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.directions_car_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Kendaraan'),
          ]),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/dashboard'),
          ),
        ),
        body: BlocListener<KendaraanBloc, KendaraanState>(
          listener: (context, state) {
            if (state is KendaraanActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.success));
              _loadData();
            } else if (state is KendaraanActionError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: AppTheme.error));
            }
          },
          child: Column(children: [
            // ── Search bar ──────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search field
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Cari kendaraan...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppTheme.primary, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<MerekBloc, MerekState>(
                          builder: (context, merekState) {
                            List<String> merkOptions = [];
                            if (merekState is MerekLoaded) {
                              merkOptions = merekState.items.map((e) => e.nama).toList();
                            }
                            
                            return DropdownButtonFormField<String?>(
                              value: _selectedMerk,
                              decoration: const InputDecoration(
                                hintText: 'Filter merk',
                                prefixIcon: Icon(
                                  Icons.branding_watermark_rounded,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Semua merk'),
                                ),
                                ...merkOptions.map(
                                  (merk) => DropdownMenuItem<String?>(
                                    value: merk,
                                    child: Text(merk),
                                  ),
                                ),
                              ],
                              onChanged: _onMerkFilter,
                            );
                          }
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isSuperAdmin)
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.primary,
                          tooltip: 'Tambah merk baru',
                          onPressed: _onAddMerkRequested,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Filter chips row ──────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Clear semua filter
                        if (_hasActiveFilter) ...[
                          _FilterChip(
                            label: 'Reset',
                            icon: Icons.close_rounded,
                            selected: false,
                            isReset: true,
                            onTap: _clearAllFilters,
                          ),
                          const SizedBox(width: 6),
                          Container(
                              width: 1,
                              height: 24,
                              color: Theme.of(context).dividerColor),
                          const SizedBox(width: 6),
                        ],

                        if (_selectedMerk != null) ...[
                          _FilterChip(
                            label: _selectedMerk!,
                            icon: Icons.branding_watermark_rounded,
                            selected: true,
                            onTap: () => _onMerkFilter(null),
                          ),
                          const SizedBox(width: 6),
                        ],
                        // ── Filter STATUS ─────────────────────────────────
                        _FilterChip(
                          label: 'Semua',
                          selected: _selectedStatus == null,
                          onTap: () => _onStatusFilter(null),
                        ),
                        const SizedBox(width: 6),
                        _FilterChip(
                          label: 'Tersedia',
                          icon: Icons.check_circle_outline_rounded,
                          selected: _selectedStatus == 'Tersedia',
                          activeColor: AppTheme.success,
                          onTap: () => _onStatusFilter(
                              _selectedStatus == 'Tersedia'
                                  ? null
                                  : 'Tersedia'),
                        ),
                        const SizedBox(width: 6),
                        _FilterChip(
                          label: 'Terjual',
                          icon: Icons.sell_rounded,
                          selected: _selectedStatus == 'Terjual',
                          activeColor: const Color(0xFFE53935),
                          onTap: () => _onStatusFilter(
                              _selectedStatus == 'Terjual' ? null : 'Terjual'),
                        ),

                        const SizedBox(width: 10),
                        Container(
                            width: 1,
                            height: 24,
                            color: Theme.of(context).dividerColor),
                        const SizedBox(width: 10),

                        // ── Filter KEPEMILIKAN PT ─────────────────────────
                        _KepemilikanFilter(
                          selected: _selectedKepemilikan,
                          options: _kepemilikanOptions,
                          onChanged: (v) => _onKepemilikanFilter(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<KendaraanBloc, KendaraanState>(
                builder: (context, state) {
                  if (state is KendaraanLoading) return const AppLoading();
                  if (state is KendaraanError) {
                    return EmptyState(
                      message: state.failure.message,
                      icon: Icons.error_outline,
                      onRetry: () =>
                          context.read<KendaraanBloc>().add(_buildLoadEvent()),
                    );
                  }
                  if (state is KendaraanLoaded) {
                    if (state.items.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: const CustomScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              child: EmptyState(
                                message: 'Tidak ada kendaraan ditemukan',
                                icon: Icons.directions_car_outlined,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 4),
                            sliver: SliverToBoxAdapter(
                              child: Row(children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.primary,
                                        AppTheme.secondary
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${state.meta.total} kendaraan',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                if (_selectedStatus != null) ...[
                                  const SizedBox(width: 6),
                                  _StatusBadge(status: _selectedStatus!),
                                ],
                              ]),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 100),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: isDesktop
                                    ? 0.78
                                    : isTablet
                                        ? 0.76
                                        : 0.74,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = state.items[index];
                                  return KendaraanCard(
                                    kendaraan: item,
                                    onTap: () => context.push(
                                        '/kendaraan/${item.id}',
                                        extra: item),
                                    onEdit: () async {
                                      await context.push(
                                          '/kendaraan/${item.id}/edit',
                                          extra: item);
                                      if (context.mounted) {
                                        _loadData();
                                      }
                                    },
                                    onDelete: () async {
                                      final confirm = await showConfirmDialog(
                                        context,
                                        title: 'Hapus Kendaraan',
                                        message:
                                            'Yakin ingin menghapus ${item.merk} ${item.tipe}?',
                                      );
                                      if (confirm && context.mounted) {
                                        context.read<KendaraanBloc>().add(
                                            KendaraanDeleteRequested(item.id));
                                      }
                                    },
                                  );
                                },
                                childCount: state.items.length,
                              ),
                            ),
                          ),
                          if (state.isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: AppLoading(),
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ]),
        ),
        floatingActionButton: Builder(builder: (context) {
          final authState = context.read<AuthBloc>().state;
          final isAdmin =
              authState is AuthAuthenticated && authState.user.role == 'admin';

          if (!isAdmin) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: _goCreate,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          );
        }),
      ),
    );
  }

  KendaraanLoadRequested _buildLoadEvent() => KendaraanLoadRequested(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        merk: _selectedMerk,
        kepemilikan: _selectedKepemilikan,
        status: _selectedStatus,
      );
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final bool isReset;
  final Color? activeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    this.isReset = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isReset ? AppTheme.error : activeColor ?? AppTheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected || isReset
              ? color.withOpacity(isDark ? 0.25 : 0.12)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected || isReset
                ? color.withOpacity(0.6)
                : Theme.of(context).dividerColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: selected || isReset ? color : AppTheme.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    selected || isReset ? FontWeight.w600 : FontWeight.w400,
                color: selected || isReset ? color : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Kepemilikan Dropdown Filter ──────────────────────────────────────────────

class _KepemilikanFilter extends StatelessWidget {
  final String? selected;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _KepemilikanFilter({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = selected != null;
    const color = AppTheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSheet(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: hasValue
              ? color.withOpacity(isDark ? 0.25 : 0.12)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasValue
                ? color.withOpacity(0.6)
                : Theme.of(context).dividerColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_rounded,
                size: 13, color: hasValue ? color : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              hasValue ? selected! : 'Kepemilikan PT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                color: hasValue ? color : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down_rounded,
                size: 16, color: hasValue ? color : AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Filter Kepemilikan PT',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
              // Opsi "Semua"
              ListTile(
                leading: Icon(
                  selected == null
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppTheme.primary,
                ),
                title: const Text('Semua Kepemilikan',
                    style: TextStyle(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  onChanged(null);
                },
              ),
              ...options.map((opt) => ListTile(
                    leading: Icon(
                      selected == opt
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: AppTheme.primary,
                    ),
                    title: Text(opt, style: const TextStyle(fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      onChanged(selected == opt ? null : opt);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isTerjual = status == 'Terjual';
    final color = isTerjual ? const Color(0xFFE53935) : AppTheme.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
