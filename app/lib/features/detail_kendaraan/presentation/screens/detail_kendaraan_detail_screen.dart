import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/detail_kendaraan_entity.dart';

class DetailKendaraanDetailScreen extends StatelessWidget {
  final DetailKendaraanEntity item;

  const DetailKendaraanDetailScreen({super.key, required this.item});

  static const _tealColor = Color(0xFF4DB6AC);
  static const _tealDark = Color(0xFF26A69A);

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

    final photos = [
      item.fotoStnk,
      item.fotoBpkb,
      item.fotoNomor,
      item.fotoKm,
    ].where((p) => p != null && p.isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_tealColor, _tealDark],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(item.noPolisi, overflow: TextOverflow.ellipsis),
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
                context.push('/detail-kendaraan/${item.id}/edit', extra: item),
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
                          _tealColor.withOpacity(0.2),
                          _tealColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _tealColor.withOpacity(0.25)),
                    ),
                    child: const Center(
                      child: Icon(Icons.description_outlined,
                          size: 72, color: _tealColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Plate & ID badges
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            _tealColor.withOpacity(0.15),
                            _tealColor.withOpacity(0.05),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _tealColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _tealColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.credit_card_outlined,
                                  color: _tealColor, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('No. Polisi',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                                Text(item.noPolisi,
                                    style: const TextStyle(
                                        color: _tealColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppTheme.primary.withOpacity(0.15),
                          AppTheme.primary.withOpacity(0.05),
                        ]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ID',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11)),
                          Text('#${item.id}',
                              style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)),
                        ],
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
                        color: _tealColor.withOpacity(0.04),
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
                                colors: [_tealColor, AppTheme.primary],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Informasi STNK & BPKB',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoGrid(items: [
                        _InfoItem('No. Polisi', item.noPolisi,
                            Icons.credit_card_outlined),
                        _InfoItem('Nama Pemilik', item.namaPemilik,
                            Icons.person_outline),
                        _InfoItem(
                            'Berlaku Mulai',
                            FormatHelper.date(item.berlakuMulai),
                            Icons.calendar_today_outlined),
                        _InfoItem('Dibuat', FormatHelper.date(item.createdAt),
                            Icons.access_time_outlined),
                      ]),

                      // Photo type labels
                      if (photos.isNotEmpty) ...[
                        Divider(height: 28, color: dividerColor),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _tealColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.photo_library_outlined,
                                  color: _tealColor, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Text('Dokumen Foto',
                                style: TextStyle(
                                    color: _tealColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (item.fotoStnk != null &&
                                item.fotoStnk!.isNotEmpty)
                              const _DocChip('STNK', _tealColor),
                            if (item.fotoBpkb != null &&
                                item.fotoBpkb!.isNotEmpty)
                              const _DocChip('BPKB', AppTheme.primary),
                            if (item.fotoNomor != null &&
                                item.fotoNomor!.isNotEmpty)
                              const _DocChip('Nomor', AppTheme.secondary),
                            if (item.fotoKm != null && item.fotoKm!.isNotEmpty)
                              const _DocChip('KM', AppTheme.success),
                          ],
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

class _DocChip extends StatelessWidget {
  final String label;
  final Color color;
  const _DocChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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
