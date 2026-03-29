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
import '../../domain/entities/servis_entity.dart';
import '../bloc/servis_bloc.dart';

class ServisFormScreen extends StatefulWidget {
  final ServisEntity? existing;
  final int? kendaraanId;
  const ServisFormScreen({super.key, this.existing, this.kendaraanId});

  @override
  State<ServisFormScreen> createState() => _ServisFormScreenState();
}

class _ServisFormScreenState extends State<ServisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kendaraanIdCtrl;
  late final TextEditingController _tanggalServisCtrl;
  late final TextEditingController _kilometerCtrl;

  DateTime? _tanggalServis;
  
  XFile? _fotoKm;
  bool _fotoKmDel = false;
  
  XFile? _fotoInvoice;
  bool _fotoInvoiceDel = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kendaraanIdCtrl = TextEditingController(
        text: (widget.kendaraanId ?? e?.kendaraanId)?.toString() ?? '');
    _tanggalServisCtrl = TextEditingController(
        text: e?.tanggalServis != null ? FormatHelper.date(e!.tanggalServis) : '');
    _kilometerCtrl = TextEditingController(text: e?.kilometer.toString() ?? '');
  }

  @override
  void dispose() {
    _kendaraanIdCtrl.dispose();
    _tanggalServisCtrl.dispose();
    _kilometerCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (dt != null) {
      setState(() {
        _tanggalServis = dt;
        _tanggalServisCtrl.text = FormatHelper.date(FormatHelper.apiDate(dt));
      });
    }
  }

  String? _req(String? v, String l) =>
      (v == null || v.isEmpty) ? '$l wajib diisi' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final tanggal = _tanggalServis != null
        ? FormatHelper.apiDate(_tanggalServis!)
        : widget.existing?.tanggalServis ?? '';

    if (_isEdit) {
      context.read<ServisBloc>().add(ServisUpdateRequested(
            id: widget.existing!.id,
            tanggalServis: tanggal,
            kilometer: int.tryParse(_kilometerCtrl.text),
            fotoKm: _fotoKm,
            fotoKmDeleted: _fotoKmDel,
            fotoInvoice: _fotoInvoice,
            fotoInvoiceDeleted: _fotoInvoiceDel,
          ));
    } else {
      context.read<ServisBloc>().add(ServisCreateRequested(
            kendaraanId: int.parse(_kendaraanIdCtrl.text),
            tanggalServis: tanggal,
            kilometer: int.tryParse(_kilometerCtrl.text) ?? 0,
            fotoKm: _fotoKm,
            fotoInvoice: _fotoInvoice,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Edit Servis' : 'Tambah Servis')),
      body: BlocListener<ServisBloc, ServisState>(
        listener: (ctx, state) {
          if (state is ServisActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success));
            ctx.pop();
          } else if (state is ServisActionError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppTheme.error));
          }
        },
        child: BlocBuilder<ServisBloc, ServisState>(
          builder: (ctx, state) {
            final isLoading = state is ServisActionLoading;
            return AppLoadingOverlay(
              isLoading: isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isEdit && widget.kendaraanId == null) ...[
                        AppTextField(
                            controller: _kendaraanIdCtrl,
                            label: 'ID Kendaraan',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.tag,
                            validator: (v) => _req(v, 'ID Kendaraan')),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        controller: _tanggalServisCtrl,
                        label: 'Tanggal Servis',
                        prefixIcon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (v) => _req(v, 'Tanggal Servis'),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _kilometerCtrl,
                        label: 'Kilometer',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.speed_outlined,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Kilometer wajib diisi';
                          if (int.tryParse(v) == null) return 'Kilometer harus angka';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text('Upload Foto',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: PhotoPickerWidget(
                              label: 'Foto KM',
                              pickedFile: _fotoKm,
                              existingUrl: widget.existing?.fotoKm,
                              onPhotoResult: (r) => setState(() {
                                _fotoKm = r.hasPicked ? r.file : null;
                                _fotoKmDel = r.isDeleted;
                              }),
                              onChanged: (f) => setState(() => _fotoKm = f),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PhotoPickerWidget(
                              label: 'Foto Invoice',
                              pickedFile: _fotoInvoice,
                              existingUrl: widget.existing?.fotoInvoice,
                              onPhotoResult: (r) => setState(() {
                                _fotoInvoice = r.hasPicked ? r.file : null;
                                _fotoInvoiceDel = r.isDeleted;
                              }),
                              onChanged: (f) => setState(() => _fotoInvoice = f),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                          label: _isEdit ? 'Simpan' : 'Tambah',
                          onPressed: isLoading ? null : _submit,
                          isLoading: isLoading,
                          fullWidth: true),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
