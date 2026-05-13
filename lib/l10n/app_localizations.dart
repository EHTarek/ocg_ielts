import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OCG IELTS'**
  String get appTitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'OCG IELTS is a comprehensive IELTS preparation app that helps students prepare for the IELTS exam.'**
  String get appDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @brightnessLabel.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightnessLabel;

  /// No description provided for @brightnessLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get brightnessLight;

  /// No description provided for @brightnessDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get brightnessDark;

  /// No description provided for @brightnessSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get brightnessSystem;

  /// No description provided for @accentLabel.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get accentLabel;

  /// No description provided for @paletteIeltsBlue.
  ///
  /// In en, this message translates to:
  /// **'IELTS Blue'**
  String get paletteIeltsBlue;

  /// No description provided for @paletteEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get paletteEmerald;

  /// No description provided for @paletteCrimson.
  ///
  /// In en, this message translates to:
  /// **'Crimson'**
  String get paletteCrimson;

  /// No description provided for @previewSection.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewSection;

  /// No description provided for @previewBody.
  ///
  /// In en, this message translates to:
  /// **'This is how your text will look across the app.'**
  String get previewBody;

  /// No description provided for @previewFilledButton.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get previewFilledButton;

  /// No description provided for @previewOutlinedButton.
  ///
  /// In en, this message translates to:
  /// **'Outlined'**
  String get previewOutlinedButton;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About & Legal'**
  String get aboutSection;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate on Play Store'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @supportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'OCG IELTS — Support request'**
  String get supportEmailSubject;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {build})'**
  String versionLabel(String version, String build);

  /// No description provided for @playerPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get playerPrevious;

  /// No description provided for @playerNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get playerNext;

  /// No description provided for @downloadBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Download the study book'**
  String get downloadBookTitle;

  /// No description provided for @downloadBookMessage.
  ///
  /// In en, this message translates to:
  /// **'The Cambridge guide will be downloaded once and stored on your device. After that you can read it offline.'**
  String get downloadBookMessage;

  /// No description provided for @downloadBookButton.
  ///
  /// In en, this message translates to:
  /// **'Download book'**
  String get downloadBookButton;

  /// No description provided for @downloadingBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading book…'**
  String get downloadingBookTitle;

  /// No description provided for @downloadingBookSize.
  ///
  /// In en, this message translates to:
  /// **'{received} of {total}'**
  String downloadingBookSize(String received, String total);

  /// No description provided for @downloadingBookSizeUnknown.
  ///
  /// In en, this message translates to:
  /// **'{received} downloaded'**
  String downloadingBookSizeUnknown(String received);

  /// No description provided for @downloadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailedTitle;

  /// No description provided for @downloadRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get downloadRetryButton;

  /// No description provided for @downloadInvalidPdf.
  ///
  /// In en, this message translates to:
  /// **'The downloaded file isn\'t a valid PDF. The configured URL may be pointing to an HTML preview or a redirect page instead of the actual book.'**
  String get downloadInvalidPdf;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
