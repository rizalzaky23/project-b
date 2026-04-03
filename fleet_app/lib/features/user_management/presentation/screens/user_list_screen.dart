import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../domain/entities/managed_user_entity.dart';
import '../bloc/user_bloc.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(UserLoadRequested());
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':   return AppTheme.primary;
      case 'manager': return AppTheme.secondary;
      case 'staff':   return AppTheme.success;
      default:        return AppTheme.textSecondary;
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'admin':   return Icons.admin_panel_settings_rounded;
      case 'manager': return Icons.manage_accounts_rounded;
      case 'staff':   return Icons.person_rounded;
      default:        return Icons.person_outline_rounded;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':   return 'Admin';
      case 'manager': return 'Manager';
      case 'staff':   return 'Staff';
      default:        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.manage_accounts_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            const Text('Kelola User'),
          ],
        ),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Text(state.message),
                  ],
                ),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(12),
              ),
            );
          }
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(12),
              ),
            );
          }
        },
        builder: (context, state) {
          List<ManagedUserEntity> users = [];
          if (state is UserLoaded) users = state.users;
          if (state is UserActionSuccess) users = state.users;
          final isLoading = state is UserLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (users.isEmpty && state is! UserLoading) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.group_off_rounded,
                        size: 56, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada user',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Tambah user baru dengan tombol di bawah.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<UserBloc>().add(UserLoadRequested()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final user = users[i];
                final color = _roleColor(user.role);
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: color.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_roleIcon(user.role),
                          color: Colors.white, size: 22),
                    ),
                    title: Text(user.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(user.email,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            _roleLabel(user.role),
                            style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppTheme.primary, size: 20),
                          onPressed: () async {
                            await context.push('/users/${user.id}/edit',
                                extra: user);
                            if (ctx.mounted) {
                              ctx
                                  .read<UserBloc>()
                                  .add(UserLoadRequested());
                            }
                          },
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppTheme.error, size: 20),
                          onPressed: () async {
                            final ok = await showConfirmDialog(ctx,
                                title: 'Hapus User',
                                message:
                                    'Hapus user ${user.name}? Tindakan ini tidak dapat dibatalkan.');
                            if (ok && ctx.mounted) {
                              ctx
                                  .read<UserBloc>()
                                  .add(UserDeleteRequested(user.id));
                            }
                          },
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/users/create');
          if (mounted) context.read<UserBloc>().add(UserLoadRequested());
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah User'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
    );
  }
}
