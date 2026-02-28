import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../bloc/penyewaan_bloc.dart';

class PenyewaanListScreen extends StatefulWidget {
  final int? kendaraanId;
  const PenyewaanListScreen({super.key, this.kendaraanId});

  @override
  State<PenyewaanListScreen> createState() => _PenyewaanListScreenState();
}

class _PenyewaanListScreenState extends State<PenyewaanListScreen> {
  final _scrollController = ScrollController();
  bool? _filterAktif;

  @override
  void initState() {
    super.initState();
    context.read<PenyewaanBloc>().add(
        PenyewaanLoadRequested(kendaraanId: widget.kendaraanId));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<PenyewaanBloc>().add(PenyewaanLoadMoreRequested());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _reload() => context.read<PenyewaanBloc>().add(PenyewaanLoadRequested(
      kendaraanId: widget.kendaraanId, aktif: _filterAktif));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final hPad = isDesktop ? 48.0 : isTablet ? 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.secondary, Color(0xFF00BFA5)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.assignment_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Penyewaan'),
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
        actions: [
          // Filter toggle
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<bool?>(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_list_rounded,
                        color: AppTheme.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _filterAktif == null
                          ? 'Semua'
                          : _filterAktif!
                              ? 'Aktif'
                              : 'Selesai',
                      style: const TextStyle(
                          color: AppTheme.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(value: null, child: Text('Semua')),
                const PopupMenuItem(value: true, child: Text('Aktif')),
                const PopupMenuItem(value: false, child: Text('Selesai')),
              ],
              onSelected: (v) {
                setState(() => _filterAktif = v);
                _reload();
              },
            ),
          ),
        ],
      ),
      body: BlocListener<PenyewaanBloc, PenyewaanState>(
        listener: (ctx, state) {
          if (state is PenyewaanActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success));
            _reload();
          } else if (state is PenyewaanActionError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppTheme.error));
          }
        },
        child: BlocBuilder<PenyewaanBloc, PenyewaanState>(
          builder: (ctx, state) {
            if (state is PenyewaanLoading) return const AppLoading();
            if (state is PenyewaanError) {
              return EmptyState(
                  message: state.failure.message,
                  icon: Icons.error_outline,
                  onRetry: _reload);
            }
            if (state is PenyewaanLoaded) {
              if (state.items.isEmpty) {
                return const EmptyState(
                    message: 'Belum ada data penyewaan',
                    icon: Icons.assignment_outlined);
              }
              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 80),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  final now = DateTime.now();
                  final selesai = DateTime.tryParse(item.tanggalSelesai);
                  final mulai = DateTime.tryParse(item.tanggalMulai);
                  final isActive = mulai != null &&
                      selesai != null &&
                      now.isAfter(mulai) &&
                      now.isBefore(selesai);
                  final statusColor =
                      isActive ? AppTheme.secondary : AppTheme.textSecondary;
                  final gradColors = isActive
                      ? [AppTheme.secondary, const Color(0xFF00BFA5)]
                      : [AppTheme.textSecondary, AppTheme.textSecondary];

                  return InkWell(
                    onTap: () => context.push('/penyewaan/${item.id}'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: statusColor.withOpacity(0.25),
                            width: 1.5),
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
                            child: const Icon(Icons.assignment_outlined,
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
                                      child: Text(item.kodePenyewa,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ),
                                    if (item.group)
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: AppTheme.primary
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: const Text('Group',
                                              style: TextStyle(
                                                  color: AppTheme.primary,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color:
                                            statusColor.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                          isActive ? 'Aktif' : 'Selesai',
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(item.penanggungJawab,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule_outlined,
                                        size: 12,
                                        color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${FormatHelper.date(item.tanggalMulai)} → ${FormatHelper.date(item.tanggalSelesai)} (${item.masaSewa} hari)',
                                        style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                    FormatHelper.currency(item.nilaiSewa),
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                if (item.lokasiSewa != null) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 12,
                                          color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(item.lokasiSewa!,
                                            style: const TextStyle(
                                                color:
                                                    AppTheme.textSecondary,
                                                fontSize: 11),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: AppTheme.primary, size: 20),
                                  onPressed: () =>
                                      ctx.push('/penyewaan/${item.id}/edit'),
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints()),
                              const SizedBox(height: 4),
                              IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppTheme.error, size: 20),
                                  onPressed: () async {
                                    final ok = await showConfirmDialog(ctx,
                                        title: 'Hapus Penyewaan',
                                        message:
                                            'Hapus penyewaan ${item.kodePenyewa}?');
                                    if (ok && ctx.mounted) {
                                      ctx.read<PenyewaanBloc>().add(
                                          PenyewaanDeleteRequested(
                                              item.id));
                                    }
                                  },
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints()),
                            ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/penyewaan/create'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
