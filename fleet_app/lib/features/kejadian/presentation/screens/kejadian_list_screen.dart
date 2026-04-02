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
      body: BlocListener<KejadianBloc, KejadianState>(
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
              if (state.items.isEmpty) {
                return const EmptyState(
                    message: 'Belum ada data kejadian',
                    icon: Icons.report_problem_outlined);
              }
              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 80),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  return InkWell(
                    onTap: () => context.push('/kejadian/${item.id}', extra: item),
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
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        size: 13,
                                        color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(FormatHelper.date(item.tanggal),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                  ],
                                ),
                                if (item.deskripsi != null &&
                                    item.deskripsi!.isNotEmpty) ...[
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
