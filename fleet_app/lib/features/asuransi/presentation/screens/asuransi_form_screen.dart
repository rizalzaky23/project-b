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
import '../../domain/entities/asuransi_entity.dart';
import '../bloc/asuransi_bloc.dart';

class AsuransiFormScreen extends StatefulWidget {
  final AsuransiEntity? existing;
  final int? kendaraanId;
  const AsuransiFormScreen({super.key, this.existing, this.kendaraanId});

  @override
  State<AsuransiFormScreen> createState() => _AsuransiFormScreenState();
}

class _AsuransiFormScreenState extends State<AsuransiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kendaraanIdCtrl, _perusahaanCtrl, _jenisCtrl, _tanggalMulaiCtrl, _tanggalAkhirCtrl, _noPolisCtrl, _premiCtrl, _pertanggunganCtrl;
  DateTime? _tanggalMulai, _tanggalAkhir;
  XFile? _fotoDepan, _fotoKiri, _fotoKanan, _fotoBelakang, _fotoDashboard, _fotoKm;
  bool _fotoDepanDel=false, _fotoKiriDel=false, _fotoKananDel=false, _fotoBelakangDel=false, _fotoDashboardDel=false, _fotoKmDel=false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kendaraanIdCtrl = TextEditingController(text: (widget.kendaraanId ?? e?.kendaraanId)?.toString() ?? '');
    _perusahaanCtrl = TextEditingController(text: e?.perusahaanAsuransi ?? '');
    _jenisCtrl = TextEditingController(text: e?.jenisAsuransi ?? '');
    _tanggalMulaiCtrl = TextEditingController(text: e?.tanggalMulai != null ? FormatHelper.date(e!.tanggalMulai) : '');
    _tanggalAkhirCtrl = TextEditingController(text: e?.tanggalAkhir != null ? FormatHelper.date(e!.tanggalAkhir) : '');
    _noPolisCtrl = TextEditingController(text: e?.noPolis ?? '');
    _premiCtrl = TextEditingController(text: e?.nilaiPremi.toStringAsFixed(0) ?? '');
    _pertanggunganCtrl = TextEditingController(text: e?.nilaiPertanggungan.toStringAsFixed(0) ?? '');
  }

  @override void dispose() { for (final c in [_kendaraanIdCtrl, _perusahaanCtrl, _jenisCtrl, _tanggalMulaiCtrl, _tanggalAkhirCtrl, _noPolisCtrl, _premiCtrl, _pertanggunganCtrl]) {
    c.dispose();
  } super.dispose(); }

  Future<void> _pickDate(TextEditingController ctrl, void Function(DateTime) onPick) async {
    final dt = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (dt != null) { onPick(dt); ctrl.text = FormatHelper.date(FormatHelper.apiDate(dt)); }
  }

  String? _req(String? v, String l) => (v == null || v.isEmpty) ? '$l wajib diisi' : null;
  String? _num(String? v, String l) { if (v == null || v.isEmpty) return '$l wajib diisi'; if (double.tryParse(v) == null) return '$l harus angka'; return null; }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final mulai = _tanggalMulai != null ? FormatHelper.apiDate(_tanggalMulai!) : widget.existing?.tanggalMulai ?? '';
    final akhir = _tanggalAkhir != null ? FormatHelper.apiDate(_tanggalAkhir!) : widget.existing?.tanggalAkhir ?? '';
    if (_isEdit) {
      context.read<AsuransiBloc>().add(AsuransiUpdateRequested(id: widget.existing!.id, perusahaanAsuransi: _perusahaanCtrl.text, jenisAsuransi: _jenisCtrl.text, tanggalMulai: mulai, tanggalAkhir: akhir, noPolis: _noPolisCtrl.text, nilaiPremi: double.parse(_premiCtrl.text), nilaiPertanggungan: double.parse(_pertanggunganCtrl.text), fotoDepan: _fotoDepan, fotoKiri: _fotoKiri, fotoKanan: _fotoKanan, fotoBelakang: _fotoBelakang, fotoDashboard: _fotoDashboard, fotoKm: _fotoKm, fotoDepanDeleted: _fotoDepanDel, fotoKiriDeleted: _fotoKiriDel, fotoKananDeleted: _fotoKananDel, fotoBelakangDeleted: _fotoBelakangDel, fotoDashboardDeleted: _fotoDashboardDel, fotoKmDeleted: _fotoKmDel));
    } else {
      context.read<AsuransiBloc>().add(AsuransiCreateRequested(kendaraanId: int.parse(_kendaraanIdCtrl.text), perusahaanAsuransi: _perusahaanCtrl.text, jenisAsuransi: _jenisCtrl.text, tanggalMulai: mulai, tanggalAkhir: akhir, noPolis: _noPolisCtrl.text, nilaiPremi: double.parse(_premiCtrl.text), nilaiPertanggungan: double.parse(_pertanggunganCtrl.text), fotoDepan: _fotoDepan, fotoKiri: _fotoKiri, fotoKanan: _fotoKanan, fotoBelakang: _fotoBelakang, fotoDashboard: _fotoDashboard, fotoKm: _fotoKm));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Asuransi' : 'Tambah Asuransi')),
      body: BlocListener<AsuransiBloc, AsuransiState>(
        listener: (ctx, state) {
          if (state is AsuransiActionSuccess) { ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.success)); ctx.pop(); }
          else if (state is AsuransiActionError) { ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.failure.message), backgroundColor: AppTheme.error)); }
        },
        child: BlocBuilder<AsuransiBloc, AsuransiState>(
          builder: (ctx, state) {
            final isLoading = state is AsuransiActionLoading;
            return AppLoadingOverlay(isLoading: isLoading, child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (!_isEdit && widget.kendaraanId == null) ...[AppTextField(controller: _kendaraanIdCtrl, label: 'ID Kendaraan', keyboardType: TextInputType.number, prefixIcon: Icons.tag, validator: (v) => _req(v, 'ID Kendaraan')), const SizedBox(height: 16)],
                AppTextField(controller: _perusahaanCtrl, label: 'Perusahaan Asuransi', prefixIcon: Icons.business_outlined, validator: (v) => _req(v, 'Perusahaan')),
                const SizedBox(height: 16),
                AppTextField(controller: _jenisCtrl, label: 'Jenis Asuransi', prefixIcon: Icons.category_outlined, validator: (v) => _req(v, 'Jenis')),
                const SizedBox(height: 16),
                AppTextField(controller: _noPolisCtrl, label: 'No. Polis', prefixIcon: Icons.numbers, validator: (v) => _req(v, 'No. Polis')),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: AppTextField(controller: _tanggalMulaiCtrl, label: 'Tanggal Mulai', prefixIcon: Icons.calendar_today_outlined, readOnly: true, onTap: () => _pickDate(_tanggalMulaiCtrl, (d) => _tanggalMulai = d), validator: (v) => _req(v, 'Tanggal Mulai'))),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(controller: _tanggalAkhirCtrl, label: 'Tanggal Akhir', prefixIcon: Icons.event_outlined, readOnly: true, onTap: () => _pickDate(_tanggalAkhirCtrl, (d) => _tanggalAkhir = d), validator: (v) => _req(v, 'Tanggal Akhir'))),
                ]),
                const SizedBox(height: 16),
                AppTextField(controller: _premiCtrl, label: 'Nilai Premi (Rp)', keyboardType: TextInputType.number, prefixIcon: Icons.attach_money, validator: (v) => _num(v, 'Nilai Premi')),
                const SizedBox(height: 16),
                AppTextField(controller: _pertanggunganCtrl, label: 'Nilai Pertanggungan (Rp)', keyboardType: TextInputType.number, prefixIcon: Icons.monetization_on_outlined, validator: (v) => _num(v, 'Nilai Pertanggungan')),
                const SizedBox(height: 24),
                const Text('Foto', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  SizedBox(width: 140, child: PhotoPickerWidget(label: 'Foto Depan', pickedFile: _fotoDepan, existingUrl: widget.existing?.fotoDepan, onPhotoResult: (r) => setState(() { _fotoDepan = r.hasPicked ? r.file : null; _fotoDepanDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoDepan = f))),
                  SizedBox(width: 140, child: PhotoPickerWidget(label: 'Foto Kiri', pickedFile: _fotoKiri, existingUrl: widget.existing?.fotoKiri, onPhotoResult: (r) => setState(() { _fotoKiri = r.hasPicked ? r.file : null; _fotoKiriDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoKiri = f))),
                  SizedBox(width: 140, child: PhotoPickerWidget(label: 'Foto Kanan', pickedFile: _fotoKanan, existingUrl: widget.existing?.fotoKanan, onPhotoResult: (r) => setState(() { _fotoKanan = r.hasPicked ? r.file : null; _fotoKananDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoKanan = f))),
                  SizedBox(width: 140, child: PhotoPickerWidget(label: 'Foto Belakang', pickedFile: _fotoBelakang, existingUrl: widget.existing?.fotoBelakang, onPhotoResult: (r) => setState(() { _fotoBelakang = r.hasPicked ? r.file : null; _fotoBelakangDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoBelakang = f))),
                  SizedBox(width: 140, child: PhotoPickerWidget(label: 'Foto Dashboard', pickedFile: _fotoDashboard, existingUrl: widget.existing?.fotoDashboard, onPhotoResult: (r) => setState(() { _fotoDashboard = r.hasPicked ? r.file : null; _fotoDashboardDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoDashboard = f))),
                  SizedBox(width: 140, child: PhotoPickerWidget(label: 'Foto KM', pickedFile: _fotoKm, existingUrl: widget.existing?.fotoKm, onPhotoResult: (r) => setState(() { _fotoKm = r.hasPicked ? r.file : null; _fotoKmDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoKm = f))),
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
