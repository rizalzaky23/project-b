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
    // Ambil lebar layar untuk scaling
    final screenWidth = MediaQuery.of(context).size.width;

    // Breakpoint: phone kecil < 360, normal 360–599, tablet >= 600
    final isSmallPhone = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    final double cardHeight = isTablet
        ? 120
        : isSmallPhone
            ? 90
            : 106;
    final double photoWidth = isTablet
        ? 130
        : isSmallPhone
            ? 80
            : 110;
    final double titleFontSize = isTablet
        ? 15
        : isSmallPhone
            ? 12
            : 14;
    final double subFontSize = isTablet
        ? 13
        : isSmallPhone
            ? 10
            : 12;
    final double chipFontSize = isTablet
        ? 12
        : isSmallPhone
            ? 9
            : 11;
    final double iconSize = isTablet ? 22 : 20;

    return GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildPhoto(photoWidth, cardHeight),
                  Expanded(
                    child: _buildInfo(
                      context,
                      titleFontSize: titleFontSize,
                      subFontSize: subFontSize,
                      chipFontSize: chipFontSize,
                    ),
                  ),
                  _buildActions(context, iconSize: iconSize),
                ],
              ),
              // Badge ID
              Positioned(
                top: -13,
                right: -13,
                child: Container(
                  constraints: BoxConstraints(minWidth: isTablet ? 60 : 52),
                  height: isTablet ? 30 : 26,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppTheme.surface, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'ID = ${kendaraan.id}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 11 : 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto(double width, double height) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: kendaraan.fotoDepan != null
            ? CachedNetworkImage(
                imageUrl: kendaraan.fotoDepan!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppTheme.surfaceVariant),
                errorWidget: (_, __, ___) => _placeholderIcon(),
              )
            : _placeholderIcon(),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: const Icon(Icons.directions_car_outlined,
          color: AppTheme.textSecondary, size: 36),
    );
  }

  Widget _buildInfo(
    BuildContext context, {
    required double titleFontSize,
    required double subFontSize,
    required double chipFontSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${kendaraan.merk} ${kendaraan.tipe}',
            style: TextStyle(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: titleFontSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            kendaraan.noChasis,
            style: TextStyle(
              color: AppTheme.primary,
              fontSize: subFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: _InfoChip(
                  label: kendaraan.warna,
                  icon: Icons.palette_outlined,
                  fontSize: chipFontSize,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: _InfoChip(
                  label: kendaraan.tahunPembuatan.toString(),
                  icon: Icons.calendar_today_outlined,
                  fontSize: chipFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            FormatHelper.currency(kendaraan.hargaPerolehan),
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: subFontSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, {required double iconSize}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: iconSize, color: AppTheme.primary),
            onPressed: onEdit,
            tooltip: 'Edit',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 6),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: iconSize, color: AppTheme.error),
            onPressed: onDelete,
            tooltip: 'Hapus',
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final double fontSize;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.fontSize,
  });

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
          Icon(icon, size: fontSize - 1, color: AppTheme.textSecondary),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: fontSize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
