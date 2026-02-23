import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../bloc/detail_kendaraan_bloc.dart';

class DetailKendaraanListScreen extends StatefulWidget {
  final int? kendaraanId;
  const DetailKendaraanListScreen({super.key, this.kendaraanId});

  @override
  State<DetailKendaraanListScreen> createState() => _DetailKendaraanListScreenState();
}

class _DetailKendaraanListScreenState extends State<DetailKendaraanListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<DetailKendaraanBloc>().add(DetailKendaraanLoadRequested(kendaraanId: widget.kendaraanId));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<DetailKendaraanBloc>().add(DetailKendaraanLoadMoreRequested());
      }
    });
  }

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kendaraan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/detail-kendaraan/create${widget.kendaraanId != null ? '?kendaraan_id=${widget.kendaraanId}' : ''}'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: BlocListener<DetailKendaraanBloc, DetailKendaraanState>(
        listener: (ctx, state) {
          if (state is DetailKendaraanActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.success));
            ctx.read<DetailKendaraanBloc>().add(DetailKendaraanLoadRequested(kendaraanId: widget.kendaraanId));
          } else if (state is DetailKendaraanActionError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.failure.message), backgroundColor: AppTheme.error));
          }
        },
        child: BlocBuilder<DetailKendaraanBloc, DetailKendaraanState>(
          builder: (ctx, state) {
            if (state is DetailKendaraanLoading) return const AppLoading();
            if (state is DetailKendaraanError) return EmptyState(message: state.failure.message, icon: Icons.error_outline, onRetry: () => ctx.read<DetailKendaraanBloc>().add(DetailKendaraanLoadRequested(kendaraanId: widget.kendaraanId)));
            if (state is DetailKendaraanLoaded) {
              if (state.items.isEmpty) return const EmptyState(message: 'Belum ada data detail kendaraan', icon: Icons.description_outlined);
              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
                    child: Row(
                      children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.noPolisi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(item.namaPemilik, style: const TextStyle(color: AppTheme.textSecondary)),
                            if (item.berlakuMulai != null) ...[
                              const SizedBox(height: 4),
                              Text('Berlaku: ${FormatHelper.date(item.berlakuMulai)}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ],
                        )),
                        IconButton(icon: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 20), onPressed: () => context.push('/detail-kendaraan/${item.id}/edit')),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                          onPressed: () async {
                            final ok = await showConfirmDialog(ctx, title: 'Hapus', message: 'Hapus detail ${item.noPolisi}?');
                            if (ok && ctx.mounted) ctx.read<DetailKendaraanBloc>().add(DetailKendaraanDeleteRequested(item.id));
                          },
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
