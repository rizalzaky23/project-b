import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/asuransi_entity.dart';

class AsuransiDetailScreen extends StatelessWidget {
  final AsuransiEntity item;

  const AsuransiDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
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
        title: Text(item.perusahaanAsuransi),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => context.push('/asuransi/${item.id}/edit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 80 : 16,
          vertical: 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto
              if (photos.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => TappablePhoto(
                      imageUrl: photos[i],
                      width: 280,
                      height: 200,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(12),
                      allPhotos: photos.cast<String?>(),
                      initialIndex: i,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.health_and_safety_outlined, size: 64, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.perusahaanAsuransi,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isActive ? 'Aktif' : 'Tidak Aktif',
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.noPolis, style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
                    const SizedBox(height: 20),
                    _InfoGrid(items: [
                      _InfoItem('Jenis Asuransi', item.jenisAsuransi, Icons.category_outlined),
                      _InfoItem('Tanggal Mulai', FormatHelper.date(item.tanggalMulai), Icons.calendar_today_outlined),
                      _InfoItem('Tanggal Akhir', FormatHelper.date(item.tanggalAkhir), Icons.calendar_month_outlined),
                      _InfoItem('No. Polis', item.noPolis, Icons.tag),
                    ]),
                    Divider(height: 28, color: dividerColor),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nilai Premi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                FormatHelper.currency(item.nilaiPremi),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nilai Pertanggungan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                FormatHelper.currency(item.nilaiPertanggungan),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (item.kendaraan != null) ...[
                      Divider(height: 28, color: dividerColor),
                      const Text('Kendaraan', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '${item.kendaraan!['merk'] ?? ''} ${item.kendaraan!['tipe'] ?? ''}'.trim(),
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
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
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
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(item.label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 2),
              Text(item.value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
