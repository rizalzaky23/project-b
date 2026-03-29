import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/photo_picker_widget.dart';
import '../../../../shared/widgets/pdf_picker_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
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
  late final TextEditingController _pemilikKomersialController;
  late final TextEditingController _pemilikFiskalController;
  late final TextEditingController _kendaraanIdController;

  // STNK berlaku
  late final TextEditingController _stnkBerlakuMulaiController;
  late final TextEditingController _stnkBerlakuAkhirController;
  DateTime? _stnkBerlakuMulaiDate;
  DateTime? _stnkBerlakuAkhirDate;

  XFile? _fotoStnk, _fotoBpkb, _fotoNomor, _fotoKm;
  bool _fotoStnkDel = false, _fotoBpkbDel = false, _fotoNomorDel = false, _fotoKmDel = false;

  XFile? _kartuKir, _lembarKir;
  bool _kartuKirDel = false, _lembarKirDel = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _noPolisiController = TextEditingController(text: e?.noPolisi ?? '');
    _namaPemilikController = TextEditingController(text: e?.namaPemilik ?? '');
    _pemilikKomersialController = TextEditingController(text: e?.pemilikKomersial ?? '');
    _pemilikFiskalController = TextEditingController(text: e?.pemilikFiskal ?? '');
    _kendaraanIdController = TextEditingController(text: (widget.kendaraanId ?? e?.kendaraanId)?.toString() ?? '');
    _stnkBerlakuMulaiController = TextEditingController(
      text: e?.stnkBerlakuMulai != null ? FormatHelper.date(e!.stnkBerlakuMulai) : '',
    );
    _stnkBerlakuAkhirController = TextEditingController(
      text: e?.stnkBerlakuAkhir != null ? FormatHelper.date(e!.stnkBerlakuAkhir) : '',
    );
  }

  @override
  void dispose() {
    _noPolisiController.dispose();
    _namaPemilikController.dispose();
    _pemilikKomersialController.dispose();
    _pemilikFiskalController.dispose();
    _kendaraanIdController.dispose();
    _stnkBerlakuMulaiController.dispose();
    _stnkBerlakuAkhirController.dispose();
    super.dispose();
  }

  Future<void> _pickStnkMulai() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _stnkBerlakuMulaiDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dt != null) {
      setState(() {
        _stnkBerlakuMulaiDate = dt;
        _stnkBerlakuMulaiController.text = FormatHelper.date(FormatHelper.apiDate(dt));
      });
    }
  }

  Future<void> _pickStnkAkhir() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _stnkBerlakuAkhirDate ?? _stnkBerlakuMulaiDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dt != null) {
      setState(() {
        _stnkBerlakuAkhirDate = dt;
        _stnkBerlakuAkhirController.text = FormatHelper.date(FormatHelper.apiDate(dt));
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<DetailKendaraanBloc>();
    final pemilikKomersial = _pemilikKomersialController.text.trim().isEmpty ? null : _pemilikKomersialController.text.trim();
    final pemilikFiskal = _pemilikFiskalController.text.trim().isEmpty ? null : _pemilikFiskalController.text.trim();

    final stnkMulai = _stnkBerlakuMulaiDate != null
        ? FormatHelper.apiDate(_stnkBerlakuMulaiDate!)
        : widget.existing?.stnkBerlakuMulai;
    final stnkAkhir = _stnkBerlakuAkhirDate != null
        ? FormatHelper.apiDate(_stnkBerlakuAkhirDate!)
        : widget.existing?.stnkBerlakuAkhir;

    if (_isEdit) {
      bloc.add(DetailKendaraanUpdateRequested(
        id: widget.existing!.id,
        noPolisi: _noPolisiController.text,
        namaPemilik: _namaPemilikController.text,
        pemilikKomersial: pemilikKomersial,
        pemilikFiskal: pemilikFiskal,
        fotoStnk: _fotoStnk,
        stnkBerlakuMulai: stnkMulai,
        stnkBerlakuAkhir: stnkAkhir,
        fotoBpkb: _fotoBpkb,
        fotoNomor: _fotoNomor,
        fotoKm: _fotoKm,
        kartuKir: _kartuKir,
        lembarKir: _lembarKir,
        fotoStnkDeleted: _fotoStnkDel,
        fotoBpkbDeleted: _fotoBpkbDel,
        fotoNomorDeleted: _fotoNomorDel,
        fotoKmDeleted: _fotoKmDel,
        kartuKirDeleted: _kartuKirDel,
        lembarKirDeleted: _lembarKirDel,
      ));
    } else {
      bloc.add(DetailKendaraanCreateRequested(
        kendaraanId: int.parse(_kendaraanIdController.text),
        noPolisi: _noPolisiController.text,
        namaPemilik: _namaPemilikController.text,
        pemilikKomersial: pemilikKomersial,
        pemilikFiskal: pemilikFiskal,
        fotoStnk: _fotoStnk,
        stnkBerlakuMulai: stnkMulai,
        stnkBerlakuAkhir: stnkAkhir,
        fotoBpkb: _fotoBpkb,
        fotoNomor: _fotoNomor,
        fotoKm: _fotoKm,
        kartuKir: _kartuKir,
        lembarKir: _lembarKir,
      ));
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

                    // ── Informasi STNK & BPKB ──
                    const _FormSectionHeader(icon: Icons.credit_card_outlined, label: 'Informasi STNK & BPKB'),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _noPolisiController,
                      label: 'No. Polisi',
                      prefixIcon: Icons.credit_card_outlined,
                      validator: (v) => (v == null || v.isEmpty) ? 'No. Polisi wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _namaPemilikController,
                      label: 'Nama Pemilik',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => (v == null || v.isEmpty) ? 'Nama pemilik wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _pemilikKomersialController,
                      label: 'Pemilik Komersial (Opsional)',
                      prefixIcon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _pemilikFiskalController,
                      label: 'Pemilik Fiskal (Opsional)',
                      prefixIcon: Icons.account_balance_outlined,
                    ),
                    const SizedBox(height: 24),

                    // ── Foto Dokumen ──
                    const _FormSectionHeader(icon: Icons.photo_library_outlined, label: 'Foto Dokumen'),
                    const SizedBox(height: 12),

                    // Foto STNK + tanggal berlaku & Foto BPKB dalam satu baris
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PhotoPickerWidget(
                                label: 'Foto STNK',
                                pickedFile: _fotoStnk,
                                existingUrl: widget.existing?.fotoStnk,
                                onPhotoResult: (r) => setState(() { _fotoStnk = r.hasPicked ? r.file : null; _fotoStnkDel = r.isDeleted; }),
                                onChanged: (f) => setState(() => _fotoStnk = f),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _stnkBerlakuMulaiController,
                                      label: 'Berlaku Mulai',
                                      prefixIcon: Icons.calendar_today_outlined,
                                      readOnly: true,
                                      onTap: _pickStnkMulai,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppTextField(
                                      controller: _stnkBerlakuAkhirController,
                                      label: 'Berlaku Akhir',
                                      prefixIcon: Icons.event_outlined,
                                      readOnly: true,
                                      onTap: _pickStnkAkhir,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PhotoPickerWidget(
                            label: 'Foto BPKB',
                            pickedFile: _fotoBpkb,
                            existingUrl: widget.existing?.fotoBpkb,
                            onPhotoResult: (r) => setState(() { _fotoBpkb = r.hasPicked ? r.file : null; _fotoBpkbDel = r.isDeleted; }),
                            onChanged: (f) => setState(() => _fotoBpkb = f),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: PhotoPickerWidget(label: 'Foto Nomor', pickedFile: _fotoNomor, existingUrl: widget.existing?.fotoNomor, onPhotoResult: (r) => setState(() { _fotoNomor = r.hasPicked ? r.file : null; _fotoNomorDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoNomor = f))),
                      const SizedBox(width: 12),
                      Expanded(child: PhotoPickerWidget(label: 'Foto KM', pickedFile: _fotoKm, existingUrl: widget.existing?.fotoKm, onPhotoResult: (r) => setState(() { _fotoKm = r.hasPicked ? r.file : null; _fotoKmDel = r.isDeleted; }), onChanged: (f) => setState(() => _fotoKm = f))),
                    ]),
                    const SizedBox(height: 24),

                    // ── Dokumen KIR ──
                    const _FormSectionHeader(icon: Icons.assignment_outlined, label: 'Dokumen KIR'),
                    const SizedBox(height: 12),
                    PdfPickerWidget(
                      label: 'Kartu KIR (PDF)',
                      pickedFile: _kartuKir,
                      existingUrl: widget.existing?.kartuKir,
                      onPdfResult: (r) => setState(() {
                        _kartuKir = r.hasPicked ? r.file : null;
                        _kartuKirDel = r.isDeleted;
                      }),
                    ),
                    const SizedBox(height: 12),
                    PdfPickerWidget(
                      label: 'Lembar KIR (PDF)',
                      pickedFile: _lembarKir,
                      existingUrl: widget.existing?.lembarKir,
                      onPdfResult: (r) => setState(() {
                        _lembarKir = r.hasPicked ? r.file : null;
                        _lembarKirDel = r.isDeleted;
                      }),
                    ),
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

class _FormSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FormSectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3, height: 18,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.4)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Icon(icon, size: 16, color: AppTheme.primary),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
    ]);
  }
}
