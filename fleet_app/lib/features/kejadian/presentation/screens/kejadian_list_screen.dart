import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../bloc/kejadian_bloc.dart';

class KejadianListScreen extends StatefulWidget {
  final int? kendaraanId;
  const KejadianListScreen({super.key, this.kendaraanId});

  @override
  State<KejadianListScreen> createState() => _KejadianListScreenState();
}

class _KejadianListScreenState extends State<KejadianListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<KejadianBloc>()
        .add(KejadianLoadRequested(kendaraanId: widget.kendaraanId));
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kejadian'),

        // --- TAMBAHKAN BAGIAN LEADING INI ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop(); // Kembali ke tumpukan halaman sebelumnya
            } else {
              // Jika halaman ini dibuka dari menu utama tanpa riwayat tumpukan,
              // arahkan paksa ke halaman Dashboard/Home.
              // Ganti '/home' dengan rute menu utama aplikasi Anda.
              context.go('/dashboard');
            }
          },
        ),
        // ------------------------------------
      ),
      body: BlocListener<KejadianBloc, KejadianState>(
        listener: (ctx, state) {
          if (state is KejadianActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success));
            ctx
                .read<KejadianBloc>()
                .add(KejadianLoadRequested(kendaraanId: widget.kendaraanId));
          } else if (state is KejadianActionError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppTheme.error));
          }
        },
        child: BlocBuilder<KejadianBloc, KejadianState>(
          builder: (ctx, state) {
            if (state is KejadianLoading) return const AppLoading();
            if (state is KejadianError)
              return EmptyState(
                  message: state.failure.message,
                  icon: Icons.error_outline,
                  onRetry: () => ctx.read<KejadianBloc>().add(
                      KejadianLoadRequested(kendaraanId: widget.kendaraanId)));
            if (state is KejadianLoaded) {
              if (state.items.isEmpty)
                return const EmptyState(
                    message: 'Belum ada data kejadian',
                    icon: Icons.report_problem_outlined);
              return ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  return InkWell(
                    onTap: () => context.push('/kejadian/${item.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: AppTheme.warning.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.warning_amber_outlined,
                                  color: AppTheme.warning, size: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(FormatHelper.date(item.tanggal),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                if (item.deskripsi != null &&
                                    item.deskripsi!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(item.deskripsi!,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)
                                ],
                              ])),
                          Column(children: [
                            IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppTheme.primary, size: 20),
                                onPressed: () =>
                                    ctx.push('/kejadian/${item.id}/edit')),
                            IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppTheme.error, size: 20),
                                onPressed: () async {
                                  final ok = await showConfirmDialog(ctx,
                                      title: 'Hapus Kejadian',
                                      message:
                                          'Hapus kejadian tanggal ${FormatHelper.date(item.tanggal)}?');
                                  if (ok && ctx.mounted)
                                    ctx
                                        .read<KejadianBloc>()
                                        .add(KejadianDeleteRequested(item.id));
                                }),
                          ]),
                        ]),
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
        onPressed: () => context.push('/kejadian/create',
            extra: {'kendaraanId': widget.kendaraanId}),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
