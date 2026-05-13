# Dependencies

## Internal Dependencies

### Entry point
- **`lib/main.dart`** — Wraps `MyApp` in `ProviderScope`, configures Material 3 theme (seed `#1E3A8A`, secondary `#FACC15`, Poppins via `google_fonts`), installs `AppLocalizations` delegates, and sets `SplashScreen` as `home`.

### Screens (`lib/screens/`)
- **`splash_screen.dart`** — `StatefulWidget` with a 2 s fade `AnimationController`; pushes `LandingScreen` after a 3 s delay.
- **`landing_screen.dart`** — Two-card hub: *Read Study Book* → `PDFViewScreen()` (no asset path; the screen resolves the cached file / downloads on first open); *View Resources* → `ResourcesScreen`.
- **`resources_screen.dart`** — `DefaultTabController` of length 2 with rounded pill `TabBar` (Audio / Video) and a `TabBarView` of `AudioListScreen` + `VideoListScreen`.
- **`audio_list_screen.dart`** — `ConsumerWidget`, watches `audioListProvider`; renders cards that open `AudioPlayerWidget(playlist, initialIndex)` in a modal bottom sheet.
- **`video_list_screen.dart`** — `ConsumerWidget`, watches `videoListProvider`; pushes a full-page `VideoPlayerScreen(playlist, initialIndex)` on tap.
- **`legal_document_screen.dart`** — `StatelessWidget` taking `title` + `body` (long-form text). Used by *Privacy Policy* / *Terms of Service* rows in `SettingsScreen` to surface in-app text instead of launching a browser.
- **`pdf_view_screen.dart`** — `StatefulWidget` that owns a `PdfDownloadState` state machine. Looks for a cached `<applicationDocumentsDirectory>/book.pdf`; if absent, presents a *Download book* button that streams `AppConfig.bookPdfUrl` over `http` and writes it to disk with a determinate progress UI; on success or cache hit, mounts `SfPdfViewer.file(...)` with `PdfViewerController`. AppBar menu still opens `MediaBottomSheet`; two mini FABs call `previousPage()` / `nextPage()` once the viewer is mounted.
- **`video_player_screen.dart`** — Holds the full `playlist` plus the `_currentIndex` it is presently playing; owns `VideoPlayerController.networkUrl(_currentItem.link)` + `ChewieController`; AppBar `actions` expose prev/next `IconButton`s that re-initialise both controllers against the neighbouring list entry; disposes both in `dispose()`.

### Widgets (`lib/widgets/`)
- **`audio_player_widget.dart`** — responsive modal sheet (height grows with content via `SafeArea` + `Column(mainAxisSize.min)`); holds a `playlist` + `_currentIndex`; owns its own `AudioPlayer`, subscribes to `onPlayerStateChanged` / `onDurationChanged` / `onPositionChanged`; slider seek; ±10 s skip buttons; skip-previous / skip-next buttons that swap the source and auto-resume (disabled at boundaries); large play/pause FAB.
- **`media_bottom_sheet.dart`** — `ConsumerWidget` modal (70 % screen height) with the same Audio/Video tabbed list as `ResourcesScreen`, used from inside the PDF reader. Passes the full catalog list + tapped index into the player widgets so prev/next works from inside the PDF flow too.

### Providers (`lib/providers/`)
- **`media_provider.dart`** — Two `FutureProvider<List<MediaItem>>` instances: `audioListProvider` (loads `assets/jsons/audio.json`) and `videoListProvider` (loads `assets/jsons/video.json`). No playback state is held here.
- **`theme_provider.dart`** — `themeSettingsProvider` (`NotifierProvider<ThemeSettingsNotifier, ThemeSettings>`) holds the current brightness mode + accent palette and persists changes via `SharedPreferences`.

### Models (`lib/models/`)
- **`media_item.dart`** — `enum MediaType { audio, video }` and `class MediaItem { int sl; String link; String file; MediaType type; }` with `fromJson` / `toJson`.
- **`app_theme.dart`** — `enum AppPalette { ieltsBlue, emerald, crimson }` exposing the seed `Color` for each preset, and an immutable `ThemeSettings { ThemeMode mode; AppPalette palette; }` value object.

### Localization (`lib/l10n/`)
- **`app_localizations.dart`** + **`app_localizations_en.dart`** — Flutter-generated from `assets/jsons/app_en.arb`. Currently exposes `appTitle` and `appDescription`. Supported locales: `[Locale('en')]`.

### Configuration (`lib/config/`)
- **`app_config.dart`** — Static class `AppConfig` holding store/contact endpoints (`playStoreUrl`, `supportEmail`, `appLegalName`) and content endpoints (`bookPdfUrl`, `bookPdfFileName`). Replace the placeholder constants with real values before shipping to a store. Privacy Policy and Terms of Service text live in `lib/legal/legal_texts.dart` rather than as URLs.

### Legal text (`lib/legal/`)
- **`legal_texts.dart`** — Static class `LegalTexts` exposing two long-form `String` constants (`privacyPolicy`, `termsOfService`). Surfaced in-app by `LegalDocumentScreen`. Kept out of ARB because the bodies are long-form prose; localise by adding sibling files keyed by locale when needed.

### Assets (`assets/`)
- `assets/jsons/audio.json`, `assets/jsons/video.json` — media catalog (Cloudinary URLs).
- `assets/jsons/app_en.arb` — localization source.
- `assets/images/` — icon / image assets.
- *(Note: the study book PDF is no longer bundled; it is downloaded on first open of `PDFViewScreen` and cached under `<applicationDocumentsDirectory>/book.pdf`.)*

## External Dependencies (`pubspec.yaml`)

**Runtime**
- `flutter` (sdk) — UI toolkit.
- `cupertino_icons` ^1.0.8
- `audioplayers` ^6.1.1 — audio streaming.
- `video_player` ^2.9.2 — video playback engine.
- `chewie` ^1.9.0 — UI shell around `video_player`.
- `flutter_riverpod` ^2.6.1 — state / async data loading.
- `google_fonts` ^6.2.1 — Poppins text theme.
- `syncfusion_flutter_pdfviewer` ^28.1.33 — PDF rendering.
- `flutter_localizations` (sdk) + `intl` ^0.20.2 — i18n.
- `shared_preferences` ^2.x — persisted key/value storage for theme settings.
- `package_info_plus` ^8.x — read installed app version / build number for the About section.
- `url_launcher` ^6.x — open external URLs (Privacy/Terms/Play Store/Share) and `mailto:` (Support).
- `path_provider` ^2.x — resolves `<applicationDocumentsDirectory>` where the downloaded PDF is cached.

*Note: the PDF download in `PDFViewScreen` uses `dart:io HttpClient` (no `package:http` dependency) because it auto-follows GitHub's raw → CDN redirect chain and transparently decompresses `Content-Encoding: gzip` responses.*

**Dev**
- `flutter_test` (sdk)
- `flutter_lints` ^6.0.0

**Build / CI**
- GitHub Actions workflow `.github/workflows/release.yml` — on `v*` tag push, runs Flutter 3.41.1 stable, builds release APK, attaches it to a GitHub Release.

## Environment
- **Dart/Flutter SDK constraint:** `^3.11.0`.
- **Android permissions** (per recent commits): internet + media access enabled for release builds.
- **No backend services**, no API keys, no `.env` consumed by the Flutter code.
