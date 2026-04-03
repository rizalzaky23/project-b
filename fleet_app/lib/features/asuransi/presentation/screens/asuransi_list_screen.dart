import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/asuransi_bloc.dart';

class AsuransiListScreen extends StatefulWidget {
  final int? kendaraanId;
  const AsuransiListScreen({super.key, this.kendaraanId});

  @override
  State<AsuransiListScreen> createState() => _AsuransiListScreenState();
}

class _AsuransiListScreenState extends State<AsuransiListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  /// 'semua' | 'aktif' | 'tidak_aktif'
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    context.read<AsuransiBloc>().add(AsuransiLoadRequested(kendaraanId: widget.kendaraanId));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<AsuransiBloc>().add(AsuransiLoadMoreRequested());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final hPad = isDesktop ? 48.0 : isTablet ? 24.0 : 16.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/dashboard');
      },
      child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.success, Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.health_and_safety_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Asuransi'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            color: Theme.of(context).colorScheme.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari no polis / asuransi...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
          _buildFilterBar(),
          Expanded(
            child: BlocListener<AsuransiBloc, AsuransiState>(
              listener: (ctx, state) {
                if (state is AsuransiActionSuccess) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.success));
                  ctx.read<AsuransiBloc>().add(
                      AsuransiLoadRequested(kendaraanId: widget.kendaraanId));
                } else if (state is AsuransiActionError) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(state.failure.message),
                      backgroundColor: AppTheme.error));
                }
              },
              child: BlocBuilder<AsuransiBloc, AsuransiState>(
          builder: (ctx, state) {
            if (state is AsuransiLoading) return const AppLoading();
            if (state is AsuransiError) {
              return EmptyState(
                  message: state.failure.message,
                  icon: Icons.error_outline,
                  onRetry: () => ctx.read<AsuransiBloc>().add(
                      AsuransiLoadRequested(kendaraanId: widget.kendaraanId)));
            }
            if (state is AsuransiLoaded) {
              // ── client-side filter by status & search ─────────────────
              final now = DateTime.now();
              final filtered = state.items.where((item) {
                // Filter status
                final akhir = DateTime.tryParse(item.tanggalAkhir);
                final isActive = akhir != null && akhir.isAfter(now);
                bool passStatus = true;
                if (_filterStatus == 'aktif') passStatus = isActive;
                if (_filterStatus == 'tidak_aktif') passStatus = !isActive;

                // Filter search
                bool passSearch = true;
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  final plat = (item.kendaraan?['kode_kendaraan'] as String?)?.toLowerCase() ?? '';
                  passSearch = item.noPolis.toLowerCase().contains(q) ||
                      item.perusahaanAsuransi.toLowerCase().contains(q) ||
                      plat.contains(q);
                }

                return passStatus && passSearch;
              }).toList();
              // ─────────────────────────────────────────────────────────

              if (filtered.isEmpty) {
                return EmptyState(
                    message: _filterStatus == 'semua'
                        ? 'Belum ada data asuransi'
                        : _filterStatus == 'aktif'
                            ? 'Tidak ada asuransi yang aktif'
                            : 'Tidak ada asuransi yang tidak aktif',
                    icon: Icons.health_and_safety_outlined);
              }
              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 80),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  final akhir = DateTime.tryParse(item.tanggalAkhir);
                  final isActive = akhir != null && akhir.isAfter(now);
                  final statusColor = isActive ? AppTheme.success : AppTheme.textSecondary;
                  final gradColors = isActive
                      ? [AppTheme.success, const Color(0xFF66BB6A)]
                      : [AppTheme.textSecondary, AppTheme.textSecondary];

                  return InkWell(
                    onTap: () => context.push('/asuransi/${item.id}', extra: item),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: statusColor.withOpacity(0.25), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradColors),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.health_and_safety_outlined,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(item.perusahaanAsuransi,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isActive ? 'Aktif' : 'Kadaluarsa',
                                        style: TextStyle(
                                            color: statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(item.noPolis,
                                    style: const TextStyle(
                                        color: AppTheme.primary, fontSize: 12,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.category_outlined,
                                        size: 12, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(item.jenisAsuransi,
                                        style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 12, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                          '${FormatHelper.date(item.tanggalMulai)} – ${FormatHelper.date(item.tanggalAkhir)}',
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 11),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                    'Premi: ${FormatHelper.currency(item.nilaiPremi)}',
                                    style: TextStyle(
                                        color: isActive
                                            ? AppTheme.success
                                            : AppTheme.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final authState = context.read<AuthBloc>().state;
                              final isAdmin = authState is AuthAuthenticated && authState.user.role == 'admin';
                              if (!isAdmin) return const SizedBox.shrink();
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: AppTheme.primary, size: 20),
                                      onPressed: () async {
                                        await ctx.push('/asuransi/${item.id}/edit', extra: item);
                                        if (ctx.mounted) ctx.read<AsuransiBloc>().add(AsuransiLoadRequested(kendaraanId: widget.kendaraanId));
                                      },
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints()),
                                  const SizedBox(height: 4),
                                  IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: AppTheme.error, size: 20),
                                      onPressed: () async {
                                        final ok = await showConfirmDialog(ctx,
                                            title: 'Hapus Asuransi',
                                            message:
                                                'Hapus asuransi ${item.noPolis}?');
                                        if (ok && ctx.mounted) {
                                          ctx.read<AsuransiBloc>().add(
                                              AsuransiDeleteRequested(item.id));
                                        }
                                      },
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints()),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final authState = context.read<AuthBloc>().state;
          final isAdmin = authState is AuthAuthenticated && authState.user.role == 'admin';
          if (!isAdmin) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () async {
              await context.push('/asuransi/create', extra: {'kendaraanId': widget.kendaraanId});
              if (mounted) context.read<AsuransiBloc>().add(AsuransiLoadRequested(kendaraanId: widget.kendaraanId));
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
            backgroundColor: AppTheme.success,
            foregroundColor: Colors.white,
          );
        },
      ),
    ),
    );
  }

  // ── Filter chip bar ───────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    const filters = [
      ('semua', 'Semua', Icons.list_alt_rounded),
      ('aktif', 'Aktif', Icons.check_circle_outline_rounded),
      ('tidak_aktif', 'Tidak Aktif', Icons.cancel_outlined),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textSecondary.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: filters.map((f) {
          final (value, label, icon) = f;
          final isSelected = _filterStatus == value;

          Color chipColor;
          if (value == 'aktif') {
            chipColor = AppTheme.success;
          } else if (value == 'tidak_aktif') {
            chipColor = AppTheme.error;
          } else {
            chipColor = AppTheme.primary;
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: GestureDetector(
                  onTap: () => setState(() => _filterStatus = value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? chipColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? chipColor.withOpacity(0.6)
                            : AppTheme.textSecondary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 14,
                          color: isSelected ? chipColor : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? chipColor : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
