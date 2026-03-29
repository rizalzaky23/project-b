import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  late final TextEditingController _tenorController;

  // ── Dropdowns ────────────────────────────────────────────────
  String? _selectedKepemilikan;
  String? _selectedJenisPembayaran; // 'cash' | 'credit'
  String? _selectedJenisKredit;     // 'leasing' | 'bank'

  // ── File kontrak PDF — XFile dari file_selector ───────────────
  XFile? _fileKontrak;
  bool   _fileKontrakDeleted = false;

  // ── Foto kendaraan ────────────────────────────────────────────
  XFile? _fotoDepan, _fotoKiri, _fotoKanan, _fotoBelakang;
  bool _fotoDepanDeleted    = false;
  bool _fotoKiriDeleted     = false;
  bool _fotoKananDeleted    = false;
  bool _fotoBelakangDeleted = false;

  static const List<String> _ptOptions = ['PT1', 'PT2', 'PT3'];

  bool get _isEdit   => widget.existing != null;
  bool get _isCredit => _selectedJenisPembayaran == 'credit';
  bool get _isBank   => _isCredit && _selectedJenisKredit == 'bank';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kodeController           = TextEditingController(text: e?.kodeKendaraan ?? '');
    _merkController           = TextEditingController(text: e?.merk ?? '');
    _tipeController           = TextEditingController(text: e?.tipe ?? '');
    _warnaController          = TextEditingController(text: e?.warna ?? '');
    _noChasisController       = TextEditingController(text: e?.noChasis ?? '');
    _noMesinController        = TextEditingController(text: e?.noMesin ?? '');
    _tahunPerolehanController = TextEditingController(text: e?.tahunPerolehan.toString() ?? '');
    _tahunPembuatanController = TextEditingController(text: e?.tahunPembuatan.toString() ?? '');
    _hargaController          = TextEditingController(text: e?.hargaPerolehan.toStringAsFixed(0) ?? '');
    _tenorController          = TextEditingController(text: e?.tenor?.toString() ?? '');
    _selectedKepemilikan      = e?.kepemilikan;
    _selectedJenisPembayaran  = e?.jenisPembayaran;
    _selectedJenisKredit      = e?.jenisKredit;
  }

  @override
  void dispose() {
    for (final c in [
      _kodeController, _merkController, _tipeController, _warnaController,
      _noChasisController, _noMesinController, _tahunPerolehanController,
      _tahunPembuatanController, _hargaController, _tenorController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Pilih PDF kontrak (file_selector — works on web & macOS) ──
  Future<void> _pickPdf() async {
    try {
      const typeGroup = XTypeGroup(
        label: 'PDF',
        extensions: ['pdf'],
        mimeTypes: ['application/pdf'],
        uniformTypeIdentifiers: ['com.adobe.pdf'],
      );
      final file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        setState(() {
          _fileKontrak        = file;
          _fileKontrakDeleted = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal memilih file: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }

  void _removePdf() {
    setState(() {
      _fileKontrak        = null;
      _fileKontrakDeleted = true;
    });
  }

  // ── Submit ────────────────────────────────────────────────────
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final jenisKredit = _isCredit ? _selectedJenisKredit : null;
    final tenor       = _isBank   ? int.tryParse(_tenorController.text) : null;
    final kontrakFile = _isBank   ? _fileKontrak : null;
    final kontrakDel  = _isBank   ? _fileKontrakDeleted : false;

    final bloc = context.read<KendaraanBloc>();
    if (_isEdit) {
      bloc.add(KendaraanUpdateRequested(
        id:               widget.existing!.id,
        kodeKendaraan:    _kodeController.text,
        merk:             _merkController.text,
        tipe:             _tipeController.text,
        warna:            _warnaController.text,
        noChasis:         _noChasisController.text,
        noMesin:          _noMesinController.text,
        tahunPerolehan:   int.parse(_tahunPerolehanController.text),
        tahunPembuatan:   int.parse(_tahunPembuatanController.text),
        hargaPerolehan:   double.parse(_hargaController.text),
        kepemilikan:      _selectedKepemilikan,
        jenisPembayaran:  _selectedJenisPembayaran,
        jenisKredit:      jenisKredit,
        tenor:            tenor,
        fileKontrak:      kontrakFile,
        fileKontrakDeleted: kontrakDel,
        fotoDepan: _fotoDepan, fotoKiri: _fotoKiri,
        fotoKanan: _fotoKanan, fotoBelakang: _fotoBelakang,
        fotoDepanDeleted:    _fotoDepanDeleted,
        fotoKiriDeleted:     _fotoKiriDeleted,
        fotoKananDeleted:    _fotoKananDeleted,
        fotoBelakangDeleted: _fotoBelakangDeleted,
      ));
    } else {
      bloc.add(KendaraanCreateRequested(
        kodeKendaraan:   _kodeController.text,
        merk:            _merkController.text,
        tipe:            _tipeController.text,
        warna:           _warnaController.text,
        noChasis:        _noChasisController.text,
        noMesin:         _noMesinController.text,
        tahunPerolehan:  int.parse(_tahunPerolehanController.text),
        tahunPembuatan:  int.parse(_tahunPembuatanController.text),
        hargaPerolehan:  double.parse(_hargaController.text),
        kepemilikan:     _selectedKepemilikan,
        jenisPembayaran: _selectedJenisPembayaran,
        jenisKredit:     jenisKredit,
        tenor:           tenor,
        fileKontrak:     kontrakFile,
        fotoDepan: _fotoDepan, fotoKiri: _fotoKiri,
        fotoKanan: _fotoKanan, fotoBelakang: _fotoBelakang,
      ));
    }
  }

  // ── Build ─────────────────────────────────────────────────────
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
        Expanded(
          flex: 50,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Foto Kendaraan'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _photoCard('Foto Depan', _fotoDepan, widget.existing?.fotoDepan,
                    (r) => setState(() { _fotoDepan = r.hasPicked ? r.file : null; _fotoDepanDeleted = r.isDeleted; }),
                    (f) => setState(() => _fotoDepan = f))),
                const SizedBox(width: 12),
                Expanded(child: _photoCard('Foto Kiri', _fotoKiri, widget.existing?.fotoKiri,
                    (r) => setState(() { _fotoKiri = r.hasPicked ? r.file : null; _fotoKiriDeleted = r.isDeleted; }),
                    (f) => setState(() => _fotoKiri = f))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _photoCard('Foto Kanan', _fotoKanan, widget.existing?.fotoKanan,
                    (r) => setState(() { _fotoKanan = r.hasPicked ? r.file : null; _fotoKananDeleted = r.isDeleted; }),
                    (f) => setState(() => _fotoKanan = f))),
                const SizedBox(width: 12),
                Expanded(child: _photoCard('Foto Belakang', _fotoBelakang, widget.existing?.fotoBelakang,
                    (r) => setState(() { _fotoBelakang = r.hasPicked ? r.file : null; _fotoBelakangDeleted = r.isDeleted; }),
                    (f) => setState(() => _fotoBelakang = f))),
              ]),
            ]),
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
            Expanded(child: _photoCard('Foto Depan', _fotoDepan, widget.existing?.fotoDepan,
                (r) => setState(() { _fotoDepan = r.hasPicked ? r.file : null; _fotoDepanDeleted = r.isDeleted; }),
                (f) => setState(() => _fotoDepan = f))),
            const SizedBox(width: 12),
            Expanded(child: _photoCard('Foto Kiri', _fotoKiri, widget.existing?.fotoKiri,
                (r) => setState(() { _fotoKiri = r.hasPicked ? r.file : null; _fotoKiriDeleted = r.isDeleted; }),
                (f) => setState(() => _fotoKiri = f))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _photoCard('Foto Kanan', _fotoKanan, widget.existing?.fotoKanan,
                (r) => setState(() { _fotoKanan = r.hasPicked ? r.file : null; _fotoKananDeleted = r.isDeleted; }),
                (f) => setState(() => _fotoKanan = f))),
            const SizedBox(width: 12),
            Expanded(child: _photoCard('Foto Belakang', _fotoBelakang, widget.existing?.fotoBelakang,
                (r) => setState(() { _fotoBelakang = r.hasPicked ? r.file : null; _fotoBelakangDeleted = r.isDeleted; }),
                (f) => setState(() => _fotoBelakang = f))),
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

  Widget _photoCard(
    String label, XFile? file, String? url,
    void Function(PhotoResult) onResult, void Function(XFile?) onChanged,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
      const SizedBox(height: 6),
      AspectRatio(
        aspectRatio: 4 / 3,
        child: PhotoPickerWidget(
          label: '', pickedFile: file, existingUrl: url,
          onPhotoResult: onResult, onChanged: onChanged, hideLabel: true,
        ),
      ),
    ]);
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(
        color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
  );

  Widget _buildDesktopFormGrid() {
    final fields = _buildFormFields().where((w) => w is! SizedBox).toList();
    final rows = <Widget>[];
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

  Widget _dropdown<T>({
    required String label,
    required IconData icon,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(
          color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items,
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _buildKontrakPicker() {
    final hasExistingUrl = widget.existing?.fileKontrak != null && !_fileKontrakDeleted;
    final hasNewFile     = _fileKontrak != null;
    final hasFile        = hasNewFile || hasExistingUrl;
    final displayName    = hasNewFile
        ? _fileKontrak!.name
        : hasExistingUrl
            ? widget.existing!.fileKontrak!.split('/').last
            : null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('File Kontrak (PDF)',
          style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      if (!hasFile)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _pickPdf,
            icon: const Icon(Icons.upload_file_outlined, size: 20),
            label: const Text('Upload PDF Kontrak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: const BorderSide(color: AppTheme.divider),
              backgroundColor: AppTheme.surfaceVariant,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        )
      else
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFE74C3C), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  displayName ?? 'kontrak.pdf',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text('PDF kontrak terlampir',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ]),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              color: AppTheme.primary,
              onPressed: _pickPdf,
              tooltip: 'Ganti PDF',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppTheme.error,
              onPressed: _removePdf,
              tooltip: 'Hapus PDF',
            ),
          ]),
        ),
    ]);
  }

  Color _ptColor(String pt) {
    switch (pt) {
      case 'PT1': return const Color(0xFF6C63FF);
      case 'PT2': return const Color(0xFF00C6AE);
      case 'PT3': return const Color(0xFFFF8C69);
      default:    return AppTheme.primary;
    }
  }

  List<Widget> _buildFormFields() {
    String? req(String? v, String l) =>
        (v == null || v.isEmpty) ? '$l wajib diisi' : null;
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
      AppTextField(controller: _noChasisController, label: 'No. Rangka',
          prefixIcon: Icons.numbers, validator: (v) => req(v, 'No. Rangka')),
      const SizedBox(height: 16),
      AppTextField(controller: _noMesinController, label: 'No. Mesin',
          prefixIcon: Icons.engineering_outlined, validator: (v) => req(v, 'No. Mesin')),
      const SizedBox(height: 16),
      AppTextField(controller: _tahunPerolehanController, label: 'Tahun Perolehan',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.calendar_month_outlined,
          validator: (v) => num(v, 'Tahun perolehan')),
      const SizedBox(height: 16),
      AppTextField(controller: _tahunPembuatanController, label: 'Tahun Pembuatan',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.calendar_today_outlined,
          validator: (v) => num(v, 'Tahun pembuatan')),
      const SizedBox(height: 16),
      AppTextField(controller: _hargaController, label: 'Harga Perolehan (Rp)',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.attach_money,
          validator: (v) => num(v, 'Harga perolehan')),
      const SizedBox(height: 16),

      // ── Kepemilikan ─────────────────────────────────────────
      _dropdown<String>(
        label: 'Kepemilikan', icon: Icons.business_outlined,
        hint: 'Pilih kepemilikan', value: _selectedKepemilikan,
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('— Tidak dipilih —')),
          ..._ptOptions.map((pt) => DropdownMenuItem<String>(
            value: pt,
            child: Row(children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(color: _ptColor(pt), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(pt),
            ]),
          )),
        ],
        onChanged: (v) => setState(() => _selectedKepemilikan = v),
      ),
      const SizedBox(height: 16),

      // ── Jenis Pembayaran ─────────────────────────────────────
      _dropdown<String>(
        label: 'Jenis Pembayaran', icon: Icons.payment_outlined,
        hint: 'Pilih jenis pembayaran', value: _selectedJenisPembayaran,
        items: const [
          DropdownMenuItem<String>(value: null,     child: Text('— Tidak dipilih —')),
          DropdownMenuItem<String>(value: 'cash',   child: Text('Cash')),
          DropdownMenuItem<String>(value: 'credit', child: Text('Credit')),
        ],
        onChanged: (v) => setState(() {
          _selectedJenisPembayaran = v;
          if (v != 'credit') {
            _selectedJenisKredit = null;
            _tenorController.clear();
            _fileKontrak        = null;
            _fileKontrakDeleted = false;
          }
        }),
      ),

      // ── Credit section (animated expand) ────────────────────
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: _isCredit ? _buildCreditSection() : const SizedBox.shrink(),
      ),
    ];
  }

  Widget _buildCreditSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _dropdown<String>(
                label: 'Jenis Kredit', icon: Icons.account_balance_outlined,
                hint: 'Pilih jenis kredit', value: _selectedJenisKredit,
                items: const [
                  DropdownMenuItem<String>(value: null,      child: Text('— Tidak dipilih —')),
                  DropdownMenuItem<String>(value: 'leasing', child: Text('Leasing')),
                  DropdownMenuItem<String>(value: 'bank',    child: Text('Bank')),
                ],
                onChanged: (v) => setState(() {
                  _selectedJenisKredit = v;
                  if (v != 'bank') {
                    _tenorController.clear();
                    _fileKontrak        = null;
                    _fileKontrakDeleted = false;
                  }
                }),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isBank
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _tenorController,
                          label: 'Tenor (bulan)',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.timer_outlined,
                          validator: (v) {
                            if (_isBank) {
                              if (v == null || v.isEmpty) return 'Tenor wajib diisi';
                              final n = int.tryParse(v);
                              if (n == null || n < 1 || n > 360) return 'Tenor 1–360 bulan';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildKontrakPicker(),
                      ])
                    : const SizedBox.shrink(),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}