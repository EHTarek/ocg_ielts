# Components

All paths are relative to `lib/`.

## 1. Entry & Theming
- **`main.dart`** — `void main()` wraps `MyApp` in `ProviderScope`. `MyApp` is a `ConsumerWidget` returning `MaterialApp` with:
  - `title` = `AppLocalizations.of(context)!.appTitle` ("OCG IELTS").
  - Theme: Material 3, seed comes from `settings.palette.seed`, Poppins text theme. Both `theme` and `darkTheme` are built by a single `_buildTheme(palette, brightness)` helper.
  - `_schemeFor(palette, brightness)`: `ColorScheme.fromSeed(seedColor, brightness)` for light. For dark, the same call with `contrastLevel: -0.3` then `.copyWith(surface: 0xFF1B1C1F, onSurface: 0xFFE6E5E9, onSurfaceVariant: 0xFFC6C6CC)` — milder near-black instead of pure dark + neon primary. **No hard-coded `secondary` override** — every tone follows the seed, so palette switching re-tints the whole scheme.
  - Component themes wired so widgets read scheme tokens by default: `appBarTheme` (`surface` bg, `onSurface` icons, `centerTitle: true`), `cardTheme` (`surfaceContainerHigh` bg, scheme-derived `shadowColor`), `tabBarTheme` (label/indicator/divider from scheme), `bottomSheetTheme` (`surface` bg), `iconTheme` (`onSurface`).
  - Localization delegates: `AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`.
  - `supportedLocales: [Locale('en')]`.
  - `home: SplashScreen()`.

## 2. Navigation Screens
- **`screens/splash_screen.dart` — `SplashScreen`** (`StatefulWidget` + `SingleTickerProviderStateMixin`)
  - 2 s `AnimationController` + `CurvedAnimation(easeIn)` powering a `FadeTransition`.
  - `Future.delayed(Duration(seconds: 3))` then `Navigator.pushReplacement` to `LandingScreen` (guarded by `mounted`).
  - UI: circular white icon container with `Icons.auto_stories` and the title "The Official Cambridge Guide to IELTS" on the blue background.
- **`screens/landing_screen.dart` — `LandingScreen`** (`StatelessWidget`)
  - AppBar with a single trailing `IconButton(Icons.settings)` → `Navigator.push(SettingsScreen)`.
  - Body: a `Column` of two `_buildOptionCard` cards.
  - Card 1: "Read Study Book" / "Digital version of the Official Guide" → `PDFViewScreen()` (no asset path — the screen resolves the cached file / download URL itself).
  - Card 2: "View Resources" / "Audio and Video practice materials" → `ResourcesScreen`.
- **`screens/settings_screen.dart` — `SettingsScreen`** (`ConsumerWidget`)
  - Section 1 — *Appearance*: brightness segmented control (Light / Dark / System) + palette swatch row (3 presets) + live preview card.
  - Section 2 — *About & Legal*: a `Card` of `ListTile`s for *Privacy Policy*, *Terms of Service*, *Open Source Licenses*, *Contact Support*, *Rate on Play Store*, *Share App*; a footer showing the app name + `<version> (<build>)` resolved at runtime via `package_info_plus`.
  - Reads `themeSettingsProvider` for appearance state and `packageInfoProvider` (a `FutureProvider<PackageInfo>`) for version metadata.
  - *Privacy Policy* and *Terms of Service* push an in-app `LegalDocumentScreen` populated from `LegalTexts.privacyPolicy` / `LegalTexts.termsOfService` — these no longer leave the app to a browser.
  - *Rate on Play Store* / *Share App* still route through `url_launcher`; *Contact Support* opens a `mailto:`; *Open Source Licenses* calls Flutter's built-in `showLicensePage()`.
  - If `launchUrl` returns `false` for any reason (no browser / mail client installed), a `SnackBar` with `couldNotOpenLink` is shown.
- **`screens/legal_document_screen.dart` — `LegalDocumentScreen`** (`StatelessWidget`, required `String title`, `String body`)
  - AppBar with the passed title; body is a single `SafeArea` + `SingleChildScrollView` containing a `SelectableText` so the user can copy paragraphs.
  - Uses Poppins (`GoogleFonts`) with `height: 1.55` line-height and `colorScheme.onSurface` so it re-tints with the active theme/palette.
- **`screens/resources_screen.dart` — `ResourcesScreen`** (`StatelessWidget`)
  - `DefaultTabController(length: 2)` with a custom rounded-pill `TabBar` ("Audio" / "Video") in the AppBar.
  - Body: `TabBarView(children: [AudioListScreen(), VideoListScreen()])`.

## 3. Media List Screens
- **`screens/audio_list_screen.dart` — `AudioListScreen`** (`ConsumerWidget`)
  - `ref.watch(audioListProvider).when(data, loading, error)`.
  - `data` → `ListView.builder` of cards (`Icons.audiotrack`, title `Track ${item.sl}`, subtitle `item.file`, `play_circle_fill` trailing).
  - On tap: `showModalBottomSheet` rendering `AudioPlayerWidget(playlist: audioList, initialIndex: index)`.
- **`screens/video_list_screen.dart` — `VideoListScreen`** (`ConsumerWidget`)
  - Same shape as `AudioListScreen` but `Icons.movie_outlined`, title `Lesson ${item.sl}`, and `Navigator.push` to `VideoPlayerScreen(playlist: videoList, initialIndex: index)`.

## 4. Player Screens / Widgets
- **`screens/pdf_view_screen.dart` — `PDFViewScreen`** (`StatefulWidget`, no required parameters)
  - Owns `PdfViewerController`, `GlobalKey<SfPdfViewerState>`, a `PdfDownloadState` enum (`checking`, `needsDownload`, `downloading`, `ready`, `error`), the resolved `File? _localFile`, and per-download `_received` / `_total` byte counters.
  - `initState()` → `_resolve()`: builds `<applicationDocumentsDirectory>/book.pdf`; if the file exists with non-zero length, transitions straight to `ready`. Otherwise transitions to `needsDownload`.
  - `_startDownload()`: streams `AppConfig.bookPdfUrl` (raw GitHub URL) via `http.Client.send(http.Request('GET', uri))`, writes chunks to a `.part` file beside the target, updates `_received` / `_total` on every chunk, and on completion renames `.part` → `book.pdf` and transitions to `ready`. On error: deletes the `.part`, sets `_error`, transitions to `error`.
  - Body renders one of: a centred progress card during `checking`, an info card with a *Download book* `FilledButton` during `needsDownload`, a determinate `LinearProgressIndicator` + `<received MB> / <total MB>` text during `downloading`, an error card with a *Retry* `FilledButton.tonal` during `error`, or `SfPdfViewer.file(_localFile!, controller: _pdfViewerController, key: _pdfViewerKey, interactionMode: PdfInteractionMode.pan)` during `ready`.
  - AppBar action: menu `IconButton` → `showModalBottomSheet(builder: => MediaBottomSheet())` (always available).
  - `floatingActionButton`: two mini FABs (`heroTag: 'prev'/'next'`) only mounted in the `ready` state.
  - Cancels any in-flight `http.StreamSubscription` and closes the file sink in `dispose()`.
- **`screens/video_player_screen.dart` — `VideoPlayerScreen`** (`StatefulWidget`, required `List<MediaItem> playlist`, `int initialIndex`)
  - Holds `int _currentIndex` (starts at `initialIndex`); `MediaItem get _currentItem => widget.playlist[_currentIndex]`.
  - `initState()` → `_initializePlayer()`: creates `VideoPlayerController.networkUrl(Uri.parse(_currentItem.link))`, awaits `initialize()`, then builds `ChewieController(autoPlay: true, looping: false, aspectRatio: <video aspectRatio>, materialProgressColors: red/grey/white70, autoInitialize: true)` and calls `setState`.
  - AppBar `actions`: two `IconButton`s (`Icons.skip_previous`, `Icons.skip_next`) wired to `_goToIndex(_currentIndex - 1)` / `_goToIndex(_currentIndex + 1)`. Each button is disabled (`onPressed: null`) at the corresponding list boundary.
  - `_goToIndex(int)` disposes the existing `_videoPlayerController` + `_chewieController`, nulls `_chewieController` to re-show the spinner, sets `_currentIndex`, and re-runs `_initializePlayer()`.
  - Black scaffold, transparent AppBar with white icon theme.
  - `dispose()` releases both controllers.
- **`widgets/audio_player_widget.dart` — `AudioPlayerWidget`** (`StatefulWidget`, required `List<MediaItem> playlist`, `int initialIndex`)
  - Holds `int _currentIndex`, one `AudioPlayer`, and three subscriptions: `onPlayerStateChanged`, `onDurationChanged`, `onPositionChanged` (each updates a local state field). `MediaItem get _currentItem => widget.playlist[_currentIndex]`.
  - `_initAudio()` calls `_audioPlayer.setSourceUrl(_currentItem.link)`.
  - Responsive modal sheet (no fixed height — wraps `SafeArea(top: false)` + `Padding` + `Column(mainAxisSize: MainAxisSize.min)` so the sheet grows to fit its content and respects the bottom system inset). Contents: drag handle, "Track ${sl}" title, file-name subtitle (2-line ellipsis), `Slider` (clamped to `[0, duration]`), formatted position/duration labels (`MM:SS`), and a button row: `skip_previous` / `replay_10` / large play-pause FAB / `forward_10` / `skip_next`. Play FAB triggers `audioPlayer.play(UrlSource(_currentItem.link))` if not currently playing, else `.pause()`.
  - `_goToIndex(int)` stops the current player, resets `_position` and `_duration`, sets `_currentIndex`, then `setSourceUrl(...) + play(...)` so the new track auto-resumes. Prev/next buttons are disabled at list boundaries.

## 5. Shared Widget
- **`widgets/media_bottom_sheet.dart` — `MediaBottomSheet`** (`ConsumerWidget`)
  - 70 % screen-height sheet with the same rounded-pill `TabBar` ("Audio" / "Video") as `ResourcesScreen`.
  - Two private inner `ConsumerWidget`s (`_AudioListTab`, `_VideoListTab`) replicate the catalog list pattern. Tapping an audio entry stacks another modal sheet with `AudioPlayerWidget(playlist: audioList, initialIndex: index)`; tapping a video pushes `VideoPlayerScreen(playlist: videoList, initialIndex: index)`.

## 6. State & Models
- **`providers/media_provider.dart`**
  - `audioListProvider` — `FutureProvider<List<MediaItem>>` that loads `assets/jsons/audio.json`, decodes JSON, maps to `MediaItem.fromJson`.
  - `videoListProvider` — same as above with `assets/jsons/video.json`.
- **`providers/theme_provider.dart`**
  - `themeSettingsProvider` — `NotifierProvider<ThemeSettingsNotifier, ThemeSettings>`. Hydrates from `SharedPreferences` on first read; exposes `setMode(ThemeMode)` and `setPalette(AppPalette)`, both of which persist immediately.
- **`models/media_item.dart`**
  - `enum MediaType { audio, video }`.
  - `class MediaItem` with `int sl`, `String link`, `String file`, `MediaType type`, plus `fromJson` and `toJson`. Type round-trips as the string `'audio'` or `'video'`.
- **`models/app_theme.dart`**
  - `enum AppPalette { ieltsBlue, emerald, crimson }` with a `seed` getter returning the Material seed `Color`.
  - `class ThemeSettings { ThemeMode mode; AppPalette palette; }` (immutable, with `copyWith`).

## 8. Configuration
- **`config/app_config.dart`** — Compile-time constants for store / content endpoints:
  - `playStoreUrl` — used by *Rate on Play Store* and *Share App*.
  - `supportEmail` — used by *Contact Support*.
  - `bookPdfUrl` — the raw `https://raw.githubusercontent.com/EHTarek/resources/main/book.pdf` from which `PDFViewScreen` downloads the study book on first open.
  - `bookPdfFileName` — `'book.pdf'`, the name used both for the on-disk cache and as a default display name.
  - `appLegalName` — long-form name used in `showLicensePage()`.
  - **Note:** *Privacy Policy* and *Terms of Service* are no longer URL-based; their long-form text lives in `lib/legal/legal_texts.dart`.

## 7. Localization
- **`l10n/app_localizations.dart`** (generated) + **`l10n/app_localizations_en.dart`** — currently exposes only `appTitle` and `appDescription`.
- ARB source: `assets/jsons/app_en.arb`.
- `l10n.yaml` at repo root drives generation.
