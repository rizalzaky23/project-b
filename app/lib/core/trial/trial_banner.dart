import 'package:flutter/material.dart';
import 'trial_service.dart';
import '../../core/theme/dark_theme.dart';

/// Widget banner yang tampil di bagian bawah layar selama trial aktif.
/// Menampilkan sisa hari + progress bar.
/// Letakkan sebagai bottomNavigationBar atau di Stack di atas scaffold.
class TrialBanner extends StatefulWidget {
  const TrialBanner({super.key});

  @override
  State<TrialBanner> createState() => _TrialBannerState();
}

class _TrialBannerState extends State<TrialBanner> {
  int _remainingDays = 0;
  double _usedFraction = 0;
  bool _dismissed = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final days = await TrialService.instance.getRemainingDays();
    final frac = await TrialService.instance.getUsedFraction();
    if (mounted) {
      setState(() {
        _remainingDays = days;
        _usedFraction = frac;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _dismissed) return const SizedBox.shrink();

    // Warna berdasarkan urgensi
    final Color barColor;
    final Color bgColor;
    if (_remainingDays <= 3) {
      barColor = AppTheme.error;
      bgColor = AppTheme.error.withOpacity(0.12);
    } else if (_remainingDays <= 7) {
      barColor = AppTheme.warning;
      bgColor = AppTheme.warning.withOpacity(0.10);
    } else {
      barColor = AppTheme.primary;
      bgColor = AppTheme.primary.withOpacity(0.08);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: barColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: barColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _remainingDays <= 0
                      ? 'Trial Anda telah habis'
                      : 'Trial: $_remainingDays hari tersisa',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _dismissed = true),
                child: Icon(Icons.close, size: 14,
                    color: barColor.withOpacity(0.6)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _usedFraction,
              backgroundColor: barColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
