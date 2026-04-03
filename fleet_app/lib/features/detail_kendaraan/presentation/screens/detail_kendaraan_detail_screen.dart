import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/detail_kendaraan_entity.dart';

class DetailKendaraanDetailScreen extends StatelessWidget {
  final DetailKendaraanEntity item;
  const DetailKendaraanDetailScreen({super.key, required this.item});

  static const _color = Color(0xFF4DB6AC);
  static const _color2 = Color(0xFF26A69A);

  List<String?> get _photos => [item.fotoStnk, item.fotoBpkb, item.fotoNomor, item.fotoKm]
      .where((p) => p != null && p.isNotEmpty).toList();

  bool get _hasKir =>
      (item.kartuKir != null && item.kartuKir!.isNotEmpty) ||
      (item.lembarKir != null && item.lembarKir!.isNotEmpty) ||
      (item.kirBerlakuMulai != null && item.kirBerlakuMulai!.isNotEmpty) ||
      (item.kirBerlakuAkhir != null && item.kirBerlakuAkhir!.isNotEmpty);

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
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(child: Text(item.noPolisi, overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_outlined, color: AppTheme.primary, size: 18),
            ),
            onPressed: () => context.push('/detail-kendaraan/${item.id}/edit', extra: item),
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
          _buildPlateBadge(), const SizedBox(height: 20),
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
          _buildPlateBadge(), const SizedBox(height: 14),
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
                  child: const Icon(Icons.description_outlined, size: 64, color: _color)),
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
          child: const Center(child: Icon(Icons.description_outlined, size: 72, color: _color)),
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
        Text(item.noPolisi,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(item.namaPemilik,
            style: const TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: _color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20), border: Border.all(color: _color.withOpacity(0.3))),
        child: Text('#${item.id}',
            style: const TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    ]);
  }

  Widget _buildPlateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_color.withOpacity(0.15), _color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: _color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.credit_card_outlined, color: _color, size: 18)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('No. Polisi', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(item.noPolisi, style: const TextStyle(color: _color, fontWeight: FontWeight.w700, fontSize: 15)),
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

        // ── Informasi STNK & BPKB ──
        const _SectionHeader(icon: Icons.credit_card_outlined, label: 'Informasi STNK & BPKB', color: _color),
        const SizedBox(height: 14),
        _InfoGrid(items: [
          _InfoItem('No. Polisi', item.noPolisi, Icons.credit_card_outlined),
          _InfoItem('Nama Pemilik', item.namaPemilik, Icons.person_outline),
          if (item.pemilikKomersial != null && item.pemilikKomersial!.isNotEmpty)
            _InfoItem('Pemilik Komersial', item.pemilikKomersial!, Icons.business_outlined),
          if (item.pemilikFiskal != null && item.pemilikFiskal!.isNotEmpty)
            _InfoItem('Pemilik Fiskal', item.pemilikFiskal!, Icons.account_balance_outlined),
          if (item.createdAt != null)
            _InfoItem('Dibuat', _formatDate(item.createdAt), Icons.access_time_outlined),
        ]),
        // Masa berlaku STNK
        if (item.stnkBerlakuMulai != null || item.stnkBerlakuAkhir != null) ...[
          const SizedBox(height: 14),
          _StnkBerlakuBadge(
            mulai: item.stnkBerlakuMulai,
            akhir: item.stnkBerlakuAkhir,
          ),
        ],

        // ── Foto Dokumen ──
        if (_photos.isNotEmpty) ...[
          Divider(height: 28, color: Theme.of(context).dividerColor),
          const _SectionHeader(icon: Icons.photo_library_outlined, label: 'Dokumen Foto', color: _color),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            if (item.fotoStnk != null && item.fotoStnk!.isNotEmpty) const _DocChip('STNK', _color),
            if (item.fotoBpkb != null && item.fotoBpkb!.isNotEmpty) const _DocChip('BPKB', AppTheme.primary),
            if (item.fotoNomor != null && item.fotoNomor!.isNotEmpty) const _DocChip('Nomor', AppTheme.secondary),
            if (item.fotoKm != null && item.fotoKm!.isNotEmpty) const _DocChip('KM', AppTheme.success),
          ]),
        ],

        // ── Dokumen KIR ──
        if (_hasKir) ...[
          Divider(height: 28, color: Theme.of(context).dividerColor),
          const _SectionHeader(icon: Icons.assignment_outlined, label: 'Dokumen KIR', color: Color(0xFF7B61FF)),
          const SizedBox(height: 10),
          if ((item.kirBerlakuMulai != null && item.kirBerlakuMulai!.isNotEmpty) || (item.kirBerlakuAkhir != null && item.kirBerlakuAkhir!.isNotEmpty)) ...[
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              const Text('Masa Berlaku:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${FormatHelper.date(item.kirBerlakuMulai)} - ${FormatHelper.date(item.kirBerlakuAkhir)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF7B61FF)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
            const SizedBox(height: 12),
          ],
          if (item.kartuKir != null && item.kartuKir!.isNotEmpty)
            _KirDocRow(label: 'Kartu KIR', url: item.kartuKir!),
          if (item.kartuKir != null && item.kartuKir!.isNotEmpty &&
              item.lembarKir != null && item.lembarKir!.isNotEmpty)
            const SizedBox(height: 8),
          if (item.lembarKir != null && item.lembarKir!.isNotEmpty)
            _KirDocRow(label: 'Lembar KIR', url: item.lembarKir!),
        ],

        // ── Kendaraan ref ──
        if (item.kendaraan != null) ...[
          Divider(height: 28, color: Theme.of(context).dividerColor),
          _KendaraanRef(kendaraan: item.kendaraan!),
        ],
      ]),
    );
  }

  String _formatDate(String? raw) => FormatHelper.date(raw);
}


class _StnkBerlakuBadge extends StatelessWidget {
  final String? mulai;
  final String? akhir;
  const _StnkBerlakuBadge({this.mulai, this.akhir});

  static const _teal = Color(0xFF4DB6AC);

  bool _isExpiringSoon(String? akhirStr) {
    if (akhirStr == null) return false;
    try {
      final akhir = DateTime.parse(akhirStr);
      return akhir.difference(DateTime.now()).inDays <= 30;
    } catch (_) { return false; }
  }

  bool _isExpired(String? akhirStr) {
    if (akhirStr == null) return false;
    try {
      return DateTime.parse(akhirStr).isBefore(DateTime.now());
    } catch (_) { return false; }
  }

  @override
  Widget build(BuildContext context) {
    final expired = _isExpired(akhir);
    final expiringSoon = !expired && _isExpiringSoon(akhir);
    final statusColor = expired
        ? AppTheme.error
        : expiringSoon
            ? AppTheme.warning
            : _teal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.event_note_outlined, color: statusColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Masa Berlaku STNK',
              style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(
            '${FormatHelper.date(mulai)}  →  ${FormatHelper.date(akhir)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ])),
        if (expired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Kadaluarsa',
                style: TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.w700)),
          )
        else if (expiringSoon)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Segera Berakhir',
                style: TextStyle(color: AppTheme.warning, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
      ]),
    );
  }
}

class _KirDocRow extends StatelessWidget {
  final String label;
  final String url;
  const _KirDocRow({required this.label, required this.url});

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

class _DocChip extends StatelessWidget {
  final String label; final Color color;
  const _DocChip(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)));
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
