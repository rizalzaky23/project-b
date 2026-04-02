import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/servis_bloc.dart';

class ServisListScreen extends StatefulWidget {
  final int? kendaraanId;
  const ServisListScreen({super.key, this.kendaraanId});

  @override
  State<ServisListScreen> createState() => _ServisListScreenState();
}

class _ServisListScreenState extends State<ServisListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<ServisBloc>()
        .add(ServisLoadRequested(kendaraanId: widget.kendaraanId));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ServisBloc>().add(ServisLoadMoreRequested());
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
    final hPad = isDesktop
        ? 48.0
        : isTablet
            ? 24.0
            : 16.0;

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
                    colors: [Color(0xFF7B61FF), Color(0xFF9C85FF)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.build_circle_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Servis Record'),
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
        body: BlocListener<ServisBloc, ServisState>(
          listener: (ctx, state) {
            if (state is ServisActionSuccess) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.success));
              ctx
                  .read<ServisBloc>()
                  .add(ServisLoadRequested(kendaraanId: widget.kendaraanId));
            } else if (state is ServisActionError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: AppTheme.error));
            }
          },
          child: BlocBuilder<ServisBloc, ServisState>(
            builder: (ctx, state) {
              if (state is ServisLoading) return const AppLoading();
              if (state is ServisError) {
                return EmptyState(
                    message: state.failure.message,
                    icon: Icons.error_outline,
                    onRetry: () => ctx.read<ServisBloc>().add(
                        ServisLoadRequested(kendaraanId: widget.kendaraanId)));
              }
              if (state is ServisLoaded) {
                if (state.items.isEmpty) {
                  return const EmptyState(
                      message: 'Belum ada data servis',
                      icon: Icons.build_circle_outlined);
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 80),
                  itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i == state.items.length) {
                      return const Center(
                          child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator()));
                    }
                    final item = state.items[i];
                    const accentColor = AppTheme.secondary;

                    return InkWell(
                      onTap: () =>
                          context.push('/servis/${item.id}', extra: item),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: accentColor.withOpacity(0.25), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: accentColor.withOpacity(0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  accentColor,
                                  accentColor.withOpacity(0.7)
                                ]),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: accentColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3)),
                                ],
                              ),
                              child: const Icon(Icons.build_circle_outlined,
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
                                        child: Text(
                                            FormatHelper.date(
                                                item.tanggalServis),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Record',
                                          style: TextStyle(
                                              color: accentColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.speed_outlined,
                                          size: 12,
                                          color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                          '${item.kilometer.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} km',
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
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
                                          await ctx.push('/servis/${item.id}/edit',
                                              extra: item);
                                          if (ctx.mounted) {
                                            ctx.read<ServisBloc>().add(
                                                ServisLoadRequested(
                                                    kendaraanId:
                                                        widget.kendaraanId));
                                          }
                                        },
                                        padding: const EdgeInsets.all(6),
                                        constraints: const BoxConstraints()),
                                    const SizedBox(height: 4),
                                    IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: AppTheme.error, size: 20),
                                        onPressed: () async {
                                          final ok = await showConfirmDialog(ctx,
                                              title: 'Hapus Servis',
                                              message:
                                                  'Hapus servis tanggal ${FormatHelper.date(item.tanggalServis)}?');
                                          if (ok && ctx.mounted) {
                                            ctx.read<ServisBloc>().add(
                                                ServisDeleteRequested(item.id));
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
                await context.push('/servis/create',
                    extra: {'kendaraanId': widget.kendaraanId});
                if (mounted) {
                  context
                      .read<ServisBloc>()
                      .add(ServisLoadRequested(kendaraanId: widget.kendaraanId));
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              backgroundColor: const Color(0xFF7B61FF),
              foregroundColor: Colors.white,
            );
          },
        ),
      ),
    );
  }
}
