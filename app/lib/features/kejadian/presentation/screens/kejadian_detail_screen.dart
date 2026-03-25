import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/kejadian_entity.dart';

class KejadianDetailScreen extends StatelessWidget {
  final KejadianEntity item;

  const KejadianDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600 && size.width < 1024;
    final isDesktop = size.width >= 1024;
    final hPad = isDesktop ? 80.0 : isTablet ? 32.0 : 16.0;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final dividerColor = Theme.of(context).dividerColor;

    final photos = [item.fotoKm, item.foto1, item.foto2]
        .where((p) => p != null && p.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.warning, Color(0xFFFFB74D)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Kejadian ${FormatHelper.date(item.tanggal)}',
                overflow: TextOverflow.ellipsis,
              ),
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
            onPressed: () => context.push('/kejadian/${item.id}/edit', extra: item),
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
                        AppTheme.warning.withOpacity(0.2),
                        AppTheme.warning.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.warning.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Icon(Icons.warning_amber_outlined,
                        size: 72, color: AppTheme.warning),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Date badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.warning.withOpacity(0.15),
                    AppTheme.warning.withOpacity(0.05),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today_rounded,
                          color: AppTheme.warning, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tanggal Kejadian',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11)),
                        Text(
                          FormatHelper.date(item.tanggal),
                          style: const TextStyle(
                              color: AppTheme.warning,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Kejadian',
                          style: TextStyle(
                              color: AppTheme.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 12)),
                    ),
                  ],
                ),
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
                      color: AppTheme.warning.withOpacity(0.04),
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
                          width: 4, height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.warning, Color(0xFFFFB74D)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Detail Kejadian',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (item.deskripsi != null &&
                        item.deskripsi!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Divider(color: dividerColor),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 14,
                              color: AppTheme.textSecondary),
                          SizedBox(width: 4),
                          Text('Deskripsi',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.warning.withOpacity(0.15)),
                        ),
                        child: Text(item.deskripsi!,
                            style: const TextStyle(
                                fontSize: 14, height: 1.6)),
                      ),
                    ],
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
