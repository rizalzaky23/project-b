import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/kejadian_entity.dart';

class KejadianDetailScreen extends StatelessWidget {
  final KejadianEntity item;
  const KejadianDetailScreen({super.key, required this.item});

  static const _color = AppTheme.warning;
  static const _color2 = Color(0xFFFFB74D);

  List<String?> get _photos => [item.fotoKm, item.foto1, item.foto2]
      .where((p) => p != null && p.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_color, _color2]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(child: Text('Kejadian ${FormatHelper.date(item.tanggal)}', overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 18),
            ),
            onPressed: () => context.push('/kejadian/${item.id}/edit', extra: item),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: MediaQuery.of(context).size.width * 0.45,
          child: _buildPhotoPanel(context, fill: true)),
      VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTitleRow(), const SizedBox(height: 20),
          _buildDateBadge(), const SizedBox(height: 20),
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
          _buildDateBadge(), const SizedBox(height: 14),
          _buildInfoCard(context), const SizedBox(height: 32),
        ])),
    ]));
  }

  Widget _buildPhotoPanel(BuildContext context, {required bool fill}) {
    final photos = _photos;
    if (fill) {
      return Container(
        height: double.infinity, color: Theme.of(context).colorScheme.surface,
        child: photos.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: _color.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber_outlined, size: 64, color: _color)),
                const SizedBox(height: 16),
                const Text('Belum ada foto', style: TextStyle(color: AppTheme.textSecondary)),
              ]))
            : ListView.separated(padding: const EdgeInsets.all(16), itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: TappablePhoto(imageUrl: photos[i], width: double.infinity, height: 260,
                    fit: BoxFit.cover, borderRadius: BorderRadius.circular(12),
                    allPhotos: photos, initialIndex: i))),
      );
    }
    if (photos.isEmpty) {
      return AspectRatio(aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [
            _color.withOpacity(0.2), _color.withOpacity(0.05)],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: const Center(child: Icon(Icons.warning_amber_outlined, size: 72, color: _color)),
        ));
    }
    return SizedBox(height: 240, child: ListView.separated(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
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
        Text('Kejadian ${FormatHelper.date(item.tanggal)}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('ID #${item.id}',
            style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: _color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20), border: Border.all(color: _color.withOpacity(0.3))),
        child: const Text('Kejadian', style: TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    ]);
  }

  Widget _buildDateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_color.withOpacity(0.15), _color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12), border: Border.all(color: _color.withOpacity(0.3))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.calendar_today_rounded, color: _color, size: 18)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tanggal Kejadian', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(FormatHelper.date(item.tanggal),
              style: const TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
      ]),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [BoxShadow(color: _color.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionHeader(icon: Icons.warning_amber_outlined, label: 'Detail Kejadian', color: _color),
        if (item.deskripsi != null && item.deskripsi!.isNotEmpty) ...[
          const SizedBox(height: 14),
          const Row(children: [
            Icon(Icons.description_outlined, size: 13, color: AppTheme.textSecondary),
            SizedBox(width: 4),
            Text('Deskripsi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _color.withOpacity(0.15))),
            child: Text(item.deskripsi!, style: const TextStyle(fontSize: 14, height: 1.6)),
          ),
        ],
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
          borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Icon(icon, size: 16, color: color), const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    ]);
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
