import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../bloc/merek_bloc.dart';
import '../../domain/entities/merek_entity.dart';

class MerekListScreen extends StatefulWidget {
  const MerekListScreen({super.key});

  @override
  State<MerekListScreen> createState() => _MerekListScreenState();
}

class _MerekListScreenState extends State<MerekListScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<MerekBloc>().add(MerekLoadRequested());
  }

  Future<void> _showFormDialog([MerekEntity? existing]) async {
    final controller = TextEditingController(text: existing?.nama ?? '');
    final bool isEdit = existing != null;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Merek' : 'Tambah Merek Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama Merek (contoh: Toyota)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          AppButton(
            label: 'Simpan',
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      if (isEdit) {
        context.read<MerekBloc>().add(MerekUpdateRequested(existing.id, result));
      } else {
        context.read<MerekBloc>().add(MerekCreateRequested(result));
      }
    }
  }

  Future<void> _deleteMerek(MerekEntity item) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Hapus Merek',
      message: 'Apakah Anda yakin ingin menghapus merek "${item.nama}"?',
    );

    if (confirm && mounted) {
      context.read<MerekBloc>().add(MerekDeleteRequested(item.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Merek Kendaraan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<MerekBloc, MerekState>(
        listener: (context, state) {
          if (state is MerekActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.success),
            );
            _loadData();
          } else if (state is MerekActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.error),
            );
          }
        },
        builder: (context, state) {
          if (state is MerekLoading) {
            return const AppLoading();
          }
          if (state is MerekError) {
            return EmptyState(
              icon: Icons.error_outline,
              message: state.message,
              onRetry: _loadData,
            );
          }
          if (state is MerekLoaded) {
            if (state.items.isEmpty) {
              return EmptyState(
                icon: Icons.branding_watermark_rounded,
                message: 'Belum ada merek terdaftar.',
                onRetry: _loadData,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.primary,
                        child: Icon(Icons.branding_watermark, color: Colors.white, size: 20),
                      ),
                      title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppTheme.primary, size: 20),
                            onPressed: () => _showFormDialog(item),
                            tooltip: 'Edit Merek',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                            onPressed: () => _deleteMerek(item),
                            tooltip: 'Hapus Merek',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Merek'),
      ),
    );
  }
}
