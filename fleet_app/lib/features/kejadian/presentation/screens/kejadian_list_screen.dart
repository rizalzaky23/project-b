import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/kejadian_bloc.dart';

class KejadianListScreen extends StatefulWidget {
  final int? kendaraanId;
  const KejadianListScreen({super.key, this.kendaraanId});

  @override
  State<KejadianListScreen> createState() => _KejadianListScreenState();
}

class _KejadianListScreenState extends State<KejadianListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<KejadianBloc>().add(
        KejadianLoadRequested(kendaraanId: widget.kendaraanId));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<KejadianBloc>().add(KejadianLoadMoreRequested());
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
                  colors: [AppTheme.warning, Color(0xFFFFB74D)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Kejadian'),
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
                hintText: 'Cari kejadian / lokasi...',
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
                  borderSide: const BorderSide(color: AppTheme.warning, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocListener<KejadianBloc, KejadianState>(
              listener: (ctx, state) {
                if (state is KejadianActionSuccess) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.success));
                  ctx.read<KejadianBloc>().add(
                      KejadianLoadRequested(kendaraanId: widget.kendaraanId));
                } else if (state is KejadianActionError) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(state.failure.message),
                      backgroundColor: AppTheme.error));
                }
              },
        child: BlocBuilder<KejadianBloc, KejadianState>(
          builder: (ctx, state) {
            if (state is KejadianLoading) return const AppLoading();
            if (state is KejadianError) {
              return EmptyState(
                  message: state.failure.message,
                  icon: Icons.error_outline,
                  onRetry: () => ctx.read<KejadianBloc>().add(
                      KejadianLoadRequested(
                          kendaraanId: widget.kendaraanId)));
            }
            if (state is KejadianLoaded) {
              final filteredItems = _searchQuery.isEmpty
                  ? state.items
                  : state.items.where((item) {
                      final q = _searchQuery.toLowerCase();
                      final desc = item.deskripsi?.toLowerCase() ?? '';
                      final jenis = item.jenisKejadian?.toLowerCase() ?? '';
                      final loc = item.lokasi?.toLowerCase() ?? '';
                      final plat = (item.kendaraan?['kode_kendaraan'] as String?)?.toLowerCase() ?? '';
                      return desc.contains(q) ||
                          jenis.contains(q) ||
                          loc.contains(q) ||
                          plat.contains(q);
                    }).toList();

              if (filteredItems.isEmpty) {
                return const EmptyState(
                    message: 'Belum ada data kejadian',
                    icon: Icons.report_problem_outlined);
              }
              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 80),
                itemCount: filteredItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = filteredItems[i];
                  return InkWell(
                    onTap: () async {
                      await context.push('/kejadian/${item.id}', extra: item);
                      if (context.mounted) {
                        context.read<KejadianBloc>().add(KejadianLoadRequested(kendaraanId: widget.kendaraanId));
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.warning.withOpacity(0.25),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.warning.withOpacity(0.06),
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
                              gradient: const LinearGradient(colors: [
                                AppTheme.warning,
                                Color(0xFFFFB74D),
                              ]),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.warning.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.warning_amber_outlined,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(FormatHelper.date(item.tanggal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                    if (item.status != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.status == 'selesai' ? AppTheme.success.withOpacity(0.15) : AppTheme.primary.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: item.status == 'selesai' ? AppTheme.success.withOpacity(0.3) : AppTheme.primary.withOpacity(0.3)),
                                        ),
                                        child: Text(item.status == 'selesai' ? 'SELESAI' : 'PROGRES',
                                          style: TextStyle(color: item.status == 'selesai' ? AppTheme.success : AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 9)),
                                      ),
                                  ],
                                ),
                                if ((item.status != null) || (item.jenisKejadian != null && item.jenisKejadian!.isNotEmpty) || (item.lokasi != null && item.lokasi!.isNotEmpty)) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6, runSpacing: 6,
                                    children: [
                                      if (item.status != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(color: (item.status == 'selesai' ? AppTheme.success : AppTheme.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: (item.status == 'selesai' ? AppTheme.success : AppTheme.primary).withOpacity(0.2))),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            Icon(item.status == 'selesai' ? Icons.check_circle_outline : Icons.pending_actions_outlined, size: 10, color: item.status == 'selesai' ? AppTheme.success : AppTheme.primary),
                                            const SizedBox(width: 4),
                                            Text(item.status == 'selesai' ? 'SELESAI' : 'PROGRES', style: TextStyle(fontSize: 10, color: item.status == 'selesai' ? AppTheme.success : AppTheme.primary, fontWeight: FontWeight.w600)),
                                          ]),
                                        ),
                                      if (item.jenisKejadian != null && item.jenisKejadian!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.warning.withOpacity(0.2))),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            const Icon(Icons.category_outlined, size: 10, color: AppTheme.warning),
                                            const SizedBox(width: 4),
                                            Text(item.jenisKejadian!, style: const TextStyle(fontSize: 10, color: AppTheme.warning, fontWeight: FontWeight.w600)),
                                          ]),
                                        ),
                                      if (item.lokasi != null && item.lokasi!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(color: AppTheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: AppTheme.secondary.withOpacity(0.2))),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            const Icon(Icons.location_on_outlined, size: 10, color: AppTheme.secondary),
                                            const SizedBox(width: 4),
                                            Text(item.lokasi!, style: const TextStyle(fontSize: 10, color: AppTheme.secondary, fontWeight: FontWeight.w600)),
                                          ]),
                                        ),
                                    ],
                                  ),
                                ],
                                if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(item.deskripsi!,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                          height: 1.4),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                ],
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
                                        await ctx.push('/kejadian/${item.id}/edit', extra: item);
                                        if (ctx.mounted) ctx.read<KejadianBloc>().add(KejadianLoadRequested(kendaraanId: widget.kendaraanId));
                                      },
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints()),
                                  const SizedBox(height: 4),
                                  IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: AppTheme.error, size: 20),
                                      onPressed: () async {
                                        final ok = await showConfirmDialog(ctx,
                                            title: 'Hapus Kejadian',
                                            message:
                                                'Hapus kejadian tanggal ${FormatHelper.date(item.tanggal)}?');
                                        if (ok && ctx.mounted) {
                                          ctx.read<KejadianBloc>().add(
                                              KejadianDeleteRequested(item.id));
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
              await context.push('/kejadian/create', extra: {'kendaraanId': widget.kendaraanId});
              if (mounted) context.read<KejadianBloc>().add(KejadianLoadRequested(kendaraanId: widget.kendaraanId));
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
            backgroundColor: AppTheme.warning,
            foregroundColor: Colors.white,
          );
        },
      ),
    ),
    );
  }
}
