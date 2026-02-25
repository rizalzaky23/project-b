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
    context
        .read<PenyewaanBloc>()
        .add(PenyewaanLoadRequested(kendaraanId: widget.kendaraanId));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sewa'),

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

        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primary),
            onPressed: () => context.push('/kendaraan/create'),
          ),
          const SizedBox(width: 8),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  final now = DateTime.now();
                  final selesai = DateTime.tryParse(item.tanggalSelesai);
                  final mulai = DateTime.tryParse(item.tanggalMulai);
                  final isActive = mulai != null &&
                      selesai != null &&
                      now.isAfter(mulai) &&
                      now.isBefore(selesai);
                  return Container(
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
                                  color: (isActive
                                          ? AppTheme.secondary
                                          : AppTheme.textSecondary)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.assignment_outlined,
                                  color: isActive
                                      ? AppTheme.secondary
                                      : AppTheme.textSecondary,
                                  size: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(children: [
                                  Text(item.kodePenyewa,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  if (item.group)
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: AppTheme.primary
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: const Text('Group',
                                            style: TextStyle(
                                                color: AppTheme.primary,
                                                fontSize: 11))),
                                ]),
                                const SizedBox(height: 3),
                                Text(item.penanggungJawab,
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13)),
                                const SizedBox(height: 3),
                                Text(
                                    '${FormatHelper.date(item.tanggalMulai)} → ${FormatHelper.date(item.tanggalSelesai)} (${item.masaSewa} hari)',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 3),
                                Text(FormatHelper.currency(item.nilaiSewa),
                                    style: const TextStyle(
                                        color: AppTheme.secondary,
                                        fontWeight: FontWeight.w600)),
                                if (item.lokasiSewa != null) ...[
                                  const SizedBox(height: 2),
                                  Text(item.lokasiSewa!,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                ],
                              ])),
                          Column(children: [
                            IconButton(
                                icon: const Icon(Icons.edit_outlined,
                                    color: AppTheme.primary, size: 20),
                                onPressed: () =>
                                    ctx.push('/penyewaan/${item.id}/edit')),
                            IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppTheme.error, size: 20),
                                onPressed: () async {
                                  final ok = await showConfirmDialog(ctx,
                                      title: 'Hapus Penyewaan',
                                      message:
                                          'Hapus penyewaan ${item.kodePenyewa}?');
                                  if (ok && ctx.mounted) {
                                    ctx
                                        .read<PenyewaanBloc>()
                                        .add(PenyewaanDeleteRequested(item.id));
                                  }
                                }),
                          ]),
                        ]),
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
