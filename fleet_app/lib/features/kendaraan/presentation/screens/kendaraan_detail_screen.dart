import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/kendaraan_entity.dart';

class KendaraanDetailScreen extends StatelessWidget {
  final KendaraanEntity kendaraan;

  const KendaraanDetailScreen({super.key, required this.kendaraan});

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
                '${kendaraan.merk} ${kendaraan.tipe}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
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
            onPressed: () =>
                context.push('/kendaraan/${kendaraan.id}/edit', extra: kendaraan),
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
        VerticalDivider(
            width: 1, color: Theme.of(context).dividerColor),
        // Panel info kanan
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(context),
                const SizedBox(height: 20),
                _buildPriceBadge(context),
                const SizedBox(height: 20),
                _buildInfoCard(context),
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
    final isTablet =
        MediaQuery.of(context).size.width >= 600;
    final hPad = isTablet ? 24.0 : 16.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full-width foto
          _buildPhotoPanel(context, fill: false),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(context),
                const SizedBox(height: 14),
                _buildPriceBadge(context),
                const SizedBox(height: 14),
                _buildInfoCard(context),
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
      kendaraan.fotoDepan,
      kendaraan.fotoKiri,
      kendaraan.fotoKanan,
      kendaraan.fotoBelakang,
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
                        style: TextStyle(
                            color: AppTheme.textSecondary)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: photos.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
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
                '${kendaraan.merk} ${kendaraan.tipe}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                kendaraan.noChasis,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppTheme.primary.withOpacity(0.3)),
          ),
          child: Text(
            kendaraan.kodeKendaraan,
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
        border:
            Border.all(color: AppTheme.secondary.withOpacity(0.3)),
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
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              Text(
                FormatHelper.currency(kendaraan.hargaPerolehan),
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
            ('Merk', kendaraan.merk, Icons.directions_car_outlined),
            ('Tipe', kendaraan.tipe, Icons.category_outlined),
            ('Warna', kendaraan.warna, Icons.palette_outlined),
            ('Tahun Buat', kendaraan.tahunPembuatan.toString(),
                Icons.calendar_today_outlined),
            ('Tahun Perolehan', kendaraan.tahunPerolehan.toString(),
                Icons.calendar_month_outlined),
            ('No. Chasis', kendaraan.noChasis, Icons.tag),
            ('No. Mesin', kendaraan.noMesin, Icons.engineering_outlined),
            ('Dealer', kendaraan.dealer ?? '-', Icons.store_outlined),
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
                      size: 12,
                      color: AppTheme.primary.withOpacity(0.6)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(item.$1,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11)),
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

  // ─── Related section ─────────────────────────────────────────────────────

  Widget _buildRelatedSection(BuildContext context) {
    final actions = [
      _RelatedItem('Detail', Icons.description_rounded,
          const Color(0xFF4DB6AC),
          '/detail-kendaraan?kendaraan_id=${kendaraan.id}'),
      _RelatedItem('Asuransi', Icons.health_and_safety_rounded,
          AppTheme.success,
          '/asuransi?kendaraan_id=${kendaraan.id}'),
      _RelatedItem('Kejadian', Icons.warning_rounded,
          AppTheme.warning,
          '/kejadian?kendaraan_id=${kendaraan.id}'),
      _RelatedItem('Penyewaan', Icons.assignment_rounded,
          AppTheme.secondary,
          '/penyewaan?kendaraan_id=${kendaraan.id}'),
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
        Row(
          children: actions
              .map((a) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: a == actions.last ? 0 : 8),
                      child: _RelatedButton(item: a),
                    ),
                  ))
              .toList(),
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color)),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
                  color: item.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
