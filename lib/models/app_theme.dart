import 'package:flutter/material.dart';

enum AppPalette {
  ieltsBlue(Color(0xFF1E3A8A), 'IELTS Blue'),
  emerald(Color(0xFF047857), 'Emerald'),
  crimson(Color(0xFFBE123C), 'Crimson');

  const AppPalette(this.seed, this.label);

  final Color seed;
  final String label;

  static AppPalette fromName(String? name) {
    return AppPalette.values.firstWhere(
      (p) => p.name == name,
      orElse: () => AppPalette.ieltsBlue,
    );
  }
}

@immutable
class ThemeSettings {
  final ThemeMode mode;
  final AppPalette palette;

  const ThemeSettings({this.mode = ThemeMode.system, this.palette = AppPalette.ieltsBlue});

  ThemeSettings copyWith({ThemeMode? mode, AppPalette? palette}) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
    );
  }
}

ThemeMode themeModeFromName(String? name) {
  switch (name) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}
