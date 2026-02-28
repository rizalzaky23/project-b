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
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final dividerColor = Theme.of(context).dividerColor;

    final now = DateTime.now();
    final selesai = DateTime.tryParse(item.tanggalSelesai);
    final mulai = DateTime.tryParse(item.tanggalMulai);
    final isActive = mulai != null && selesai != null && now.isAfter(mulai) && now.isBefore(selesai);
    final statusColor = isActive ? AppTheme.secondary : AppTheme.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.kodePenyewa),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => context.push('/penyewaan/${item.id}/edit'),
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
              // Header Banner
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.3),
                      AppTheme.secondary.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_outlined, size: 48, color: AppTheme.primary),
                      const SizedBox(height: 8),
                      Text(
                        item.kodePenyewa,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (item.group)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Group', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
                            item.kodePenyewa,
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
                            isActive ? 'Aktif' : 'Selesai',
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _InfoGrid(items: [
                      _InfoItem('Penanggung Jawab', item.penanggungJawab, Icons.person_outline),
                      _InfoItem('Masa Sewa', '${item.masaSewa} hari', Icons.schedule_outlined),
                      _InfoItem('Tanggal Mulai', FormatHelper.date(item.tanggalMulai), Icons.calendar_today_outlined),
                      _InfoItem('Tanggal Selesai', FormatHelper.date(item.tanggalSelesai), Icons.calendar_month_outlined),
                      if (item.lokasiSewa != null)
                        _InfoItem('Lokasi Sewa', item.lokasiSewa!, Icons.location_on_outlined),
                      if (item.sales != null)
                        _InfoItem('Sales', item.sales!, Icons.support_agent_outlined),
                    ]),
                    Divider(height: 28, color: dividerColor),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          FormatHelper.currency(item.nilaiSewa),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
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
