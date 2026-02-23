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
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<AsuransiBloc>().add(AsuransiLoadMoreRequested());
      }
    });
  }

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asuransi Kendaraan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/asuransi/create${widget.kendaraanId != null ? '?kendaraan_id=${widget.kendaraanId}' : ''}'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: BlocListener<AsuransiBloc, AsuransiState>(
        listener: (ctx, state) {
          if (state is AsuransiActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.success));
            ctx.read<AsuransiBloc>().add(AsuransiLoadRequested(kendaraanId: widget.kendaraanId));
          } else if (state is AsuransiActionError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.failure.message), backgroundColor: AppTheme.error));
          }
        },
        child: BlocBuilder<AsuransiBloc, AsuransiState>(
          builder: (ctx, state) {
            if (state is AsuransiLoading) return const AppLoading();
            if (state is AsuransiError) return EmptyState(message: state.failure.message, icon: Icons.error_outline, onRetry: () => ctx.read<AsuransiBloc>().add(AsuransiLoadRequested(kendaraanId: widget.kendaraanId)));
            if (state is AsuransiLoaded) {
              if (state.items.isEmpty) return const EmptyState(message: 'Belum ada data asuransi', icon: Icons.health_and_safety_outlined);
              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  final now = DateTime.now();
                  final akhir = DateTime.tryParse(item.tanggalAkhir);
                  final isActive = akhir != null && akhir.isAfter(now);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: (isActive ? AppTheme.success : AppTheme.textSecondary).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.health_and_safety_outlined, color: isActive ? AppTheme.success : AppTheme.textSecondary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.perusahaanAsuransi, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(item.noPolis, style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${item.jenisAsuransi} | ${FormatHelper.date(item.tanggalMulai)} - ${FormatHelper.date(item.tanggalAkhir)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('Premi: ${FormatHelper.currency(item.nilaiPremi)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        )),
                        Column(
                          children: [
                            IconButton(icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20), onPressed: () => ctx.push('/asuransi/${item.id}/edit')),
                            IconButton(icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20), onPressed: () async {
                              final ok = await showConfirmDialog(ctx, title: 'Hapus Asuransi', message: 'Hapus asuransi ${item.noPolis}?');
                              if (ok && ctx.mounted) ctx.read<AsuransiBloc>().add(AsuransiDeleteRequested(item.id));
                            }),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
