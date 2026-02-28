import 'package:flutter/material.dart';

/// Global ValueNotifier untuk mengontrol ThemeMode di seluruh app.
/// Gunakan [themeNotifier.value = ThemeMode.light] untuk ganti tema.
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier(ThemeMode.dark);
