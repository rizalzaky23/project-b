import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../shared/widgets/network_image_widget.dart';
import '../../domain/entities/kendaraan_entity.dart';

class KendaraanDetailScreen extends StatelessWidget {
  final KendaraanEntity kendaraan;

  const KendaraanDetailScreen({super.key, required this.kendaraan});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Text('${kendaraan.merk} ${kendaraan.tipe}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
            onPressed: () => context.push('/kendaraan/${kendaraan.id}/edit'),
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
              _buildPhotos(context),
              const SizedBox(height: 24),
              _buildInfoSection(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotos(BuildContext context) {
    final photos = [
      kendaraan.fotoDepan,
      kendaraan.fotoKiri,
      kendaraan.fotoKanan,
      kendaraan.fotoBelakang,
    ].where((p) => p != null && p.isNotEmpty).toList();

    if (photos.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.directions_car_outlined, size: 64, color: AppTheme.textSecondary),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => NetworkImageWidget(
          imageUrl: photos[i],
          width: 280,
          height: 200,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${kendaraan.merk} ${kendaraan.tipe}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  kendaraan.kodeKendaraan,
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoGrid([
            ('Warna', kendaraan.warna, Icons.palette_outlined),
            ('Tahun Pembuatan', kendaraan.tahunPembuatan.toString(), Icons.calendar_today_outlined),
            ('Tahun Perolehan', kendaraan.tahunPerolehan.toString(), Icons.calendar_month_outlined),
            ('No. Chasis', kendaraan.noChasis, Icons.tag),
            ('No. Mesin', kendaraan.noMesin, Icons.engineering_outlined),
            ('Dealer', kendaraan.dealer ?? '-', Icons.store_outlined),
          ]),
          const Divider(height: 28, color: AppTheme.divider),
          Row(
            children: [
              const Icon(Icons.attach_money, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(
                FormatHelper.currency(kendaraan.hargaPerolehan),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoGrid(List<(String, String, IconData)> items) {
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
                  Icon(item.$3, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(item.$1, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 2),
              Text(item.$2,
                  style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Terkait',
            style: TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ActionButton(
              label: 'Detail',
              icon: Icons.info_outline,
              onTap: () => context.push('/detail-kendaraan?kendaraan_id=${kendaraan.id}'),
            ),
            _ActionButton(
              label: 'Asuransi',
              icon: Icons.health_and_safety_outlined,
              onTap: () => context.push('/asuransi?kendaraan_id=${kendaraan.id}'),
            ),
            _ActionButton(
              label: 'Kejadian',
              icon: Icons.report_problem_outlined,
              onTap: () => context.push('/kejadian?kendaraan_id=${kendaraan.id}'),
            ),
            _ActionButton(
              label: 'Penyewaan',
              icon: Icons.assignment_outlined,
              onTap: () => context.push('/penyewaan?kendaraan_id=${kendaraan.id}'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
