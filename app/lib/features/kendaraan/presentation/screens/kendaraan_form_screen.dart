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
  // Track foto yang dihapus user (agar bisa kirim sinyal hapus ke API)
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
    _tahunPerolehanController =
        TextEditingController(text: e?.tahunPerolehan.toString() ?? '');
    _tahunPembuatanController =
        TextEditingController(text: e?.tahunPembuatan.toString() ?? '');
    _hargaController = TextEditingController(
        text: e?.hargaPerolehan.toStringAsFixed(0) ?? '');
    _dealerController = TextEditingController(text: e?.dealer ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _kodeController, _merkController, _tipeController, _warnaController,
      _noChasisController, _noMesinController, _tahunPerolehanController,
      _tahunPembuatanController, _hargaController, _dealerController
    ]) {
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
        fotoDepan: _fotoDepan,
        fotoKiri: _fotoKiri,
        fotoKanan: _fotoKanan,
        fotoBelakang: _fotoBelakang,
        fotoDepanDeleted: _fotoDepanDeleted,
        fotoKiriDeleted: _fotoKiriDeleted,
        fotoKananDeleted: _fotoKananDeleted,
        fotoBelakangDeleted: _fotoBelakangDeleted,
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
        fotoDepan: _fotoDepan,
        fotoKiri: _fotoKiri,
        fotoKanan: _fotoKanan,
        fotoBelakang: _fotoBelakang,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kendaraan' : 'Tambah Kendaraan'),
      ),
      body: BlocListener<KendaraanBloc, KendaraanState>(
        listener: (context, state) {
          if (state is KendaraanActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.success),
            );
            context.pop();
          } else if (state is KendaraanActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message), backgroundColor: AppTheme.error),
            );
          }
        },
        child: BlocBuilder<KendaraanBloc, KendaraanState>(
          builder: (context, state) {
            final isLoading = state is KendaraanActionLoading;
            return AppLoadingOverlay(
              isLoading: isLoading,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 80 : 16,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Informasi Kendaraan'),
                        isDesktop ? _buildDesktopGrid() : _buildMobileFields(),
                        const SizedBox(height: 24),
                        _sectionTitle('Foto Kendaraan'),
                        isDesktop
                            ? _buildPhotoGridDesktop()
                            : _buildPhotoGridMobile(),
                        const SizedBox(height: 32),
                        AppButton(
                          label: _isEdit ? 'Simpan Perubahan' : 'Tambah Kendaraan',
                          onPressed: isLoading ? null : _submit,
                          isLoading: isLoading,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15)),
    );
  }

  Widget _buildMobileFields() {
    return Column(
      children: [
        ..._buildFormFields(),
      ],
    );
  }

  Widget _buildDesktopGrid() {
    final fields = _buildFormFields();
    final List<Widget> rows = [];
    for (int i = 0; i < fields.length; i += 2) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: fields[i]),
          const SizedBox(width: 16),
          Expanded(child: i + 1 < fields.length ? fields[i + 1] : const SizedBox()),
        ],
      ));
      if (i + 2 < fields.length) rows.add(const SizedBox(height: 16));
    }
    return Column(children: rows);
  }

  List<Widget> _buildFormFields() {
    String? required(String? v, String label) =>
        (v == null || v.isEmpty) ? '$label wajib diisi' : null;
    String? numValidate(String? v, String label) {
      if (v == null || v.isEmpty) return '$label wajib diisi';
      if (double.tryParse(v) == null) return '$label harus berupa angka';
      return null;
    }

    return [
      AppTextField(
        controller: _kodeController,
        label: 'Kode Kendaraan',
        prefixIcon: Icons.tag,
        validator: (v) => required(v, 'Kode kendaraan'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _merkController,
        label: 'Merk',
        prefixIcon: Icons.branding_watermark_outlined,
        validator: (v) => required(v, 'Merk'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _tipeController,
        label: 'Tipe',
        prefixIcon: Icons.directions_car_outlined,
        validator: (v) => required(v, 'Tipe'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _warnaController,
        label: 'Warna',
        prefixIcon: Icons.palette_outlined,
        validator: (v) => required(v, 'Warna'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _noChasisController,
        label: 'No. Chasis',
        prefixIcon: Icons.numbers,
        validator: (v) => required(v, 'No. Chasis'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _noMesinController,
        label: 'No. Mesin',
        prefixIcon: Icons.engineering_outlined,
        validator: (v) => required(v, 'No. Mesin'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _tahunPerolehanController,
        label: 'Tahun Perolehan',
        keyboardType: TextInputType.number,
        prefixIcon: Icons.calendar_month_outlined,
        validator: (v) => numValidate(v, 'Tahun perolehan'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _tahunPembuatanController,
        label: 'Tahun Pembuatan',
        keyboardType: TextInputType.number,
        prefixIcon: Icons.calendar_today_outlined,
        validator: (v) => numValidate(v, 'Tahun pembuatan'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _hargaController,
        label: 'Harga Perolehan (Rp)',
        keyboardType: TextInputType.number,
        prefixIcon: Icons.attach_money,
        validator: (v) => numValidate(v, 'Harga perolehan'),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _dealerController,
        label: 'Dealer (Opsional)',
        prefixIcon: Icons.store_outlined,
      ),
    ];
  }

  Widget _buildPhotoGridMobile() {
    return Column(
      children: [
        Row(children: [
          Expanded(
            child: PhotoPickerWidget(
              label: 'Foto Depan',
              pickedFile: _fotoDepan,
              existingUrl: widget.existing?.fotoDepan,
              onPhotoResult: (r) => setState(() {
                _fotoDepan = r.hasPicked ? r.file : null;
                _fotoDepanDeleted = r.isDeleted;
              }),
              onChanged: (f) => setState(() => _fotoDepan = f),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PhotoPickerWidget(
              label: 'Foto Kiri',
              pickedFile: _fotoKiri,
              existingUrl: widget.existing?.fotoKiri,
              onPhotoResult: (r) => setState(() {
                _fotoKiri = r.hasPicked ? r.file : null;
                _fotoKiriDeleted = r.isDeleted;
              }),
              onChanged: (f) => setState(() => _fotoKiri = f),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: PhotoPickerWidget(
              label: 'Foto Kanan',
              pickedFile: _fotoKanan,
              existingUrl: widget.existing?.fotoKanan,
              onPhotoResult: (r) => setState(() {
                _fotoKanan = r.hasPicked ? r.file : null;
                _fotoKananDeleted = r.isDeleted;
              }),
              onChanged: (f) => setState(() => _fotoKanan = f),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PhotoPickerWidget(
              label: 'Foto Belakang',
              pickedFile: _fotoBelakang,
              existingUrl: widget.existing?.fotoBelakang,
              onPhotoResult: (r) => setState(() {
                _fotoBelakang = r.hasPicked ? r.file : null;
                _fotoBelakangDeleted = r.isDeleted;
              }),
              onChanged: (f) => setState(() => _fotoBelakang = f),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildPhotoGridDesktop() {
    return Row(
      children: [
        Expanded(
          child: PhotoPickerWidget(
            label: 'Foto Depan',
            pickedFile: _fotoDepan,
            existingUrl: widget.existing?.fotoDepan,
            onPhotoResult: (r) => setState(() {
              _fotoDepan = r.hasPicked ? r.file : null;
              _fotoDepanDeleted = r.isDeleted;
            }),
            onChanged: (f) => setState(() => _fotoDepan = f),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PhotoPickerWidget(
            label: 'Foto Kiri',
            pickedFile: _fotoKiri,
            existingUrl: widget.existing?.fotoKiri,
            onPhotoResult: (r) => setState(() {
              _fotoKiri = r.hasPicked ? r.file : null;
              _fotoKiriDeleted = r.isDeleted;
            }),
            onChanged: (f) => setState(() => _fotoKiri = f),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PhotoPickerWidget(
            label: 'Foto Kanan',
            pickedFile: _fotoKanan,
            existingUrl: widget.existing?.fotoKanan,
            onPhotoResult: (r) => setState(() {
              _fotoKanan = r.hasPicked ? r.file : null;
              _fotoKananDeleted = r.isDeleted;
            }),
            onChanged: (f) => setState(() => _fotoKanan = f),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PhotoPickerWidget(
            label: 'Foto Belakang',
            pickedFile: _fotoBelakang,
            existingUrl: widget.existing?.fotoBelakang,
            onPhotoResult: (r) => setState(() {
              _fotoBelakang = r.hasPicked ? r.file : null;
              _fotoBelakangDeleted = r.isDeleted;
            }),
            onChanged: (f) => setState(() => _fotoBelakang = f),
          ),
        ),
      ],
    );
  }
}
