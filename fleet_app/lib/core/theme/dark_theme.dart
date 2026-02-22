import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.indigo,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF0B0F1A),
  cardColor: const Color(0xFF111318),
  colorScheme: ColorScheme.dark(
    primary: Colors.indigo.shade300,
    secondary: Colors.tealAccent.shade400,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF0E1318),
  ),
);
