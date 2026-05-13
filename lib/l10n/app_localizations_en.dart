// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OCG IELTS';

  @override
  String get appDescription =>
      'OCG IELTS is a comprehensive IELTS preparation app that helps students prepare for the IELTS exam.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get brightnessLabel => 'Brightness';

  @override
  String get brightnessLight => 'Light';

  @override
  String get brightnessDark => 'Dark';

  @override
  String get brightnessSystem => 'System';

  @override
  String get accentLabel => 'Accent colour';

  @override
  String get paletteIeltsBlue => 'IELTS Blue';

  @override
  String get paletteEmerald => 'Emerald';

  @override
  String get paletteCrimson => 'Crimson';

  @override
  String get previewSection => 'Preview';

  @override
  String get previewBody => 'This is how your text will look across the app.';

  @override
  String get previewFilledButton => 'Filled';

  @override
  String get previewOutlinedButton => 'Outlined';

  @override
  String get aboutSection => 'About & Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get rateApp => 'Rate on Play Store';

  @override
  String get shareApp => 'Share App';

  @override
  String get supportEmailSubject => 'OCG IELTS — Support request';

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String versionLabel(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get playerPrevious => 'Previous';

  @override
  String get playerNext => 'Next';

  @override
  String get downloadBookTitle => 'Download the study book';

  @override
  String get downloadBookMessage =>
      'The Cambridge guide will be downloaded once and stored on your device. After that you can read it offline.';

  @override
  String get downloadBookButton => 'Download book';

  @override
  String get downloadingBookTitle => 'Downloading book…';

  @override
  String downloadingBookSize(String received, String total) {
    return '$received of $total';
  }

  @override
  String downloadingBookSizeUnknown(String received) {
    return '$received downloaded';
  }

  @override
  String get downloadFailedTitle => 'Download failed';

  @override
  String get downloadRetryButton => 'Retry';

  @override
  String get downloadInvalidPdf =>
      'The downloaded file isn\'t a valid PDF. The configured URL may be pointing to an HTML preview or a redirect page instead of the actual book.';
}
