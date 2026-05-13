import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocg_ielts/l10n/app_localizations.dart';
import 'models/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    return MaterialApp(
      title: 'OCG IELTS',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(settings.palette, Brightness.light),
      darkTheme: _buildTheme(settings.palette, Brightness.dark),
      themeMode: settings.mode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const SplashScreen(),
    );
  }

  ColorScheme _schemeFor(AppPalette palette, Brightness brightness) {
    if (brightness == Brightness.light) {
      return ColorScheme.fromSeed(
        seedColor: palette.seed,
        brightness: Brightness.light,
      );
    }
    final base = ColorScheme.fromSeed(
      seedColor: palette.seed,
      brightness: Brightness.dark,
      contrastLevel: -0.3,
    );
    return base.copyWith(
      surface: const Color(0xFF1B1C1F),
      onSurface: const Color(0xFFE6E5E9),
      onSurfaceVariant: const Color(0xFFC6C6CC),
      outlineVariant: const Color(0xFF3D3F45),
    );
  }

  ThemeData _buildTheme(AppPalette palette, Brightness brightness) {
    final scheme = _schemeFor(palette, brightness);
    final base = brightness == Brightness.light
        ? ThemeData.light(useMaterial3: true)
        : ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        shadowColor: scheme.shadow,
        surfaceTintColor: scheme.surfaceTint,
        elevation: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onPrimary,
        unselectedLabelColor: scheme.onSurface,
        dividerColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
