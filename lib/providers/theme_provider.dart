import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

const _kModeKey = 'theme_mode';
const _kPaletteKey = 'theme_palette';

class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    _hydrate();
    return const ThemeSettings();
  }

  Future<void> _hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    state = ThemeSettings(
      mode: themeModeFromName(prefs.getString(_kModeKey)),
      palette: AppPalette.fromName(prefs.getString(_kPaletteKey)),
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kModeKey, mode.name);
  }

  Future<void> setPalette(AppPalette palette) async {
    state = state.copyWith(palette: palette);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPaletteKey, palette.name);
  }
}

final themeSettingsProvider =
    NotifierProvider<ThemeSettingsNotifier, ThemeSettings>(ThemeSettingsNotifier.new);
