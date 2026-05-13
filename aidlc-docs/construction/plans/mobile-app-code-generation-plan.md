# Code Generation Plan: mobile-app

## Objective
Track the implementation of `ocg_ielts` features against the functional design. This is a small, single-target Flutter app (no backend), so the checklist is short.

## Execution Checklist

### Shipped
- [x] Scaffold Flutter app with `^3.11.0` SDK.
- [x] Wire `ProviderScope` and Material 3 theme (`#1E3A8A` / `#FACC15`, Poppins) in `main.dart`.
- [x] Install playback + PDF dependencies (`audioplayers`, `video_player`, `chewie`, `syncfusion_flutter_pdfviewer`).
- [x] Generate `flutter_localizations` delegates from `assets/jsons/app_en.arb` (`l10n.yaml`).
- [x] Define `MediaItem` model + `MediaType` enum with `fromJson` / `toJson`.
- [x] Ship `assets/jsons/audio.json` and `assets/jsons/video.json` (Cloudinary URLs).
- [x] Ship `assets/pdfs/book.pdf`.
- [x] Build `SplashScreen` with 2 s fade + 3 s auto-route.
- [x] Build `LandingScreen` two-card hub.
- [x] Build `PDFViewScreen` with `SfPdfViewer.asset`, prev/next FABs, and `MediaBottomSheet` access.
- [x] Build `ResourcesScreen` tab hub.
- [x] Build `AudioListScreen` / `VideoListScreen` against the two `FutureProvider`s.
- [x] Build `AudioPlayerWidget` modal sheet (play/pause, ±10 s, slider, duration labels).
- [x] Build `VideoPlayerScreen` with Chewie + `video_player`.
- [x] Build `MediaBottomSheet` reusable two-tab catalog sheet.
- [x] Configure Android release permissions (internet + media).
- [x] GitHub Actions workflow: build + release APK on `v*` tag (Flutter 3.41.1).

### Open
- [ ] Error / retry UI for streaming failures (`VideoPlayerScreen`, `AudioPlayerWidget`).
- [ ] Lift all hard-coded UI strings into `app_en.arb`.
- [ ] Migrate `Color.withOpacity(x)` → `Color.withValues(alpha: x)` across landing/list/sheet widgets.
- [ ] Replace nested `showModalBottomSheet` chain (PDF → MediaBottomSheet → AudioPlayerWidget) with a single-sheet swap.
- [ ] Add unit tests for `MediaItem.fromJson` and provider success/failure paths.
- [ ] iOS release pipeline.
- [ ] Background-audio behaviour (media session / foreground service).
