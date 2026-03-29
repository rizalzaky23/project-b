import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/kendaraan_entity.dart';
import '../bloc/kendaraan_bloc.dart';
import '../widgets/jual_kendaraan_dialog.dart';

class KendaraanDetailScreen extends StatefulWidget {
  final KendaraanEntity kendaraan;

  const KendaraanDetailScreen({super.key, required this.kendaraan});

  @override
  State<KendaraanDetailScreen> createState() => _KendaraanDetailScreenState();
}

class _KendaraanDetailScreenState extends State<KendaraanDetailScreen> {
  late KendaraanEntity _kendaraan;

  @override
  void initState() {
    super.initState();
    _kendaraan = widget.kendaraan;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF8B84FF)]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.directions_car_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                '${_kendaraan.merk} ${_kendaraan.tipe}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (_kendaraan.status != 'Terjual')
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final sold = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => BlocProvider.value(
                      value: context.read<KendaraanBloc>(),
                      child: JualKendaraanDialog(kendaraan: _kendaraan),
                    ),
                  );
                  if (sold == true && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_kendaraan.merk} ${_kendaraan.tipe} berhasil dijual!',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.success,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                    // Refresh list lalu pop kembali ke list kendaraan
                    if (mounted) {
                      context
                          .read<KendaraanBloc>()
                          .add(KendaraanLoadRequested());
                      context.pop();
                    }
                  }
                },
                icon: const Icon(Icons.sell_rounded, size: 16),
                label: const Text('Jual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: AppTheme.primary, size: 18),
            ),
            onPressed: () => context.push('/kendaraan/${_kendaraan.id}/edit',
                extra: _kendaraan),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Full-screen body tanpa padding global — tiap section atur sendiri
      body: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  // ─── Desktop: split photo kiri + info kanan ──────────────────────────────

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel foto kiri, lebar 45%
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: _buildPhotoPanel(context, fill: true),
        ),
        // Divider
        VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
        // Panel info kanan
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(context),
                const SizedBox(height: 20),
                _buildPriceBadge(context),
                const SizedBox(height: 20),
                _buildInfoCard(context),
                const SizedBox(height: 20),
                _buildPaymentCard(context),
                const SizedBox(height: 20),
                _buildRelatedSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Mobile / Tablet: vertikal scroll ────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final hPad = isTablet ? 24.0 : 16.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width foto
          _buildPhotoPanel(context, fill: false),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(context),
                const SizedBox(height: 14),
                _buildPriceBadge(context),
                const SizedBox(height: 14),
                _buildInfoCard(context),
                const SizedBox(height: 14),
                _buildPaymentCard(context),
                const SizedBox(height: 14),
                _buildRelatedSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Photo Panel ──────────────────────────────────────────────────────────

  Widget _buildPhotoPanel(BuildContext context, {required bool fill}) {
    final photos = [
      _kendaraan.fotoDepan,
      _kendaraan.fotoKiri,
      _kendaraan.fotoKanan,
      _kendaraan.fotoBelakang,
    ].where((p) => p != null && p.isNotEmpty).toList();

    if (fill) {
      // Desktop: full height scrollable gallery
      return Container(
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: photos.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_car_outlined,
                          size: 64, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text('Belum ada foto',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: TappablePhoto(
                    imageUrl: photos[i],
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(12),
                    allPhotos: photos.cast<String?>(),
                    initialIndex: i,
                  ),
                ),
              ),
      );
    }

    // Mobile: horizontal scroll dengan aspect ratio
    if (photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withOpacity(0.2),
                AppTheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.directions_car_outlined,
                size: 72, color: AppTheme.primary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) => TappablePhoto(
          imageUrl: photos[i],
          width: MediaQuery.of(ctx).size.width * 0.82,
          height: 240,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(14),
          allPhotos: photos.cast<String?>(),
          initialIndex: i,
        ),
      ),
    );
  }

  // ─── Title row ───────────────────────────────────────────────────────────

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_kendaraan.merk} ${_kendaraan.tipe}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5),
              ),
              if (_kendaraan.status == 'Terjual') ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sell_rounded,
                          size: 14, color: AppTheme.error),
                      const SizedBox(width: 4),
                      Text(
                        'TERJUAL PADA ${FormatHelper.date(_kendaraan.tanggalJual)}',
                        style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                _kendaraan.noChasis,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: Text(
            _kendaraan.kodeKendaraan,
            style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12),
          ),
        ),
      ],
    );
  }

  // ─── Price badge ─────────────────────────────────────────────────────────

  Widget _buildPriceBadge(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary.withOpacity(0.18),
            AppTheme.secondary.withOpacity(0.06),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money_rounded,
              color: AppTheme.secondary, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Harga Perolehan',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              Text(
                FormatHelper.currency(_kendaraan.hargaPerolehan),
                style: const TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Info card ───────────────────────────────────────────────────────────

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.info_outline_rounded,
            label: 'Informasi Kendaraan',
            color: AppTheme.primary,
          ),
          const SizedBox(height: 14),
          _infoGrid([
            ('Merk', _kendaraan.merk, Icons.directions_car_outlined),
            ('Tipe', _kendaraan.tipe, Icons.category_outlined),
            ('Warna', _kendaraan.warna, Icons.palette_outlined),
            (
              'Tahun Buat',
              _kendaraan.tahunPembuatan.toString(),
              Icons.calendar_today_outlined
            ),
            (
              'Tahun Perolehan',
              _kendaraan.tahunPerolehan.toString(),
              Icons.calendar_month_outlined
            ),
            ('No. Rangka', _kendaraan.noChasis, Icons.tag),
            ('No. Mesin', _kendaraan.noMesin, Icons.engineering_outlined),
            ('Dealer', _kendaraan.dealer ?? '-', Icons.store_outlined),
            (
              'Kepemilikan',
              _kendaraan.kepemilikan ?? '-',
              Icons.business_outlined
            ),
            if (_kendaraan.status == 'Terjual') ...[
              (
                'Harga Jual',
                FormatHelper.currency(_kendaraan.hargaJual ?? 0),
                Icons.payments_rounded
              ),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _infoGrid(List<(String, String, IconData)> items) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: items.map((item) {
        return SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.$3,
                      size: 12, color: AppTheme.primary.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(item.$1,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(item.$2,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Payment card ─────────────────────────────────────────────────────────

  Widget _buildPaymentCard(BuildContext context) {
    final hasPembayaran = _kendaraan.jenisPembayaran != null;
    final isCredit = _kendaraan.jenisPembayaran == 'credit';
    final isBank = isCredit && _kendaraan.jenisKredit == 'bank';

    // Helper label
    String pembayaranLabel(String? v) {
      switch (v) {
        case 'cash':
          return 'Cash';
        case 'credit':
          return 'Kredit';
        default:
          return '-';
      }
    }

    String kreditLabel(String? v) {
      switch (v) {
        case 'leasing':
          return 'Leasing';
        case 'bank':
          return 'Bank';
        default:
          return '-';
      }
    }

    Color ptColor(String? pt) {
      switch (pt) {
        case 'PT1':
          return const Color(0xFF6C63FF);
        case 'PT2':
          return const Color(0xFF00C6AE);
        case 'PT3':
          return const Color(0xFFFF8C69);
        default:
          return AppTheme.primary;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
              color: AppTheme.secondary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.payment_outlined,
            label: 'Kepemilikan & Pembayaran',
            color: AppTheme.secondary,
          ),
          const SizedBox(height: 14),

          // Kepemilikan badge
          if (_kendaraan.kepemilikan != null) ...[
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: ptColor(_kendaraan.kepemilikan).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            ptColor(_kendaraan.kepemilikan).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ptColor(_kendaraan.kepemilikan),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _kendaraan.kepemilikan!,
                        style: TextStyle(
                          color: ptColor(_kendaraan.kepemilikan),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          if (!hasPembayaran)
            const Text('Belum ada informasi pembayaran.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))
          else ...[
            _infoGrid([
              (
                'Jenis Pembayaran',
                pembayaranLabel(_kendaraan.jenisPembayaran),
                Icons.payment_outlined
              ),
              if (isCredit)
                (
                  'Jenis Kredit',
                  kreditLabel(_kendaraan.jenisKredit),
                  Icons.account_balance_outlined
                ),
              if (isBank && _kendaraan.tenor != null)
                ('Tenor', '${_kendaraan.tenor} bulan', Icons.timer_outlined),
            ]),

            // Tombol file kontrak
            if (isBank && _kendaraan.fileKontrak != null) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(_kendaraan.fileKontrak!);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFE74C3C).withOpacity(0.4),
                        width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded,
                            color: Color(0xFFE74C3C), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _kendaraan.fileKontrak!.split('/').last,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text('Ketuk untuk membuka PDF kontrak',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.open_in_new_rounded,
                          color: Color(0xFFE74C3C), size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ─── Related section ─────────────────────────────────────────────────────

  Widget _buildRelatedSection(BuildContext context) {
    final actions = [
      _RelatedItem('Detail', Icons.description_rounded, const Color(0xFF4DB6AC),
          '/detail-kendaraan?kendaraan_id=${_kendaraan.id}'),
      _RelatedItem('Asuransi', Icons.health_and_safety_rounded,
          AppTheme.success, '/asuransi?kendaraan_id=${_kendaraan.id}'),
      _RelatedItem('Kejadian', Icons.warning_rounded, AppTheme.warning,
          '/kejadian?kendaraan_id=${_kendaraan.id}'),
      _RelatedItem('Penyewaan', Icons.assignment_rounded, AppTheme.secondary,
          '/penyewaan?kendaraan_id=${_kendaraan.id}'),
      _RelatedItem('Servis', Icons.build_circle_rounded,
          const Color(0xFF7B61FF), '/servis?kendaraan_id=${_kendaraan.id}'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Icons.link_rounded,
          label: 'Data Terkait',
          color: AppTheme.primary,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 90,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (ctx, i) => _RelatedButton(item: actions[i]),
        ),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _RelatedItem {
  final String label, route;
  final IconData icon;
  final Color color;
  const _RelatedItem(this.label, this.icon, this.color, this.route);
}

class _RelatedButton extends StatelessWidget {
  final _RelatedItem item;
  const _RelatedButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: item.color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: item.color, size: 22),
            const SizedBox(height: 5),
            Text(
              item.label,
              style: TextStyle(
                  color: item.color, fontWeight: FontWeight.w600, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
