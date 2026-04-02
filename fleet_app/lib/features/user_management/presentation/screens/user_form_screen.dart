import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../domain/entities/managed_user_entity.dart';
import '../bloc/user_bloc.dart';

class UserFormScreen extends StatefulWidget {
  final ManagedUserEntity? existing;
  const UserFormScreen({super.key, this.existing});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _passwordCtrl = TextEditingController();
  String _role = 'staff';
  bool _obscure = true;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.existing?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.existing?.email ?? '');
    _role      = widget.existing?.role ?? 'staff';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    if (_isEdit) {
      context.read<UserBloc>().add(UserUpdateRequested(
            id:       widget.existing!.id,
            name:     _nameCtrl.text.trim(),
            email:    _emailCtrl.text.trim(),
            password: _passwordCtrl.text.isNotEmpty
                ? _passwordCtrl.text
                : null,
            role: _role,
          ));
    } else {
      context.read<UserBloc>().add(UserCreateRequested(
            name:     _nameCtrl.text.trim(),
            email:    _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            role:     _role,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserActionSuccess) {
          context.pop();
        }
        if (state is UserError) {
          setState(() => _saving = false);
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit User' : 'Tambah User'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.manage_accounts_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit ? 'Edit Akun User' : 'Buat Akun Baru',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _isEdit
                                ? 'Kosongkan password jika tidak ingin diubah'
                                : 'Isi semua field dengan benar',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _label('Nama Lengkap'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDeco('Masukkan nama lengkap',
                      icon: Icons.person_outline_rounded),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                _label('Email'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDeco('Masukkan email',
                      icon: Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _label(_isEdit ? 'Password Baru (opsional)' : 'Password'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  decoration: _inputDeco(
                    _isEdit
                        ? 'Kosongkan jika tidak ingin diubah'
                        : 'Masukkan password (min. 6 karakter)',
                    icon: Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppTheme.textSecondary),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (!_isEdit &&
                        (v == null || v.isEmpty)) {
                      return 'Password wajib diisi untuk user baru';
                    }
                    if (v != null &&
                        v.isNotEmpty &&
                        v.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _label('Role'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: _inputDeco('Pilih role',
                      icon: Icons.admin_panel_settings_outlined),
                  items: const [
                    DropdownMenuItem(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings_rounded,
                              color: Color(0xFF6C63FF), size: 18),
                          SizedBox(width: 8),
                          Text('Admin (CRUD data fleet)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'manager',
                      child: Row(
                        children: [
                          Icon(Icons.manage_accounts_rounded,
                              color: AppTheme.secondary, size: 18),
                          SizedBox(width: 8),
                          Text('Manager (hanya lihat)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'staff',
                      child: Row(
                        children: [
                          Icon(Icons.person_rounded,
                              color: AppTheme.success, size: 18),
                          SizedBox(width: 8),
                          Text('Staff (hanya lihat)'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? 'staff'),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save_rounded),
                    label: Text(
                      _saving
                          ? 'Menyimpan...'
                          : (_isEdit ? 'Simpan Perubahan' : 'Buat User'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13),
      );

  InputDecoration _inputDeco(String hint, {required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppTheme.textSecondary),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      );
}
