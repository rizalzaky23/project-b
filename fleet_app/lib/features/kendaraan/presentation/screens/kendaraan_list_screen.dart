import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../bloc/kendaraan_bloc.dart';
import '../widgets/kendaraan_card.dart';

class KendaraanListScreen extends StatefulWidget {
  const KendaraanListScreen({super.key});

  @override
  State<KendaraanListScreen> createState() => _KendaraanListScreenState();
}

class _KendaraanListScreenState extends State<KendaraanListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<KendaraanBloc>().add(KendaraanLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<KendaraanBloc>().add(KendaraanLoadMoreRequested());
    }
  }

  void _onSearch(String value) {
    context.read<KendaraanBloc>().add(KendaraanLoadRequested(search: value));
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendaraan'),

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
      body: BlocListener<KendaraanBloc, KendaraanState>(
        listener: (context, state) {
          if (state is KendaraanActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.success),
            );
            context.read<KendaraanBloc>().add(KendaraanLoadRequested());
          } else if (state is KendaraanActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.failure.message),
                  backgroundColor: AppTheme.error),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: const InputDecoration(
                  hintText: 'Cari kendaraan...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: null,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<KendaraanBloc, KendaraanState>(
                builder: (context, state) {
                  if (state is KendaraanLoading) {
                    return const AppLoading();
                  }
                  if (state is KendaraanError) {
                    return EmptyState(
                      message: state.failure.message,
                      icon: Icons.error_outline,
                      onRetry: () => context
                          .read<KendaraanBloc>()
                          .add(KendaraanLoadRequested()),
                    );
                  }
                  if (state is KendaraanLoaded) {
                    if (state.items.isEmpty) {
                      return const EmptyState(
                        message: 'Belum ada data kendaraan',
                        icon: Icons.directions_car_outlined,
                      );
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                '${state.meta.total} kendaraan',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: isDesktop
                              ? _buildGrid(state, crossAxisCount: 3)
                              : _buildList(state),
                        ),
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: AppLoading(),
                          ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/kendaraan/create'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildList(KendaraanLoaded state) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return KendaraanCard(
          kendaraan: item,
          onTap: () => context.push('/kendaraan/${item.id}'),
          onEdit: () => context.push('/kendaraan/${item.id}/edit'),
          onDelete: () async {
            final confirm = await showConfirmDialog(
              context,
              title: 'Hapus Kendaraan',
              message: 'Yakin ingin menghapus ${item.merk} ${item.tipe}?',
            );
            if (confirm && context.mounted) {
              context
                  .read<KendaraanBloc>()
                  .add(KendaraanDeleteRequested(item.id));
            }
          },
        );
      },
    );
  }

  Widget _buildGrid(KendaraanLoaded state, {required int crossAxisCount}) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return KendaraanCard(
          kendaraan: item,
          onTap: () => context.push('/kendaraan/${item.id}'),
          onEdit: () => context.push('/kendaraan/${item.id}/edit'),
          onDelete: () async {
            final confirm = await showConfirmDialog(
              context,
              title: 'Hapus Kendaraan',
              message: 'Yakin ingin menghapus ${item.merk} ${item.tipe}?',
            );
            if (confirm && context.mounted) {
              context
                  .read<KendaraanBloc>()
                  .add(KendaraanDeleteRequested(item.id));
            }
          },
        );
      },
    );
  }
}
