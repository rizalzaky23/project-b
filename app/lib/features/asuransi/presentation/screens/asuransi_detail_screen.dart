import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/asuransi_entity.dart';

class AsuransiDetailScreen extends StatelessWidget {
  final AsuransiEntity item;

  const AsuransiDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final hPad = isDesktop
        ? 80.0
        : isTablet
            ? 32.0
            : 16.0;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final dividerColor = Theme.of(context).dividerColor;

    final now = DateTime.now();
    final akhir = DateTime.tryParse(item.tanggalAkhir);
    final isActive = akhir != null && akhir.isAfter(now);
    final statusColor = isActive ? AppTheme.success : AppTheme.textSecondary;

    final photos = [
      item.fotoDepan,
      item.fotoKiri,
      item.fotoKanan,
      item.fotoBelakang,
      item.fotoDashboard,
      item.fotoKm,
    ].where((p) => p != null && p.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [AppTheme.success, const Color(0xFF66BB6A)]
                      : [AppTheme.textSecondary, AppTheme.textSecondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.health_and_safety_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(item.perusahaanAsuransi,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: AppTheme.primary, size: 18),
            ),
            onPressed: () =>
                context.push('/asuransi/${item.id}/edit', extra: item),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto
                if (photos.isNotEmpty) ...[
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) => TappablePhoto(
                        imageUrl: photos[i],
                        width: 300,
                        height: 220,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(16),
                        allPhotos: photos.cast<String?>(),
                        initialIndex: i,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withOpacity(0.2),
                          statusColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Center(
                      child: Icon(Icons.health_and_safety_outlined,
                          size: 72, color: statusColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Status & Harga row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            statusColor.withOpacity(0.15),
                            statusColor.withOpacity(0.05),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: statusColor,
                                size: 22),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Status',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                                Text(isActive ? 'Aktif' : 'Kadaluarsa',
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppTheme.secondary.withOpacity(0.15),
                            AppTheme.secondary.withOpacity(0.05),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.secondary.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nilai Pertanggungan',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                            Text(
                              FormatHelper.currency(item.nilaiPertanggungan),
                              style: const TextStyle(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    AppTheme.success,
                                    AppTheme.secondary,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Detail Asuransi',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item.noPolis,
                          style: const TextStyle(
                              color: AppTheme.primary, fontSize: 12)),
                      const SizedBox(height: 16),
                      _InfoGrid(items: [
                        _InfoItem('Perusahaan', item.perusahaanAsuransi,
                            Icons.business_outlined),
                        _InfoItem('Jenis Asuransi', item.jenisAsuransi,
                            Icons.category_outlined),
                        _InfoItem('Mulai', FormatHelper.date(item.tanggalMulai),
                            Icons.calendar_today_outlined),
                        _InfoItem('Akhir', FormatHelper.date(item.tanggalAkhir),
                            Icons.calendar_month_outlined),
                        _InfoItem('No. Polis', item.noPolis, Icons.tag),
                      ]),
                      Divider(height: 28, color: dividerColor),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nilai Premi',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  FormatHelper.currency(item.nilaiPremi),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Nilai Pertanggungan',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  FormatHelper.currency(
                                      item.nilaiPertanggungan),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (item.kendaraan != null) ...[
                        Divider(height: 28, color: dividerColor),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.directions_car_outlined,
                                  color: AppTheme.primary, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Text('Kendaraan',
                                style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.kendaraan!['merk'] ?? ''} ${item.kendaraan!['tipe'] ?? ''}'
                              .trim(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label, value;
  final IconData icon;
  const _InfoItem(this.label, this.value, this.icon);
}

class _InfoGrid extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 14,
      children: items.map((item) {
        return SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon,
                      size: 13, color: AppTheme.primary.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(item.label,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 3),
              Text(item.value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
