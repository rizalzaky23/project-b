import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dark_theme.dart';
import '../../../../shared/utils/format_helper.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/kendaraan_entity.dart';

class KendaraanCard extends StatefulWidget {
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
  State<KendaraanCard> createState() => _KendaraanCardState();
}

class _KendaraanCardState extends State<KendaraanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  bool get _isSold => widget.kendaraan.status == 'Terjual';

  // Warna aksen berdasarkan status
  Color get _accentColor => _isSold ? AppTheme.error : AppTheme.success;
  Color get _borderColor => _isSold
      ? AppTheme.error.withOpacity(0.35)
      : AppTheme.primary.withOpacity(0.18);

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Opacity(
          // Kendaraan terjual sedikit diredupkan
          opacity: _isSold ? 0.72 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _borderColor,
                width: _isSold ? 1.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isSold
                      ? AppTheme.error.withOpacity(isDark ? 0.08 : 0.05)
                      : AppTheme.primary.withOpacity(isDark ? 0.08 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoSection(),
                  _buildInfoSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Stack(
      children: [
        // Foto kendaraan
        AspectRatio(
          aspectRatio: 16 / 9,
          child: widget.kendaraan.fotoDepan != null
              ? CachedNetworkImage(
                  imageUrl: widget.kendaraan.fotoDepan!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _photoPlaceholder(),
                  errorWidget: (_, __, ___) => _photoPlaceholder(),
                )
              : _photoPlaceholder(),
        ),

        // Overlay gelap tipis untuk kendaraan terjual
        if (_isSold)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.45),
                  ],
                ),
              ),
            ),
          ),

        // Status badge bottom-right — selalu tampil di semua card
        Positioned(
          bottom: 8,
          right: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.kendaraan.isRented) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE65100)
                        .withOpacity(0.92), // Orange for Rented
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE65100).withOpacity(0.45),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 11,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Sedang Disewa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _isSold
                      ? AppTheme.error.withOpacity(0.92)
                      : AppTheme.success.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isSold ? AppTheme.error : AppTheme.success)
                          .withOpacity(0.45),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSold ? Icons.sell_rounded : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isSold ? 'Terjual' : 'Tersedia',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ID badge top-right
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _isSold ? AppTheme.error : AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (_isSold ? AppTheme.error : AppTheme.primary)
                      .withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'ID ${widget.kendaraan.id}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        // Kode kendaraan bottom-left
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.kendaraan.kodeKendaraan,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Kepemilikan badge top-left (jika ada)
        if (widget.kendaraan.kepemilikan != null)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _ptColor(widget.kendaraan.kepemilikan!),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _ptColor(widget.kendaraan.kepemilikan!)
                        .withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.kendaraan.kepemilikan!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _ptColor(String pt) {
    switch (pt) {
      case 'PT1':
        return const Color(0xFF6C63FF);
      case 'PT2':
        return const Color(0xFF00C6AE);
      case 'PT3':
        return const Color(0xFFFF8C69);
      default:
        return AppTheme.primary;
    }
  }

  Widget _photoPlaceholder() {
    return Container(
      color: AppTheme.surfaceVariant,
      child: Center(
        child: Icon(
          _isSold ? Icons.no_crash_rounded : Icons.directions_car_outlined,
          color: _isSold
              ? AppTheme.error.withOpacity(0.4)
              : AppTheme.textSecondary,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nama kendaraan + actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${widget.kendaraan.merk} ${widget.kendaraan.tipe}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                    color: _isSold ? AppTheme.textSecondary : null,
                    decoration: _isSold ? TextDecoration.lineThrough : null,
                    decorationColor: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Builder(builder: (context) {
                final authState = context.read<AuthBloc>().state;
                final isAdmin = authState is AuthAuthenticated &&
                    authState.user.role == 'admin';

                if (!isAdmin) return const SizedBox.shrink();

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: widget.onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 14, color: AppTheme.primary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.delete_outline,
                            size: 14, color: AppTheme.error),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 4),

          // No. Chasis
          Text(
            widget.kendaraan.noChasis,
            style: TextStyle(
                color: _isSold
                    ? AppTheme.textSecondary.withOpacity(0.7)
                    : AppTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),

          // Warna & Tahun chips
          Row(
            children: [
              _Chip(
                icon: Icons.palette_outlined,
                label: widget.kendaraan.warna,
                isSold: _isSold,
              ),
              const SizedBox(width: 6),
              _Chip(
                icon: Icons.calendar_today_outlined,
                label: widget.kendaraan.tahunPembuatan.toString(),
                isSold: _isSold,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Baris bawah: harga perolehan / tanggal jual
          if (_isSold && widget.kendaraan.tanggalJual != null)
            Row(
              children: [
                Icon(Icons.sell_rounded,
                    size: 11, color: AppTheme.error.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text(
                  'Terjual ${FormatHelper.date(widget.kendaraan.tanggalJual)}',
                  style: TextStyle(
                    color: AppTheme.error.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.kendaraan.hargaJual != null) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      FormatHelper.currency(widget.kendaraan.hargaJual!),
                      style: TextStyle(
                        color: AppTheme.error.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            )
          else
            Text(
              FormatHelper.currency(widget.kendaraan.hargaPerolehan),
              style: const TextStyle(
                color: AppTheme.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSold;

  const _Chip({required this.icon, required this.label, this.isSold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isSold
            ? AppTheme.textSecondary.withOpacity(0.08)
            : AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSold
              ? AppTheme.textSecondary.withOpacity(0.12)
              : AppTheme.primary.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 10,
              color: isSold ? AppTheme.textSecondary : AppTheme.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
