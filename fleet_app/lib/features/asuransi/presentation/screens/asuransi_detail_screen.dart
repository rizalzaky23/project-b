import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/asuransi_entity.dart';

class AsuransiDetailScreen extends StatelessWidget {
  final AsuransiEntity item;
  const AsuransiDetailScreen({super.key, required this.item});

  bool get _isActive {
    final akhir = DateTime.tryParse(item.tanggalAkhir);
    return akhir != null && akhir.isAfter(DateTime.now());
  }
  Color get _statusColor => _isActive ? AppTheme.success : AppTheme.textSecondary;
  List<String?> get _photos => [
    item.fotoDepan, item.fotoKiri, item.fotoKanan,
    item.fotoBelakang, item.fotoDashboard,
  ].where((p) => p != null && p.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _isActive
                  ? [AppTheme.success, const Color(0xFF66BB6A)]
                  : [AppTheme.textSecondary, AppTheme.textSecondary]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(child: Text(item.perusahaanAsuransi, overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 18),
            ),
            onPressed: () => context.push('/asuransi/${item.id}/edit', extra: item),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: _buildPhotoPanel(context, fill: true),
      ),
      VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTitleRow(), const SizedBox(height: 20),
          _buildStatusRow(), const SizedBox(height: 20),
          _buildInfoCard(context), const SizedBox(height: 32),
        ]),
      )),
    ]);
  }

  Widget _buildMobile(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width >= 600 ? 24.0 : 16.0;
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildPhotoPanel(context, fill: false),
      Padding(padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTitleRow(), const SizedBox(height: 14),
          _buildStatusRow(), const SizedBox(height: 14),
          _buildInfoCard(context), const SizedBox(height: 32),
        ]),
      ),
    ]));
  }

  Widget _buildPhotoPanel(BuildContext context, {required bool fill}) {
    final photos = _photos;
    if (fill) {
      return Container(
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: photos.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.health_and_safety_outlined, size: 64, color: _statusColor)),
                const SizedBox(height: 16),
                const Text('Belum ada foto', style: TextStyle(color: AppTheme.textSecondary)),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16), itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: TappablePhoto(imageUrl: photos[i], width: double.infinity, height: 260,
                    fit: BoxFit.cover, borderRadius: BorderRadius.circular(12),
                    allPhotos: photos, initialIndex: i)),
              ),
      );
    }
    if (photos.isEmpty) {
      return AspectRatio(aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [
            _statusColor.withOpacity(0.2), _statusColor.withOpacity(0.05)],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: Center(child: Icon(Icons.health_and_safety_outlined, size: 72, color: _statusColor)),
        ));
    }
    return SizedBox(height: 240, child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: photos.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (ctx, i) => TappablePhoto(imageUrl: photos[i],
        width: MediaQuery.of(ctx).size.width * 0.82, height: 240,
        fit: BoxFit.cover, borderRadius: BorderRadius.circular(14),
        allPhotos: photos, initialIndex: i),
    ));
  }

  Widget _buildTitleRow() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.perusahaanAsuransi,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(item.noPolis,
            style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: _statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20), border: Border.all(color: _statusColor.withOpacity(0.3))),
        child: Text(_isActive ? 'Aktif' : 'Kadaluarsa',
            style: TextStyle(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    ]);
  }

  Widget _buildStatusRow() {
    return Row(children: [
      Expanded(child: _BadgeBox(
        icon: _isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
        label: 'Status', value: _isActive ? 'Aktif' : 'Kadaluarsa', color: _statusColor)),
      const SizedBox(width: 12),
      Expanded(child: _BadgeBox(
        icon: Icons.monetization_on_outlined, label: 'Nilai Pertanggungan',
        value: FormatHelper.currency(item.nilaiPertanggungan), color: AppTheme.secondary)),
    ]);
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [BoxShadow(color: AppTheme.success.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionHeader(icon: Icons.health_and_safety_outlined, label: 'Detail Asuransi', color: AppTheme.success),
        const SizedBox(height: 14),
        _InfoGrid(items: [
          _InfoItem('Perusahaan', item.perusahaanAsuransi, Icons.business_outlined),
          _InfoItem('Jenis', item.jenisAsuransi, Icons.category_outlined),
          _InfoItem('No. Polis', item.noPolis, Icons.tag),
          _InfoItem('Mulai', FormatHelper.date(item.tanggalMulai), Icons.calendar_today_outlined),
          _InfoItem('Akhir', FormatHelper.date(item.tanggalAkhir), Icons.calendar_month_outlined),
          if (item.updatedAt != null)
            _InfoItem('Update Terakhir', FormatHelper.dateTime(item.updatedAt), Icons.update_outlined),
        ]),
        Divider(height: 28, color: Theme.of(context).dividerColor),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Nilai Premi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 2),
            Text(FormatHelper.currency(item.nilaiPremi),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _statusColor)),
          ])),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Nilai Pertanggungan', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 2),
            Text(FormatHelper.currency(item.nilaiPertanggungan),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
          ])),
        ]),
        if (item.kendaraan != null) ...[
          Divider(height: 28, color: Theme.of(context).dividerColor),
          _KendaraanRef(kendaraan: item.kendaraan!),
        ],
      ]),
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _SectionHeader({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 4, height: 20,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.4)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 10),
      Icon(icon, size: 16, color: color), const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    ]);
  }
}

class _BadgeBox extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _BadgeBox({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 20), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
      ]),
    );
  }
}

class _InfoItem { final String label, value; final IconData icon; const _InfoItem(this.label, this.value, this.icon); }

class _InfoGrid extends StatelessWidget {
  final List<_InfoItem> items;
  const _InfoGrid({required this.items});
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 14, runSpacing: 14, children: items.map((item) {
      return SizedBox(width: 150, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(item.icon, size: 12, color: AppTheme.primary.withOpacity(0.6)), const SizedBox(width: 4),
          Flexible(child: Text(item.label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11))),
        ]),
        const SizedBox(height: 2),
        Text(item.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ]));
    }).toList());
  }
}

class _KendaraanRef extends StatelessWidget {
  final Map<String, dynamic> kendaraan;
  const _KendaraanRef({required this.kendaraan});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: const Icon(Icons.directions_car_outlined, color: AppTheme.primary, size: 16)),
      const SizedBox(width: 8),
      const Text('Kendaraan', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(width: 12),
      Expanded(child: Text('${kendaraan['merk'] ?? ''} ${kendaraan['tipe'] ?? ''}'.trim(),
          style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
    ]);
  }
}
