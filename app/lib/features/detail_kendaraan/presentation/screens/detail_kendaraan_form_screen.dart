import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/photo_picker_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../domain/entities/detail_kendaraan_entity.dart';
import '../bloc/detail_kendaraan_bloc.dart';

class DetailKendaraanFormScreen extends StatefulWidget {
  final DetailKendaraanEntity? existing;
  final int? kendaraanId;

  const DetailKendaraanFormScreen({super.key, this.existing, this.kendaraanId});

  @override
  State<DetailKendaraanFormScreen> createState() => _DetailKendaraanFormScreenState();
}

class _DetailKendaraanFormScreenState extends State<DetailKendaraanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noPolisiController;
  late final TextEditingController _namaPemilikController;
  late final TextEditingController _berlakuMulaiController;
  late final TextEditingController _kendaraanIdController;
  DateTime? _berlakuMulaiDate;
  XFile? _fotoStnk, _fotoBpkb, _fotoNomor, _fotoKm;
  bool _fotoStnkDel=false, _fotoBpkbDel=false, _fotoNomorDel=false, _fotoKmDel=false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _noPolisiController = TextEditingController(text: e?.noPolisi ?? '');
    _namaPemilikController = TextEditingController(text: e?.namaPemilik ?? '');
    _berlakuMulaiController = TextEditingController(text: e?.berlakuMulai != null ? FormatHelper.date(e?.berlakuMulai) : '');
    _kendaraanIdController = TextEditingController(text: (widget.kendaraanId ?? e?.kendaraanId)?.toString() ?? '');
  }

  @override
  void dispose() {
    _noPolisiController.dispose(); _namaPemilikController.dispose();
    _berlakuMulaiController.dispose(); _kendaraanIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (dt != null) {
      _berlakuMulaiDate = dt;
      _berlakuMulaiController.text = FormatHelper.date(FormatHelper.apiDate(dt));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<DetailKendaraanBloc>();
    final berlaku = _berlakuMulaiDate != null ? FormatHelper.apiDate(_berlakuMulaiDate!) : widget.existing?.berlakuMulai;
    if (_isEdit) {
      bloc.add(DetailKendaraanUpdateRequested(id: widget.existing!.id, noPolisi: _noPolisiController.text, namaPemilik: _namaPemilikController.text, berlakuMulai: berlaku, fotoStnk: _fotoStnk, fotoBpkb: _fotoBpkb, fotoNomor: _fotoNomor, fotoKm: _fotoKm, fotoStnkDeleted: _fotoStnkDel, fotoBpkbDeleted: _fotoBpkbDel, fotoNomorDeleted: _fotoNomorDel, fotoKmDeleted: _fotoKmDel));
    } else {
      bloc.add(DetailKendaraanCreateRequested(kendaraanId: int.parse(_kendaraanIdController.text), noPolisi: _noPolisiController.text, namaPemilik: _namaPemilikController.text, berlakuMulai: berlaku, fotoStnk: _fotoStnk, fotoBpkb: _fotoBpkb, fotoNomor: _fotoNomor, fotoKm: _fotoKm));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Detail Kendaraan' : 'Tambah Detail Kendaraan')),
      body: BlocListener<DetailKendaraanBloc, DetailKendaraanState>(
        listener: (ctx, state) {
          if (state is DetailKendaraanActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.success));
            ctx.pop();
          } else if (state is DetailKendaraanActionError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.failure.message), backgroundColor: AppTheme.error));
          }
        },
        child: BlocBuilder<DetailKendaraanBloc, DetailKendaraanState>(
          builder: (ctx, state) {
            final isLoading = state is DetailKendaraanActionLoading;
            return AppLoadingOverlay(
              isLoading: isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (!_isEdit && widget.kendaraanId == null)
                      ...[AppTextField(controller: _kendaraanIdController, label: 'ID Kendaraan', keyboardType: TextInputType.number, prefixIcon: Icons.tag, validator: (v) => (v == null || v.isEmpty) ? 'ID Kendaraan wajib diisi' : null), const SizedBox(height: 16)],
                    AppTextField(controller: _noPolisiController, label: 'No. Polisi', prefixIcon: Icons.credit_card_outlined, validator: (v) => (v == null || v.isEmpty) ? 'No. Polisi wajib diisi' : null),
                    const SizedBox(height: 16),
                    AppTextField(controller: _namaPemilikController, label: 'Nama Pemilik', prefixIcon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? 'Nama pemilik wajib diisi' : null),
                    const SizedBox(height: 16),
                    AppTextField(controller: _berlakuMulaiController, label: 'Berlaku Mulai (Opsional)', prefixIcon: Icons.calendar_today_outlined, readOnly: true, onTap: _pickDate),
                    const SizedBox(height: 24),
                    const Text('Foto Dokumen', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: PhotoPickerWidget(label: 'Foto STNK', pickedFile: _fotoStnk, existingUrl: widget.existing?.fotoStnk, onPhotoResult: (r) => setState(() { _fotoStnk = r.hasPicked ? r.file : null; _fotoStnkDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoStnk = f))),
                      const SizedBox(width: 12),
                      Expanded(child: PhotoPickerWidget(label: 'Foto BPKB', pickedFile: _fotoBpkb, existingUrl: widget.existing?.fotoBpkb, onPhotoResult: (r) => setState(() { _fotoBpkb = r.hasPicked ? r.file : null; _fotoBpkbDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoBpkb = f))),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: PhotoPickerWidget(label: 'Foto Nomor', pickedFile: _fotoNomor, existingUrl: widget.existing?.fotoNomor, onPhotoResult: (r) => setState(() { _fotoNomor = r.hasPicked ? r.file : null; _fotoNomorDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoNomor = f))),
                      const SizedBox(width: 12),
                      Expanded(child: PhotoPickerWidget(label: 'Foto KM', pickedFile: _fotoKm, existingUrl: widget.existing?.fotoKm, onPhotoResult: (r) => setState(() { _fotoKm = r.hasPicked ? r.file : null; _fotoKmDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoKm = f))),
                    ]),
                    const SizedBox(height: 32),
                    AppButton(label: _isEdit ? 'Simpan' : 'Tambah', onPressed: isLoading ? null : _submit, isLoading: isLoading, fullWidth: true),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
