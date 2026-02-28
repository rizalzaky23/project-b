import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/kejadian_entity.dart';

class KejadianDetailScreen extends StatelessWidget {
  final KejadianEntity item;

  const KejadianDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final dividerColor = Theme.of(context).dividerColor;

    final photos = [
      item.fotoKm,
      item.foto1,
      item.foto2,
    ].where((p) => p != null && p.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Kejadian ${FormatHelper.date(item.tanggal)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => context.push('/kejadian/${item.id}/edit'),
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
                    child: Icon(Icons.warning_amber_outlined, size: 64, color: AppTheme.warning),
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
                          FormatHelper.date(item.tanggal),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Kejadian',
                            style: TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(color: dividerColor),
                      const SizedBox(height: 12),
                      const Text('Deskripsi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(item.deskripsi!, style: const TextStyle(fontSize: 14, height: 1.5)),
                    ],
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
