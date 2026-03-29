import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/photo_viewer_widget.dart';
import '../../domain/entities/servis_entity.dart';

class ServisDetailScreen extends StatelessWidget {
  final ServisEntity item;
  const ServisDetailScreen({super.key, required this.item});

  bool get _isCredit => item.jenisPembayaran == 'credit';
  Color get _accentColor => _isCredit ? AppTheme.secondary : AppTheme.success;

  List<String> get _photos => [item.fotoInvoice, item.fotoKm]
      .whereType<String>()
      .where((p) => p.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [_accentColor, _accentColor.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.build_circle_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(
              child: Text('Servis ${FormatHelper.date(item.tanggalServis)}',
                  overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.edit_outlined,
                  color: AppTheme.primary, size: 18),
            ),
            onPressed: () =>
                context.push('/servis/${item.id}/edit', extra: item),
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
      Expanded(
          child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTitleRow(),
          const SizedBox(height: 20),
          _buildBadgeRow(context),
          const SizedBox(height: 20),
          _buildInfoCard(context),
          const SizedBox(height: 32),
        ]),
      )),
    ]);
  }

  Widget _buildMobile(BuildContext context) {
    final hPad = MediaQuery.of(context).size.width >= 600 ? 24.0 : 16.0;
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildPhotoPanel(context, fill: false),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTitleRow(),
          const SizedBox(height: 14),
          _buildBadgeRow(context),
          const SizedBox(height: 14),
          _buildInfoCard(context),
          const SizedBox(height: 32),
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
            ? Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(Icons.build_circle_outlined,
                      size: 64, color: _accentColor),
                ),
                const SizedBox(height: 16),
                const Text('Belum ada foto invoice',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ]))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TappablePhoto(
                        imageUrl: photos[i],
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(12),
                        allPhotos: photos,
                        initialIndex: i)),
              ),
      );
    }
    if (photos.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              _accentColor.withOpacity(0.2),
              _accentColor.withOpacity(0.05)
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Center(
                child: Icon(Icons.build_circle_outlined,
                    size: 72, color: _accentColor))),
      );
    }
    return SizedBox(
        height: 240,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: photos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) => TappablePhoto(
              imageUrl: photos[i],
              width: MediaQuery.of(ctx).size.width * 0.82,
              height: 240,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(14),
              allPhotos: photos,
              initialIndex: i),
        ));
  }

  Widget _buildTitleRow() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(FormatHelper.date(item.tanggalServis),
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.speed_outlined, size: 14, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
              '${item.kilometer.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} km',
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ]),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accentColor.withOpacity(0.3))),
        child: Text(_isCredit ? 'Credit' : 'Cash',
            style: TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 12)),
      ),
    ]);
  }

  Widget _buildBadgeRow(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _BadgeBox(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal Servis',
              value: FormatHelper.date(item.tanggalServis),
              color: _accentColor)),
      const SizedBox(width: 12),
      Expanded(
          child: _BadgeBox(
              icon: Icons.speed_outlined,
              label: 'Kilometer',
              value:
                  '${item.kilometer.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} km',
              color: AppTheme.primary)),
    ]);
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
              color: _accentColor.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionHeader(
            icon: Icons.build_circle_outlined,
            label: 'Detail Servis',
            color: _accentColor),
        const SizedBox(height: 14),
        _InfoGrid(items: [
          _InfoItem('Tanggal', FormatHelper.date(item.tanggalServis),
              Icons.calendar_today_outlined),
          _InfoItem(
              'Kilometer',
              '${item.kilometer.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')} km',
              Icons.speed_outlined),
          _InfoItem('Pembayaran', _isCredit ? 'Credit' : 'Cash',
              Icons.payments_outlined),
        ]),

        // Credit section
        if (_isCredit) ...[
          Divider(height: 28, color: Theme.of(context).dividerColor),
          const _SectionHeader(
              icon: Icons.credit_card_outlined,
              label: 'Info Kredit',
              color: AppTheme.secondary),
          const SizedBox(height: 14),
          _InfoGrid(items: [
            if (item.jenisKredit != null)
              _InfoItem(
                  'Jenis',
                  item.jenisKredit!.substring(0, 1).toUpperCase() +
                      item.jenisKredit!.substring(1),
                  Icons.business_outlined),
            if (item.namaBank != null)
              _InfoItem('Nama', item.namaBank!, Icons.account_balance_outlined),
            if (item.tenor != null)
              _InfoItem(
                  'Tenor', '${item.tenor} bulan', Icons.schedule_outlined),
          ]),
          if (item.fileKontrak != null && item.fileKontrak!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _KontrakButton(url: item.fileKontrak!),
          ],
        ],

        // Kendaraan ref
        if (item.kendaraan != null) ...[
          Divider(height: 28, color: Theme.of(context).dividerColor),
          _KendaraanRef(kendaraan: item.kendaraan!),
        ],
      ]),
    );
  }
}

// ─── Shared helper widgets ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionHeader(
      {required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    ]);
  }
}

class _BadgeBox extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _BadgeBox(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ])),
      ]),
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
        spacing: 14,
        runSpacing: 14,
        children: items.map((item) {
          return SizedBox(
              width: 150,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(item.icon,
                          size: 12, color: AppTheme.primary.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Flexible(
                          child: Text(item.label,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11))),
                    ]),
                    const SizedBox(height: 2),
                    Text(item.value,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ]));
        }).toList());
  }
}

class _KontrakButton extends StatelessWidget {
  final String url;
  const _KontrakButton({required this.url});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open URL — in production use url_launcher
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Membuka file kontrak...')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: AppTheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.secondary.withOpacity(0.4))),
        child: const Row(children: [
          Icon(Icons.picture_as_pdf_rounded,
              color: AppTheme.secondary, size: 20),
          SizedBox(width: 10),
          Expanded(
              child: Text('Lihat Kontrak (PDF)',
                  style: TextStyle(
                      color: AppTheme.secondary, fontWeight: FontWeight.w600))),
          Icon(Icons.open_in_new, color: AppTheme.secondary, size: 16),
        ]),
      ),
    );
  }
}

class _KendaraanRef extends StatelessWidget {
  final Map<String, dynamic> kendaraan;
  const _KendaraanRef({required this.kendaraan});
  @override
  Widget build(BuildContext context) {
    final noChasis = kendaraan['no_chasis']?.toString();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.directions_car_outlined,
                color: AppTheme.primary, size: 16)),
        const SizedBox(width: 8),
        const Text('Kendaraan',
            style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
            child: Text(
                '${kendaraan['merk'] ?? ''} ${kendaraan['tipe'] ?? ''}'.trim(),
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis)),
      ]),
      if (noChasis != null && noChasis.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(children: [
          const SizedBox(width: 36),
          const Icon(Icons.numbers, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          const Text('No. Chasis: ',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          Text(noChasis,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ]),
      ],
    ]);
  }
}
