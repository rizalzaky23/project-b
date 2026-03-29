import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/penyewaan_entity.dart';

class PenyewaanDetailScreen extends StatelessWidget {
  final PenyewaanEntity item;
  const PenyewaanDetailScreen({super.key, required this.item});

  bool get _isActive {
    final mulai = DateTime.tryParse(item.tanggalMulai);
    final selesai = DateTime.tryParse(item.tanggalSelesai);
    final now = DateTime.now();
    return mulai != null && selesai != null && now.isAfter(mulai) && now.isBefore(selesai);
  }
  Color get _statusColor => _isActive ? AppTheme.secondary : AppTheme.textSecondary;

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
                  ? [AppTheme.secondary, const Color(0xFF00BFA5)]
                  : [AppTheme.textSecondary, AppTheme.textSecondary]),
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(child: Text(item.namaPenyewa, overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 18),
            ),
            onPressed: () => context.push('/penyewaan/${item.id}/edit', extra: item),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isDesktop ? _buildDesktop(context) : _buildMobile(context),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Sisi kiri: panel hero (penyewaan tidak punya foto, tampilkan info highlight)
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: _buildHeroPanel(context, fill: true),
      ),
      VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTitleRow(), const SizedBox(height: 20),
          _buildNilaiBadge(), const SizedBox(height: 20),
          _buildInfoCard(context), const SizedBox(height: 32),
        ]),
      )),
    ]);
  }

  Widget _buildMobile(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width >= 600 ? 24.0 : 16.0;
    return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHeroPanel(context, fill: false),
      Padding(padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTitleRow(), const SizedBox(height: 14),
          _buildNilaiBadge(), const SizedBox(height: 14),
          _buildInfoCard(context), const SizedBox(height: 32),
        ])),
    ]));
  }

  // Hero panel — karena penyewaan tidak ada foto, tampilkan banner besar
  Widget _buildHeroPanel(BuildContext context, {required bool fill}) {
    final color = _statusColor;
    final gradColors = _isActive
        ? [AppTheme.secondary, const Color(0xFF00BFA5)]
        : [AppTheme.textSecondary, AppTheme.textSecondary];

    if (fill) {
      return Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.primary.withOpacity(0.25), color.withOpacity(0.15),
          ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradColors),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 48, spreadRadius: 4)]),
            child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 72)),
          const SizedBox(height: 24),
          Text(item.namaPenyewa,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(item.penanggungJawab,
              style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 14)),
          const SizedBox(height: 16),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(_isActive ? 'Aktif' : 'Selesai',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13))),
            if (item.group) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Group',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13))),
            ],
          ]),
        ])),
      );
    }

    // Mobile: compact banner
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primary.withOpacity(0.25), color.withOpacity(0.15),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradColors),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
          child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 36)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.namaPenyewa,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text(item.penanggungJawab, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(_isActive ? 'Aktif' : 'Selesai',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11))),
            if (item.group) ...[
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Group',
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 11))),
            ],
          ]),
        ])),
      ]),
    );
  }

  Widget _buildTitleRow() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.namaPenyewa,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(item.penanggungJawab,
            style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: _statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20), border: Border.all(color: _statusColor.withOpacity(0.3))),
        child: Text(_isActive ? 'Aktif' : 'Selesai',
            style: TextStyle(color: _statusColor, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    ]);
  }

  Widget _buildNilaiBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.secondary.withOpacity(0.18), AppTheme.secondary.withOpacity(0.06),
        ], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.attach_money_rounded, color: AppTheme.secondary, size: 22),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nilai Sewa', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(FormatHelper.currency(item.nilaiSewa),
              style: const TextStyle(color: AppTheme.secondary, fontSize: 18, fontWeight: FontWeight.w800)),
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
        boxShadow: [BoxShadow(color: AppTheme.secondary.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionHeader(icon: Icons.assignment_outlined, label: 'Detail Penyewaan', color: AppTheme.secondary),
        const SizedBox(height: 14),
        _InfoGrid(items: [
          _InfoItem('Penanggung Jawab', item.penanggungJawab, Icons.person_outline),
          _InfoItem('Masa Sewa', '${item.masaSewa} hari', Icons.schedule_outlined),
          _InfoItem('Tanggal Mulai', FormatHelper.date(item.tanggalMulai), Icons.calendar_today_outlined),
          _InfoItem('Tanggal Selesai', FormatHelper.date(item.tanggalSelesai), Icons.calendar_month_outlined),
          if (item.lokasiSewa != null) _InfoItem('Lokasi', item.lokasiSewa!, Icons.location_on_outlined),
        ]),
        if (item.suratPerjanjian != null && item.suratPerjanjian!.isNotEmpty) ...[
          Divider(height: 28, color: Theme.of(context).dividerColor),
          const _SectionHeader(icon: Icons.assignment_outlined, label: 'Dokumen Perjanjian', color: Color(0xFF7B61FF)),
          const SizedBox(height: 10),
          _PdfDocRow(label: 'Surat Perjanjian', url: item.suratPerjanjian!),
        ],
        if (item.kendaraan != null) ...[
          Divider(height: 28, color: Theme.of(context).dividerColor),
          _KendaraanRef(kendaraan: item.kendaraan!),
        ],
      ]),
    );
  }
}

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

class _PdfDocRow extends StatelessWidget {
  final String label;
  final String url;
  const _PdfDocRow({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final fileName = Uri.tryParse(url)?.pathSegments.lastOrNull ?? 'dokumen.pdf';
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF7B61FF).withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF7B61FF).withOpacity(0.25)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFE74C3C), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(fileName, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF7B61FF)),
        ]),
      ),
    );
  }
}
