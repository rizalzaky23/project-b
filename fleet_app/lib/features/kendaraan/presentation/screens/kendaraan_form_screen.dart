import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/photo_picker_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/kendaraan_entity.dart';
import '../bloc/kendaraan_bloc.dart';

class KendaraanFormScreen extends StatefulWidget {
  final KendaraanEntity? existing;
  const KendaraanFormScreen({super.key, this.existing});

  @override
  State<KendaraanFormScreen> createState() => _KendaraanFormScreenState();
}

class _KendaraanFormScreenState extends State<KendaraanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _kodeController;
  late final TextEditingController _merkController;
  late final TextEditingController _tipeController;
  late final TextEditingController _warnaController;
  late final TextEditingController _noChasisController;
  late final TextEditingController _noMesinController;
  late final TextEditingController _tahunPerolehanController;
  late final TextEditingController _tahunPembuatanController;
  late final TextEditingController _hargaController;
  late final TextEditingController _dealerController;

  XFile? _fotoDepan, _fotoKiri, _fotoKanan, _fotoBelakang;
  bool _fotoDepanDeleted = false;
  bool _fotoKiriDeleted = false;
  bool _fotoKananDeleted = false;
  bool _fotoBelakangDeleted = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kodeController = TextEditingController(text: e?.kodeKendaraan ?? '');
    _merkController = TextEditingController(text: e?.merk ?? '');
    _tipeController = TextEditingController(text: e?.tipe ?? '');
    _warnaController = TextEditingController(text: e?.warna ?? '');
    _noChasisController = TextEditingController(text: e?.noChasis ?? '');
    _noMesinController = TextEditingController(text: e?.noMesin ?? '');
    _tahunPerolehanController = TextEditingController(text: e?.tahunPerolehan.toString() ?? '');
    _tahunPembuatanController = TextEditingController(text: e?.tahunPembuatan.toString() ?? '');
    _hargaController = TextEditingController(text: e?.hargaPerolehan.toStringAsFixed(0) ?? '');
    _dealerController = TextEditingController(text: e?.dealer ?? '');
  }

  @override
  void dispose() {
    for (final c in [_kodeController, _merkController, _tipeController, _warnaController,
      _noChasisController, _noMesinController, _tahunPerolehanController,
      _tahunPembuatanController, _hargaController, _dealerController]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<KendaraanBloc>();
    if (_isEdit) {
      bloc.add(KendaraanUpdateRequested(
        id: widget.existing!.id,
        kodeKendaraan: _kodeController.text,
        merk: _merkController.text,
        tipe: _tipeController.text,
        warna: _warnaController.text,
        noChasis: _noChasisController.text,
        noMesin: _noMesinController.text,
        tahunPerolehan: int.parse(_tahunPerolehanController.text),
        tahunPembuatan: int.parse(_tahunPembuatanController.text),
        hargaPerolehan: double.parse(_hargaController.text),
        dealer: _dealerController.text.isEmpty ? null : _dealerController.text,
        fotoDepan: _fotoDepan, fotoKiri: _fotoKiri,
        fotoKanan: _fotoKanan, fotoBelakang: _fotoBelakang,
        fotoDepanDeleted: _fotoDepanDeleted, fotoKiriDeleted: _fotoKiriDeleted,
        fotoKananDeleted: _fotoKananDeleted, fotoBelakangDeleted: _fotoBelakangDeleted,
      ));
    } else {
      bloc.add(KendaraanCreateRequested(
        kodeKendaraan: _kodeController.text,
        merk: _merkController.text,
        tipe: _tipeController.text,
        warna: _warnaController.text,
        noChasis: _noChasisController.text,
        noMesin: _noMesinController.text,
        tahunPerolehan: int.parse(_tahunPerolehanController.text),
        tahunPembuatan: int.parse(_tahunPembuatanController.text),
        hargaPerolehan: double.parse(_hargaController.text),
        dealer: _dealerController.text.isEmpty ? null : _dealerController.text,
        fotoDepan: _fotoDepan, fotoKiri: _fotoKiri,
        fotoKanan: _fotoKanan, fotoBelakang: _fotoBelakang,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      appBar: AppBar(
        leading: context.canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())
            : null,
        title: Text(_isEdit ? 'Edit Kendaraan' : 'Tambah Kendaraan'),
      ),
      body: BlocListener<KendaraanBloc, KendaraanState>(
        listener: (context, state) {
          if (state is KendaraanActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.success));
            context.pop();
          } else if (state is KendaraanActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message), backgroundColor: AppTheme.error));
          }
        },
        child: BlocBuilder<KendaraanBloc, KendaraanState>(
          builder: (context, state) {
            final isLoading = state is KendaraanActionLoading;
            return AppLoadingOverlay(
              isLoading: isLoading,
              child: isDesktop
                  ? _buildDesktopLayout(context, isLoading)
                  : _buildMobileLayout(context, isLoading),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isLoading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form kiri 50%
        Expanded(
          flex: 50,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Informasi Kendaraan'),
                _buildDesktopFormGrid(),
                const SizedBox(height: 32),
                AppButton(
                  label: _isEdit ? 'Simpan Perubahan' : 'Tambah Kendaraan',
                  onPressed: isLoading ? null : _submit,
                  isLoading: isLoading,
                  fullWidth: true,
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),
        VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
        // Panel foto kanan 50%
        Expanded(
          flex: 50,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Foto Kendaraan'),
                const SizedBox(height: 8),
                // Baris 1
                Row(children: [
                  Expanded(child: _photoCard(
                    label: 'Foto Depan', file: _fotoDepan, url: widget.existing?.fotoDepan,
                    onResult: (r) => setState(() { _fotoDepan = r.hasPicked ? r.file : null; _fotoDepanDeleted = r.isDeleted; }),
                    onChanged: (f) => setState(() => _fotoDepan = f),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _photoCard(
                    label: 'Foto Kiri', file: _fotoKiri, url: widget.existing?.fotoKiri,
                    onResult: (r) => setState(() { _fotoKiri = r.hasPicked ? r.file : null; _fotoKiriDeleted = r.isDeleted; }),
                    onChanged: (f) => setState(() => _fotoKiri = f),
                  )),
                ]),
                const SizedBox(height: 12),
                // Baris 2
                Row(children: [
                  Expanded(child: _photoCard(
                    label: 'Foto Kanan', file: _fotoKanan, url: widget.existing?.fotoKanan,
                    onResult: (r) => setState(() { _fotoKanan = r.hasPicked ? r.file : null; _fotoKananDeleted = r.isDeleted; }),
                    onChanged: (f) => setState(() => _fotoKanan = f),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _photoCard(
                    label: 'Foto Belakang', file: _fotoBelakang, url: widget.existing?.fotoBelakang,
                    onResult: (r) => setState(() { _fotoBelakang = r.hasPicked ? r.file : null; _fotoBelakangDeleted = r.isDeleted; }),
                    onChanged: (f) => setState(() => _fotoBelakang = f),
                  )),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('Informasi Kendaraan'),
          ..._buildFormFields(),
          const SizedBox(height: 24),
          _sectionTitle('Foto Kendaraan'),
          Row(children: [
            Expanded(child: _photoCard(
              label: 'Foto Depan', file: _fotoDepan, url: widget.existing?.fotoDepan,
              onResult: (r) => setState(() { _fotoDepan = r.hasPicked ? r.file : null; _fotoDepanDeleted = r.isDeleted; }),
              onChanged: (f) => setState(() => _fotoDepan = f),
            )),
            const SizedBox(width: 12),
            Expanded(child: _photoCard(
              label: 'Foto Kiri', file: _fotoKiri, url: widget.existing?.fotoKiri,
              onResult: (r) => setState(() { _fotoKiri = r.hasPicked ? r.file : null; _fotoKiriDeleted = r.isDeleted; }),
              onChanged: (f) => setState(() => _fotoKiri = f),
            )),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _photoCard(
              label: 'Foto Kanan', file: _fotoKanan, url: widget.existing?.fotoKanan,
              onResult: (r) => setState(() { _fotoKanan = r.hasPicked ? r.file : null; _fotoKananDeleted = r.isDeleted; }),
              onChanged: (f) => setState(() => _fotoKanan = f),
            )),
            const SizedBox(width: 12),
            Expanded(child: _photoCard(
              label: 'Foto Belakang', file: _fotoBelakang, url: widget.existing?.fotoBelakang,
              onResult: (r) => setState(() { _fotoBelakang = r.hasPicked ? r.file : null; _fotoBelakangDeleted = r.isDeleted; }),
              onChanged: (f) => setState(() => _fotoBelakang = f),
            )),
          ]),
          const SizedBox(height: 32),
          AppButton(
            label: _isEdit ? 'Simpan Perubahan' : 'Tambah Kendaraan',
            onPressed: isLoading ? null : _submit,
            isLoading: isLoading,
            fullWidth: true,
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  /// Wrapper foto dengan AspectRatio 4:3 agar semua kotak sama ukurannya
  Widget _photoCard({
    required String label,
    required XFile? file,
    required String? url,
    required void Function(PhotoResult) onResult,
    required void Function(XFile?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: PhotoPickerWidget(
            label: '',
            pickedFile: file,
            existingUrl: url,
            onPhotoResult: onResult,
            onChanged: onChanged,
            hideLabel: true,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
    );
  }

  Widget _buildDesktopFormGrid() {
    final fields = _buildFormFields();
    final List<Widget> rows = [];
    for (int i = 0; i < fields.length; i += 2) {
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: fields[i]),
        const SizedBox(width: 16),
        Expanded(child: i + 1 < fields.length ? fields[i + 1] : const SizedBox()),
      ]));
      if (i + 2 < fields.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }

  List<Widget> _buildFormFields() {
    String? req(String? v, String l) => (v == null || v.isEmpty) ? '$l wajib diisi' : null;
    String? num(String? v, String l) {
      if (v == null || v.isEmpty) return '$l wajib diisi';
      if (double.tryParse(v) == null) return '$l harus berupa angka';
      return null;
    }
    return [
      AppTextField(controller: _kodeController, label: 'Kode Kendaraan',
          prefixIcon: Icons.tag, validator: (v) => req(v, 'Kode kendaraan')),
      const SizedBox(height: 16),
      AppTextField(controller: _merkController, label: 'Merk',
          prefixIcon: Icons.branding_watermark_outlined, validator: (v) => req(v, 'Merk')),
      const SizedBox(height: 16),
      AppTextField(controller: _tipeController, label: 'Tipe',
          prefixIcon: Icons.directions_car_outlined, validator: (v) => req(v, 'Tipe')),
      const SizedBox(height: 16),
      AppTextField(controller: _warnaController, label: 'Warna',
          prefixIcon: Icons.palette_outlined, validator: (v) => req(v, 'Warna')),
      const SizedBox(height: 16),
      AppTextField(controller: _noChasisController, label: 'No. Chasis',
          prefixIcon: Icons.numbers, validator: (v) => req(v, 'No. Chasis')),
      const SizedBox(height: 16),
      AppTextField(controller: _noMesinController, label: 'No. Mesin',
          prefixIcon: Icons.engineering_outlined, validator: (v) => req(v, 'No. Mesin')),
      const SizedBox(height: 16),
      AppTextField(controller: _tahunPerolehanController, label: 'Tahun Perolehan',
          keyboardType: TextInputType.number, prefixIcon: Icons.calendar_month_outlined,
          validator: (v) => num(v, 'Tahun perolehan')),
      const SizedBox(height: 16),
      AppTextField(controller: _tahunPembuatanController, label: 'Tahun Pembuatan',
          keyboardType: TextInputType.number, prefixIcon: Icons.calendar_today_outlined,
          validator: (v) => num(v, 'Tahun pembuatan')),
      const SizedBox(height: 16),
      AppTextField(controller: _hargaController, label: 'Harga Perolehan (Rp)',
          keyboardType: TextInputType.number, prefixIcon: Icons.attach_money,
          validator: (v) => num(v, 'Harga perolehan')),
      const SizedBox(height: 16),
      AppTextField(controller: _dealerController, label: 'Dealer (Opsional)',
          prefixIcon: Icons.store_outlined),
    ];
  }
}