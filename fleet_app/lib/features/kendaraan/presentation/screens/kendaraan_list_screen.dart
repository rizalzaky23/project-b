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
    setState(() {});
    context.read<KendaraanBloc>().add(KendaraanLoadRequested(search: value));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final hPad = isDesktop ? 48.0 : isTablet ? 24.0 : 16.0;

    // Responsive grid columns
    final int crossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF8B84FF)]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.directions_car_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Kendaraan'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/dashboard'),
        ),
      ),
      body: BlocListener<KendaraanBloc, KendaraanState>(
        listener: (context, state) {
          if (state is KendaraanActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success));
            context.read<KendaraanBloc>().add(KendaraanLoadRequested());
          } else if (state is KendaraanActionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppTheme.error));
          }
        },
        child: Column(
          children: [
            // Search bar
            Container(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                    bottom:
                        BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Cari kendaraan...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppTheme.primary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            // Content
            Expanded(
              child: BlocBuilder<KendaraanBloc, KendaraanState>(
                builder: (context, state) {
                  if (state is KendaraanLoading) return const AppLoading();
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
                          padding:
                              EdgeInsets.fromLTRB(hPad, 12, hPad, 4),
                          child: Row(
                            children: [
                              Container(
                                width: 4, height: 16,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.primary,
                                      AppTheme.secondary
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${state.meta.total} kendaraan',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            padding:
                                EdgeInsets.fromLTRB(hPad, 8, hPad, 100),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              // Let height be determined by content
                              childAspectRatio: isDesktop
                                  ? 0.78
                                  : isTablet
                                      ? 0.76
                                      : 0.74,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return KendaraanCard(
                                kendaraan: item,
                                onTap: () =>
                                    context.push('/kendaraan/${item.id}'),
                                onEdit: () => context
                                    .push('/kendaraan/${item.id}/edit'),
                                onDelete: () async {
                                  final confirm = await showConfirmDialog(
                                    context,
                                    title: 'Hapus Kendaraan',
                                    message:
                                        'Yakin ingin menghapus ${item.merk} ${item.tipe}?',
                                  );
                                  if (confirm && context.mounted) {
                                    context.read<KendaraanBloc>().add(
                                        KendaraanDeleteRequested(item.id));
                                  }
                                },
                              );
                            },
                          ),
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
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
