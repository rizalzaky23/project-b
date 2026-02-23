import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/photo_picker_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/kejadian_entity.dart';
import '../bloc/kejadian_bloc.dart';

class KejadianFormScreen extends StatefulWidget {
  final KejadianEntity? existing;
  final int? kendaraanId;
  const KejadianFormScreen({super.key, this.existing, this.kendaraanId});

  @override
  State<KejadianFormScreen> createState() => _KejadianFormScreenState();
}

class _KejadianFormScreenState extends State<KejadianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kendaraanIdCtrl, _tanggalCtrl, _deskripsiCtrl;
  DateTime? _tanggal;
  XFile? _fotoKm, _foto1, _foto2;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kendaraanIdCtrl = TextEditingController(text: (widget.kendaraanId ?? e?.kendaraanId)?.toString() ?? '');
    _tanggalCtrl = TextEditingController(text: e?.tanggal != null ? FormatHelper.date(e!.tanggal) : '');
    _deskripsiCtrl = TextEditingController(text: e?.deskripsi ?? '');
  }

  @override void dispose() { _kendaraanIdCtrl.dispose(); _tanggalCtrl.dispose(); _deskripsiCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (dt != null) { _tanggal = dt; _tanggalCtrl.text = FormatHelper.date(FormatHelper.apiDate(dt)); }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final tgl = _tanggal != null ? FormatHelper.apiDate(_tanggal!) : widget.existing?.tanggal ?? '';
    if (_isEdit) {
      context.read<KejadianBloc>().add(KejadianUpdateRequested(id: widget.existing!.id, tanggal: tgl, deskripsi: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text, fotoKm: _fotoKm, foto1: _foto1, foto2: _foto2));
    } else {
      context.read<KejadianBloc>().add(KejadianCreateRequested(kendaraanId: int.parse(_kendaraanIdCtrl.text), tanggal: tgl, deskripsi: _deskripsiCtrl.text.isEmpty ? null : _deskripsiCtrl.text, fotoKm: _fotoKm, foto1: _foto1, foto2: _foto2));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Kejadian' : 'Tambah Kejadian')),
      body: BlocListener<KejadianBloc, KejadianState>(
        listener: (ctx, state) {
          if (state is KejadianActionSuccess) { ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.success)); ctx.pop(); }
          else if (state is KejadianActionError) { ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.failure.message), backgroundColor: AppTheme.error)); }
        },
        child: BlocBuilder<KejadianBloc, KejadianState>(
          builder: (ctx, state) {
            final isLoading = state is KejadianActionLoading;
            return AppLoadingOverlay(isLoading: isLoading, child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (!_isEdit && widget.kendaraanId == null) ...[AppTextField(controller: _kendaraanIdCtrl, label: 'ID Kendaraan', keyboardType: TextInputType.number, prefixIcon: Icons.tag, validator: (v) => (v == null || v.isEmpty) ? 'ID Kendaraan wajib diisi' : null), const SizedBox(height: 16)],
                AppTextField(controller: _tanggalCtrl, label: 'Tanggal Kejadian', prefixIcon: Icons.calendar_today_outlined, readOnly: true, onTap: _pickDate, validator: (v) => (v == null || v.isEmpty) ? 'Tanggal wajib diisi' : null),
                const SizedBox(height: 16),
                AppTextField(controller: _deskripsiCtrl, label: 'Deskripsi (Opsional)', prefixIcon: Icons.description_outlined, maxLines: 4),
                const SizedBox(height: 24),
                const Text('Foto', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: PhotoPickerWidget(label: 'Foto KM', pickedFile: _fotoKm, existingUrl: widget.existing?.fotoKm, onChanged: (f) => setState(() => _fotoKm = f))),
                  const SizedBox(width: 12),
                  Expanded(child: PhotoPickerWidget(label: 'Foto 1', pickedFile: _foto1, existingUrl: widget.existing?.foto1, onChanged: (f) => setState(() => _foto1 = f))),
                  const SizedBox(width: 12),
                  Expanded(child: PhotoPickerWidget(label: 'Foto 2', pickedFile: _foto2, existingUrl: widget.existing?.foto2, onChanged: (f) => setState(() => _foto2 = f))),
                ]),
                const SizedBox(height: 32),
                AppButton(label: _isEdit ? 'Simpan' : 'Tambah', onPressed: isLoading ? null : _submit, isLoading: isLoading, fullWidth: true),
                const SizedBox(height: 32),
              ])),
            ));
          },
        ),
      ),
    );
  }
}
