import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../domain/entities/penyewaan_entity.dart';

class PenyewaanDetailScreen extends StatelessWidget {
  final PenyewaanEntity item;

  const PenyewaanDetailScreen({super.key, required this.item});

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
    final selesai = DateTime.tryParse(item.tanggalSelesai);
    final mulai = DateTime.tryParse(item.tanggalMulai);
    final isActive = mulai != null &&
        selesai != null &&
        now.isAfter(mulai) &&
        now.isBefore(selesai);
    final statusColor = isActive ? AppTheme.secondary : AppTheme.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [AppTheme.secondary, const Color(0xFF00BFA5)]
                      : [AppTheme.textSecondary, AppTheme.textSecondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.assignment_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(item.kodePenyewa, overflow: TextOverflow.ellipsis),
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
                context.push('/penyewaan/${item.id}/edit', extra: item),
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
                // Hero Banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.25),
                        AppTheme.secondary.withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isActive
                                ? [AppTheme.secondary, const Color(0xFF00BFA5)]
                                : [
                                    AppTheme.textSecondary,
                                    AppTheme.textSecondary
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.assignment_rounded,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.kodePenyewa,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3)),
                            const SizedBox(height: 4),
                            Text(item.penanggungJawab,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(isActive ? 'Aktif' : 'Selesai',
                                      style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12)),
                                ),
                                if (item.group) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Group',
                                        style: TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Nilai Sewa highlight
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              AppTheme.secondary.withOpacity(0.15),
                              AppTheme.secondary.withOpacity(0.05),
                            ]
                          : [
                              AppTheme.textSecondary.withOpacity(0.1),
                              AppTheme.textSecondary.withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money_rounded,
                          color: AppTheme.secondary, size: 24),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nilai Sewa',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11)),
                          Text(
                            FormatHelper.currency(item.nilaiSewa),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondary),
                          ),
                        ],
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
                        color: AppTheme.secondary.withOpacity(0.04),
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
                                colors: [AppTheme.secondary, AppTheme.primary],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Detail Penyewaan',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoGrid(items: [
                        _InfoItem('Penanggung Jawab', item.penanggungJawab,
                            Icons.person_outline),
                        _InfoItem('Masa Sewa', '${item.masaSewa} hari',
                            Icons.schedule_outlined),
                        _InfoItem(
                            'Tanggal Mulai',
                            FormatHelper.date(item.tanggalMulai),
                            Icons.calendar_today_outlined),
                        _InfoItem(
                            'Tanggal Selesai',
                            FormatHelper.date(item.tanggalSelesai),
                            Icons.calendar_month_outlined),
                        if (item.lokasiSewa != null)
                          _InfoItem('Lokasi Sewa', item.lokasiSewa!,
                              Icons.location_on_outlined),
                        if (item.sales != null)
                          _InfoItem('Sales', item.sales!,
                              Icons.support_agent_outlined),
                      ]),
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
