import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../domain/entities/kendaraan_entity.dart';
import '../bloc/kendaraan_bloc.dart';

class JualKendaraanDialog extends StatefulWidget {
  final KendaraanEntity kendaraan;

  const JualKendaraanDialog({super.key, required this.kendaraan});

  @override
  State<JualKendaraanDialog> createState() => _JualKendaraanDialogState();
}

class _JualKendaraanDialogState extends State<JualKendaraanDialog> {
  DateTime? _selectedDate;
  final _hargaController = TextEditingController();
  bool _isSubmitting = false;

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _submit() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal jual terlebih dahulu')),
      );
      return;
    }

    final hargaStr = _hargaController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final hargaJual = double.tryParse(hargaStr);

    if (hargaJual == null || hargaJual <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan harga jual yang valid')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<KendaraanBloc>().add(KendaraanUpdateRequested(
      id: widget.kendaraan.id,
      status: 'Terjual',
      tanggalJual: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      hargaJual: hargaJual,
    ));
  }

  @override
  void dispose() {
    _hargaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KendaraanBloc, KendaraanState>(
      listener: (context, state) {
        if (state is KendaraanActionSuccess) {
          // Tutup dialog dan kirim `true` agar caller tahu perlu refresh
          Navigator.of(context).pop(true);
        } else if (state is KendaraanActionError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.failure.message),
            backgroundColor: AppTheme.error,
          ));
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sell_rounded,
                        color: AppTheme.success, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Jual Kendaraan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ubah status ${widget.kendaraan.merk} ${widget.kendaraan.tipe} menjadi Terjual.',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // ── Tanggal Jual ──────────────────────────────────────────────
              const Text('Tanggal Jual',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isSubmitting ? null : _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 20,
                          color: AppTheme.primary.withOpacity(0.7)),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal'
                            : DateFormat('dd MMM yyyy')
                                .format(_selectedDate!),
                        style: TextStyle(
                          color: _selectedDate == null
                              ? AppTheme.textSecondary
                              : AppTheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Harga Jual ────────────────────────────────────────────────
              const Text('Harga Jual',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _hargaController,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'Masukkan angka',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 24),

              // ── Buttons ───────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Batal',
                        style:
                            TextStyle(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
