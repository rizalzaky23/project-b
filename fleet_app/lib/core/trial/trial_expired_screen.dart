import 'package:flutter/material.dart';
import 'trial_service.dart';
import '../../core/theme/dark_theme.dart';

class TrialExpiredScreen extends StatefulWidget {
  const TrialExpiredScreen({super.key});

  @override
  State<TrialExpiredScreen> createState() => _TrialExpiredScreenState();
}

class _TrialExpiredScreenState extends State<TrialExpiredScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 0.94, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)]
                : [const Color(0xFF1A1A2E), const Color(0xFF6C63FF), const Color(0xFF16213E)],
          ),
        ),
        child: Stack(
          children: [
            // Dekorasi lingkaran latar
            Positioned(top: -80, right: -80,
                child: _DecoCircle(size: 300, opacity: 0.06)),
            Positioned(bottom: -60, left: -60,
                child: _DecoCircle(size: 240, opacity: 0.05)),
            Positioned(top: size.height * 0.35, right: -40,
                child: _DecoCircle(size: 120, opacity: 0.08)),

            // Konten
            FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 80 : 28,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLockIcon(),
                        const SizedBox(height: 32),
                        _buildTitle(),
                        const SizedBox(height: 16),
                        _buildSubtitle(),
                        const SizedBox(height: 40),
                        _buildInfoCard(),
                        const SizedBox(height: 32),
                        _buildContactButton(),
                        const SizedBox(height: 14),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockIcon() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withOpacity(0.35),
              blurRadius: 48,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.lock_clock_rounded, size: 52, color: Colors.white),
            Positioned(
              bottom: 20, right: 20,
              child: Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.close, size: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Masa Trial Habis',
          style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          height: 3, width: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Periode trial ${TrialService.instance.trialDays} hari Anda telah berakhir.\n'
      'Hubungi administrator untuk melanjutkan menggunakan aplikasi ini.',
      style: TextStyle(
          color: Colors.white.withOpacity(0.70),
          fontSize: 15,
          height: 1.65),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.directions_car_rounded,
              label: 'Aplikasi', value: 'Fleet Management'),
          const Divider(color: Colors.white12, height: 20),
          _InfoRow(icon: Icons.timer_outlined,
              label: 'Durasi Trial',
              value: '${TrialService.instance.trialDays} hari'),
          const Divider(color: Colors.white12, height: 20),
          _InfoRow(icon: Icons.highlight_off_rounded,
              label: 'Status',
              value: 'Kadaluarsa',
              valueColor: AppTheme.error),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: ganti dengan URL WhatsApp / email admin
          // launchUrl(Uri.parse('https://wa.me/628xxxxxxxxxx'));
        },
        icon: const Icon(Icons.headset_mic_rounded, size: 20),
        label: const Text('Hubungi Administrator',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'v1.0.0 · Fleet Management',
      style: TextStyle(
          color: Colors.white.withOpacity(0.30), fontSize: 12),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DecoCircle extends StatelessWidget {
  final double size, opacity;
  const _DecoCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
          color: Colors.white.withOpacity(opacity), width: 2),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.55), fontSize: 13)),
        ),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
