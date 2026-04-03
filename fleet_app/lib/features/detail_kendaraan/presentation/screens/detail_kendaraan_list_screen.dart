import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';

import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/detail_kendaraan_bloc.dart';

class DetailKendaraanListScreen extends StatefulWidget {
  final int? kendaraanId;
  const DetailKendaraanListScreen({super.key, this.kendaraanId});

  @override
  State<DetailKendaraanListScreen> createState() =>
      _DetailKendaraanListScreenState();
}

class _DetailKendaraanListScreenState extends State<DetailKendaraanListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<DetailKendaraanBloc>()
        .add(DetailKendaraanLoadRequested(kendaraanId: widget.kendaraanId));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context
            .read<DetailKendaraanBloc>()
            .add(DetailKendaraanLoadMoreRequested());
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
                    colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Detail Kendaraan'),
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
        body: BlocListener<DetailKendaraanBloc, DetailKendaraanState>(
          listener: (ctx, state) {
            if (state is DetailKendaraanActionSuccess) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.success));
              ctx.read<DetailKendaraanBloc>().add(DetailKendaraanLoadRequested(
                  kendaraanId: widget.kendaraanId));
            } else if (state is DetailKendaraanActionError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: AppTheme.error));
            }
          },
          child: BlocBuilder<DetailKendaraanBloc, DetailKendaraanState>(
            builder: (ctx, state) {
              if (state is DetailKendaraanLoading) return const AppLoading();
              if (state is DetailKendaraanError) {
                return EmptyState(
                    message: state.failure.message,
                    icon: Icons.error_outline,
                    onRetry: () => ctx.read<DetailKendaraanBloc>().add(
                        DetailKendaraanLoadRequested(
                            kendaraanId: widget.kendaraanId)));
              }
              if (state is DetailKendaraanLoaded) {
                if (state.items.isEmpty) {
                  return const EmptyState(
                      message: 'Belum ada data detail kendaraan',
                      icon: Icons.description_outlined);
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 80),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final item = state.items[i];
                    return InkWell(
                      onTap: () => context.push('/detail-kendaraan/${item.id}',
                          extra: item),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF4DB6AC).withOpacity(0.25),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4DB6AC).withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF4DB6AC),
                                  Color(0xFF26A69A),
                                ]),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4DB6AC)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.credit_card_outlined,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.noPolisi,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline,
                                          size: 13,
                                          color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(item.namaPemilik,
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 13)),
                                    ],
                                  ),
                                  if ((item.kirBerlakuMulai != null && item.kirBerlakuMulai!.isNotEmpty) || (item.kirBerlakuAkhir != null && item.kirBerlakuAkhir!.isNotEmpty)) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7B61FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF7B61FF).withOpacity(0.2)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.assignment_outlined, size: 12, color: Color(0xFF7B61FF)),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'KIR: ${FormatHelper.date(item.kirBerlakuMulai)} - ${FormatHelper.date(item.kirBerlakuAkhir)}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7B61FF)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                          await context.push(
                                              '/detail-kendaraan/${item.id}/edit',
                                              extra: item);
                                          if (context.mounted) {
                                            context.read<DetailKendaraanBloc>().add(
                                                DetailKendaraanLoadRequested(
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
                                            title: 'Hapus',
                                            message:
                                                'Hapus detail ${item.noPolisi}?');
                                        if (ok && ctx.mounted) {
                                          ctx.read<DetailKendaraanBloc>().add(
                                              DetailKendaraanDeleteRequested(
                                                  item.id));
                                        }
                                      },
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                    ),
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
                await context.push(
                  '/detail-kendaraan/create',
                  extra: {'kendaraanId': widget.kendaraanId},
                );
                if (context.mounted) {
                  context.read<DetailKendaraanBloc>().add(
                        DetailKendaraanLoadRequested(
                            kendaraanId: widget.kendaraanId),
                      );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
              backgroundColor: const Color(0xFF4DB6AC),
              foregroundColor: Colors.white,
            );
          },
        ),
      ),
    );
  }
}
