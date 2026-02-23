import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../domain/entities/kendaraan_entity.dart';

class KendaraanCard extends StatelessWidget {
  final KendaraanEntity kendaraan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KendaraanCard({
    super.key,
    required this.kendaraan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            _buildPhoto(),
            Expanded(child: _buildInfo(context)),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: SizedBox(
        width: 90,
        height: 90,
        child: kendaraan.fotoDepan != null
            ? CachedNetworkImage(
                imageUrl: kendaraan.fotoDepan!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.surfaceVariant),
                errorWidget: (_, __, ___) => _placeholderIcon(),
              )
            : _placeholderIcon(),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: const Icon(Icons.directions_car_outlined, color: AppTheme.textSecondary, size: 32),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${kendaraan.merk} ${kendaraan.tipe}',
            style: const TextStyle(
                color: AppTheme.onSurface, fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            kendaraan.kodeKendaraan,
            style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _InfoChip(label: kendaraan.warna, icon: Icons.palette_outlined),
              const SizedBox(width: 6),
              _InfoChip(label: kendaraan.tahunPembuatan.toString(), icon: Icons.calendar_today_outlined),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            FormatHelper.currency(kendaraan.hargaPerolehan),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.primary),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
            onPressed: onDelete,
            tooltip: 'Hapus',
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppTheme.textSecondary),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
