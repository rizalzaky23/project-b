import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../bloc/asuransi_bloc.dart';

class AsuransiListScreen extends StatefulWidget {
  final int? kendaraanId;
  const AsuransiListScreen({super.key, this.kendaraanId});

  @override
  State<AsuransiListScreen> createState() => _AsuransiListScreenState();
}

class _AsuransiListScreenState extends State<AsuransiListScreen> {
  final _scrollController = ScrollController();

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
    super.dispose();
  }

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
      body: BlocListener<AsuransiBloc, AsuransiState>(
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
              if (state.items.isEmpty) {
                return const EmptyState(
                    message: 'Belum ada data asuransi',
                    icon: Icons.health_and_safety_outlined);
              }
              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 80),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  final now = DateTime.now();
                  final akhir = DateTime.tryParse(item.tanggalAkhir);
                  final isActive = akhir != null && akhir.isAfter(now);
                  final statusColor = isActive ? AppTheme.success : AppTheme.textSecondary;
                  final gradColors = isActive
                      ? [AppTheme.success, const Color(0xFF66BB6A)]
                      : [AppTheme.textSecondary, AppTheme.textSecondary];

                  return InkWell(
                    onTap: () => context.push('/asuransi/${item.id}'),
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: AppTheme.primary, size: 20),
                                  onPressed: () =>
                                      ctx.push('/asuransi/${item.id}/edit'),
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
        onPressed: () => context.push('/asuransi/create',
            extra: {'kendaraanId': widget.kendaraanId}),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: AppTheme.success,
        foregroundColor: Colors.white,
      ),
    );
  }
}
