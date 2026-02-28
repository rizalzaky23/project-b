import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/detail_kendaraan_entity.dart';

class DetailKendaraanDetailScreen extends StatelessWidget {
  final DetailKendaraanEntity item;

  const DetailKendaraanDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceColor = colorScheme.surface;
    final dividerColor = Theme.of(context).dividerColor;

    final photos = [
      item.fotoStnk,
      item.fotoBpkb,
      item.fotoNomor,
      item.fotoKm,
    ].where((p) => p != null && p.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(item.noPolisi),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => context.push('/detail-kendaraan/${item.id}/edit'),
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
                    child: Icon(Icons.description_outlined, size: 64, color: AppTheme.textSecondary),
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
                      children: [
                        Text(
                          item.noPolisi,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${item.id}',
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InfoGrid(items: [
                      _InfoItem('No. Polisi', item.noPolisi, Icons.credit_card_outlined),
                      _InfoItem('Nama Pemilik', item.namaPemilik, Icons.person_outline),
                      _InfoItem('Berlaku Mulai', FormatHelper.date(item.berlakuMulai), Icons.calendar_today_outlined),
                      _InfoItem('Dibuat', FormatHelper.date(item.createdAt), Icons.access_time_outlined),
                    ]),
                    if (item.kendaraan != null) ...[
                      Divider(height: 28, color: dividerColor),
                      Text(
                        'Kendaraan',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
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
