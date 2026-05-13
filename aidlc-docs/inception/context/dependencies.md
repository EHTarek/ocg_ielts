# Dependencies

## Internal Dependencies

### Entry point
- **`lib/main.dart`** — Wraps `MyApp` in `ProviderScope`, configures Material 3 theme (seed `#1E3A8A`, secondary `#FACC15`, Poppins via `google_fonts`), installs `AppLocalizations` delegates, and sets `SplashScreen` as `home`.

### Screens (`lib/screens/`)
- **`splash_screen.dart`** — `StatefulWidget` with a 2 s fade `AnimationController`; pushes `LandingScreen` after a 3 s delay.
- **`landing_screen.dart`** — Two-card hub: *Read Study Book* → `PDFViewScreen(assetPath: 'assets/pdfs/book.pdf')`; *View Resources* → `ResourcesScreen`.
- **`resources_screen.dart`** — `DefaultTabController` of length 2 with rounded pill `TabBar` (Audio / Video) and a `TabBarView` of `AudioListScreen` + `VideoListScreen`.
- **`audio_list_screen.dart`** — `ConsumerWidget`, watches `audioListProvider`; renders cards that open `AudioPlayerWidget` in a modal bottom sheet.
- **`video_list_screen.dart`** — `ConsumerWidget`, watches `videoListProvider`; pushes a full-page `VideoPlayerScreen` on tap.
- **`pdf_view_screen.dart`** — `StatefulWidget` hosting `SfPdfViewer.asset` with `PdfViewerController`; AppBar menu opens `MediaBottomSheet`; two mini FABs call `previousPage()` / `nextPage()`.
- **`video_player_screen.dart`** — Owns `VideoPlayerController.networkUrl(item.link)` + `ChewieController`; disposes both in `dispose()`.

### Widgets (`lib/widgets/`)
- **`audio_player_widget.dart`** — 350 px modal sheet; owns its own `AudioPlayer`, subscribes to `onPlayerStateChanged` / `onDurationChanged` / `onPositionChanged`; slider seek; ±10 s skip buttons; large play/pause FAB.
- **`media_bottom_sheet.dart`** — `ConsumerWidget` modal (70 % screen height) with the same Audio/Video tabbed list as `ResourcesScreen`, used from inside the PDF reader.

### Providers (`lib/providers/`)
- **`media_provider.dart`** — Two `FutureProvider<List<MediaItem>>` instances: `audioListProvider` (loads `assets/jsons/audio.json`) and `videoListProvider` (loads `assets/jsons/video.json`). No playback state is held here.

### Models (`lib/models/`)
- **`media_item.dart`** — `enum MediaType { audio, video }` and `class MediaItem { int sl; String link; String file; MediaType type; }` with `fromJson` / `toJson`.

### Localization (`lib/l10n/`)
- **`app_localizations.dart`** + **`app_localizations_en.dart`** — Flutter-generated from `assets/jsons/app_en.arb`. Currently exposes `appTitle` and `appDescription`. Supported locales: `[Locale('en')]`.

### Assets (`assets/`)
- `assets/pdfs/book.pdf` — bundled study book.
- `assets/jsons/audio.json`, `assets/jsons/video.json` — media catalog (Cloudinary URLs).
- `assets/jsons/app_en.arb` — localization source.
- `assets/images/` — icon / image assets.

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

**Dev**
- `flutter_test` (sdk)
- `flutter_lints` ^6.0.0

**Build / CI**
- GitHub Actions workflow `.github/workflows/release.yml` — on `v*` tag push, runs Flutter 3.41.1 stable, builds release APK, attaches it to a GitHub Release.

## Environment
- **Dart/Flutter SDK constraint:** `^3.11.0`.
- **Android permissions** (per recent commits): internet + media access enabled for release builds.
- **No backend services**, no API keys, no `.env` consumed by the Flutter code.
