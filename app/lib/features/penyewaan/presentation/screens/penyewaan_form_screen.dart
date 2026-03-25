import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/penyewaan_entity.dart';
import '../bloc/penyewaan_bloc.dart';

class PenyewaanFormScreen extends StatefulWidget {
  final PenyewaanEntity? existing;
  final int? kendaraanId;
  const PenyewaanFormScreen({super.key, this.existing, this.kendaraanId});

  @override
  State<PenyewaanFormScreen> createState() => _PenyewaanFormScreenState();
}

class _PenyewaanFormScreenState extends State<PenyewaanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kendaraanIdCtrl,
      _kodeCtrl,
      _masaSewaCtrl,
      _tglMulaiCtrl,
      _tglSelesaiCtrl,
      _penangCtrl,
      _lokasiCtrl,
      _salesCtrl,
      _nilaiCtrl;
  DateTime? _tglMulai, _tglSelesai;
  bool _group = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kendaraanIdCtrl = TextEditingController(
        text: (widget.kendaraanId ?? e?.kendaraanId)?.toString() ?? '');
    _kodeCtrl = TextEditingController(text: e?.kodePenyewa ?? '');
    _masaSewaCtrl = TextEditingController(text: e?.masaSewa.toString() ?? '');
    _tglMulaiCtrl = TextEditingController(
        text:
            e?.tanggalMulai != null ? FormatHelper.date(e!.tanggalMulai) : '');
    _tglSelesaiCtrl = TextEditingController(
        text: e?.tanggalSelesai != null
            ? FormatHelper.date(e!.tanggalSelesai)
            : '');
    _penangCtrl = TextEditingController(text: e?.penanggungJawab ?? '');
    _lokasiCtrl = TextEditingController(text: e?.lokasiSewa ?? '');
    _salesCtrl = TextEditingController(text: e?.sales ?? '');
    _nilaiCtrl =
        TextEditingController(text: e?.nilaiSewa.toStringAsFixed(0) ?? '');
    _group = e?.group ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _kendaraanIdCtrl,
      _kodeCtrl,
      _masaSewaCtrl,
      _tglMulaiCtrl,
      _tglSelesaiCtrl,
      _penangCtrl,
      _lokasiCtrl,
      _salesCtrl,
      _nilaiCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(
      TextEditingController ctrl, void Function(DateTime) onPick) async {
    final dt = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    if (dt != null) {
      onPick(dt);
      ctrl.text = FormatHelper.date(FormatHelper.apiDate(dt));
    }
  }

  void _calcMasaSewa() {
    if (_tglMulai != null && _tglSelesai != null) {
      final diff = _tglSelesai!.difference(_tglMulai!).inDays;
      _masaSewaCtrl.text = diff.toString();
    }
  }

  String? _req(String? v, String l) =>
      (v == null || v.isEmpty) ? '$l wajib diisi' : null;
  String? _num(String? v, String l) {
    if (v == null || v.isEmpty) return '$l wajib diisi';
    if (double.tryParse(v) == null) return '$l harus angka';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final mulai = _tglMulai != null
        ? FormatHelper.apiDate(_tglMulai!)
        : widget.existing?.tanggalMulai ?? '';
    final selesai = _tglSelesai != null
        ? FormatHelper.apiDate(_tglSelesai!)
        : widget.existing?.tanggalSelesai ?? '';
    if (_isEdit) {
      context.read<PenyewaanBloc>().add(PenyewaanUpdateRequested(
          id: widget.existing!.id,
          kodePenyewa: _kodeCtrl.text,
          group: _group,
          masaSewa: int.parse(_masaSewaCtrl.text),
          tanggalMulai: mulai,
          tanggalSelesai: selesai,
          penanggungJawab: _penangCtrl.text,
          nilaiSewa: double.parse(_nilaiCtrl.text),
          lokasiSewa: _lokasiCtrl.text.isEmpty ? null : _lokasiCtrl.text,
          sales: _salesCtrl.text.isEmpty ? null : _salesCtrl.text));
    } else {
      context.read<PenyewaanBloc>().add(PenyewaanCreateRequested(
          kendaraanId: int.parse(_kendaraanIdCtrl.text),
          kodePenyewa: _kodeCtrl.text,
          group: _group,
          masaSewa: int.parse(_masaSewaCtrl.text),
          tanggalMulai: mulai,
          tanggalSelesai: selesai,
          penanggungJawab: _penangCtrl.text,
          nilaiSewa: double.parse(_nilaiCtrl.text),
          lokasiSewa: _lokasiCtrl.text.isEmpty ? null : _lokasiCtrl.text,
          sales: _salesCtrl.text.isEmpty ? null : _salesCtrl.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(_isEdit ? 'Edit Penyewaan' : 'Tambah Penyewaan')),
      body: BlocListener<PenyewaanBloc, PenyewaanState>(
        listener: (ctx, state) {
          if (state is PenyewaanActionSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.success));
            ctx.pop();
          } else if (state is PenyewaanActionError) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(state.failure.message),
                backgroundColor: AppTheme.error));
          }
        },
        child: BlocBuilder<PenyewaanBloc, PenyewaanState>(
          builder: (ctx, state) {
            final isLoading = state is PenyewaanActionLoading;
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
                              const SizedBox(height: 16)
                            ],
                            AppTextField(
                                controller: _kodeCtrl,
                                label: 'Kode Penyewa',
                                prefixIcon: Icons.person_outlined,
                                validator: (v) => _req(v, 'Kode Penyewa')),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              value: _group,
                              onChanged: (v) => setState(() => _group = v),
                              title: const Text('Penyewaan Group'),
                              tileColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                  child: AppTextField(
                                      controller: _tglMulaiCtrl,
                                      label: 'Tanggal Mulai',
                                      prefixIcon: Icons.calendar_today_outlined,
                                      readOnly: true,
                                      onTap: () =>
                                          _pickDate(_tglMulaiCtrl, (d) {
                                            _tglMulai = d;
                                            _calcMasaSewa();
                                          }),
                                      validator: (v) =>
                                          _req(v, 'Tanggal Mulai'))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: AppTextField(
                                      controller: _tglSelesaiCtrl,
                                      label: 'Tanggal Selesai',
                                      prefixIcon: Icons.event_outlined,
                                      readOnly: true,
                                      onTap: () =>
                                          _pickDate(_tglSelesaiCtrl, (d) {
                                            _tglSelesai = d;
                                            _calcMasaSewa();
                                          }),
                                      validator: (v) =>
                                          _req(v, 'Tanggal Selesai'))),
                            ]),
                            const SizedBox(height: 16),
                            AppTextField(
                                controller: _masaSewaCtrl,
                                label: 'Masa Sewa (hari)',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.timer_outlined,
                                validator: (v) => _num(v, 'Masa Sewa')),
                            const SizedBox(height: 16),
                            AppTextField(
                                controller: _penangCtrl,
                                label: 'Penanggung Jawab',
                                prefixIcon: Icons.badge_outlined,
                                validator: (v) => _req(v, 'Penanggung Jawab')),
                            const SizedBox(height: 16),
                            AppTextField(
                                controller: _nilaiCtrl,
                                label: 'Nilai Sewa (Rp)',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.attach_money,
                                validator: (v) => _num(v, 'Nilai Sewa')),
                            const SizedBox(height: 16),
                            AppTextField(
                                controller: _lokasiCtrl,
                                label: 'Lokasi Sewa (Opsional)',
                                prefixIcon: Icons.location_on_outlined),
                            const SizedBox(height: 16),
                            AppTextField(
                                controller: _salesCtrl,
                                label: 'Sales (Opsional)',
                                prefixIcon: Icons.person_outline),
                            const SizedBox(height: 32),
                            AppButton(
                                label: _isEdit ? 'Simpan' : 'Tambah',
                                onPressed: isLoading ? null : _submit,
                                isLoading: isLoading,
                                fullWidth: true),
                            const SizedBox(height: 32),
                          ])),
                ));
          },
        ),
      ),
    );
  }
}
