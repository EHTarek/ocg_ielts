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
- [x] ~~Ship `assets/pdfs/book.pdf`.~~ Replaced 2026-05-13 — see "Downloadable Study Book" below.
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

### In progress — Appearance Settings (Epic 5, 2026-05-13)
- [x] Add `shared_preferences` dependency.
- [x] Define `models/app_theme.dart` (`AppPalette` enum + `ThemeSettings` value object).
- [x] Implement `providers/theme_provider.dart` (`ThemeSettingsNotifier` with hydrate-from-prefs + persist-on-change).
- [x] Build `screens/settings_screen.dart` with brightness segmented control, palette swatches, and live preview card.
- [x] Convert `MyApp` to `ConsumerWidget`; build both `theme` and `darkTheme` from the current `AppPalette.seed`; bind `themeMode`.
- [x] Add a gear `IconButton` to `LandingScreen` AppBar that pushes `SettingsScreen`.
- [x] Localize new strings in `app_en.arb`.

### In progress — Distribution Readiness (Epic 6, 2026-05-13)
- [x] Add `package_info_plus` + `url_launcher` dependencies.
- [x] Create `config/app_config.dart` with placeholder URLs / email and `isPlaceholder()` helper.
- [x] Extend `SettingsScreen` with an *About & Legal* section: Privacy Policy, Terms of Service, Open Source Licenses, Contact Support, Rate on Play Store, Share App, and a version/build footer.
- [x] Wire Flutter's built-in `showLicensePage()` for OSS attributions.
- [x] Localize the new strings in `app_en.arb`.
- [ ] Replace `AppConfig` placeholder `playStoreUrl` / `supportEmail` with real values (manual, pre-release). Privacy/Terms now in-app, no URL needed.
- [ ] Tighten the boilerplate `LegalTexts.privacyPolicy` / `termsOfService` text with a real review before publishing.
- [ ] Android release signing config (deferred — see open backlog).
- [ ] Switch CI to App Bundle (.aab) (deferred).
- [ ] Branded launcher icon + native splash (deferred).

### Shipped — Mild Dark Theme & Full Theme-Token Migration (Epic 5 extension, 2026-05-13)
- [x] Soften the dark `ColorScheme` in `main.dart`: `contrastLevel: -0.3` plus a single-shot `.copyWith()` overriding `surface` / `onSurface` / `onSurfaceVariant` so dark mode reads as a mild near-charcoal rather than near-black with neon primary.
- [x] Drop the hard-coded `Color(0xFFFACC15)` `secondary` override from `ColorScheme.fromSeed` so palette switching re-tints every accent surface (not just primary).
- [x] Register component themes in `main.dart` (`appBarTheme`, `cardTheme`, `tabBarTheme`, `bottomSheetTheme`, `iconTheme`) so default widgets inherit scheme colours without per-call wiring.
- [x] Replace hard-coded colours across the codebase with `Theme.of(context).colorScheme.*` tokens: `splash_screen.dart`, `landing_screen.dart` (`_buildOptionCard` second card → `secondaryContainer`), `resources_screen.dart` (TabBar background → `surfaceContainerHighest`; label / indicator from scheme), `media_bottom_sheet.dart` (sheet bg + drag handle + TabBar), `audio_player_widget.dart` (sheet bg + drag handle + subtitle).
- [x] Fix list-icon palette tracking (2026-05-13): `audio_list_screen.dart` + `video_list_screen.dart` leading-circle backgrounds → `primaryContainer`, icons → `onPrimaryContainer`, trailing `play_circle_*` → `colorScheme.primary` (audio's was inheriting the global `onSurface` icon theme so it never tinted with the palette).
- [x] Responsive `AudioPlayerWidget` (2026-05-13): dropped the hard-coded `height: 350`; sheet now wraps `SafeArea(top: false)` + `Padding` + `Column(mainAxisSize.min)` so it grows to fit content and respects the bottom system inset. Long file names truncate to 2 lines + ellipsis instead of pushing the layout.
- [x] Fix "blank PDF after download" bug (2026-05-13): rewired the PDF downloader from `package:http`'s streamed `Client.send` to `dart:io HttpClient`. The previous flow surfaced gzip-encoded bytes raw — when the GitHub raw → CDN chain served `Content-Encoding: gzip`, the file written to disk was compressed, so SfPdfViewer rendered a blank page. `HttpClient` auto-follows redirects and auto-decompresses. Also added a `%PDF` magic-byte check on the staged `.part` file: if the leading bytes aren't `0x25 0x50 0x44 0x46`, throw `_NotAPdfException` (localized as `downloadInvalidPdf`), cleanup, and show the *Retry* card. Dropped `http` from `pubspec.yaml`.
- [x] `video_player_screen.dart`: keep the scaffold black for cinema-style viewing but tint Chewie progress (`playedColor`/`handleColor`) from `colorScheme.primary`, captured once in `didChangeDependencies`. Buffer/background stay translucent white for legibility on black.

### Shipped — In-app Legal Text (Epic 6 extension, 2026-05-13)
- [x] Add `lib/legal/legal_texts.dart` with `LegalTexts.privacyPolicy` + `LegalTexts.termsOfService` boilerplate constants.
- [x] Add `lib/screens/legal_document_screen.dart` (`StatelessWidget` with title + body, `SelectableText`).
- [x] Rewire `SettingsScreen` *Privacy Policy* / *Terms of Service* tiles to `Navigator.push` the new screen via `_openLegal()`; remove URL handling for those two rows.
- [x] Drop `AppConfig.privacyPolicyUrl` + `AppConfig.termsUrl` (now unused).

### Shipped — Downloadable Study Book (Epic 1 extension, 2026-05-13)
- [x] Add `http` + `path_provider` to `pubspec.yaml` and drop `assets/pdfs/` from the asset list.
- [x] Delete the bundled `assets/pdfs/book.pdf` from the asset tree.
- [x] Add `AppConfig.bookPdfUrl` (raw GitHub URL) and `AppConfig.bookPdfFileName`.
- [x] Rewrite `PDFViewScreen` with a `PdfDownloadState` state machine (`checking`, `needsDownload`, `downloading`, `ready`, `error`), streamed `http` download to a `.part` file, atomic rename on completion, and a *Retry* path that clears partials.
- [x] Drop the `assetPath` constructor parameter from `PDFViewScreen`; update the `LandingScreen` call site to `const PDFViewScreen()`.
- [x] Localize the download UI strings in `app_en.arb`.

### In progress — Player Playlist Navigation (Epic 2/3 extension, 2026-05-13)
- [x] Extend `AudioPlayerWidget` constructor to accept `playlist: List<MediaItem>` + `initialIndex: int`.
- [x] Add `_currentIndex` + `_goToIndex` to `AudioPlayerWidget`; render `skip_previous` / `skip_next` `IconButton`s on either side of the play/pause FAB; disable at boundaries; auto-play on switch.
- [x] Extend `VideoPlayerScreen` constructor to accept `playlist` + `initialIndex` and re-initialise `VideoPlayerController` + `ChewieController` when the index changes.
- [x] Expose prev/next `IconButton`s in `VideoPlayerScreen`'s AppBar `actions` (disabled at boundaries; tooltip via `AppLocalizations`).
- [x] Update the four call sites (`AudioListScreen`, `VideoListScreen`, `MediaBottomSheet._AudioListTab`, `MediaBottomSheet._VideoListTab`) to pass the full catalog list + tapped index.
- [x] Add `playerPrevious` / `playerNext` strings to `app_en.arb` and regenerate `AppLocalizations`.

### Open
- [ ] Error / retry UI for streaming failures (`VideoPlayerScreen`, `AudioPlayerWidget`).
- [ ] Lift all hard-coded UI strings into `app_en.arb`.
- [x] Migrate `Color.withOpacity(x)` → `Color.withValues(alpha: x)` across landing/list/sheet widgets. *(2026-05-13 — last two callsites in `audio_list_screen.dart` and `video_list_screen.dart`.)*
- [ ] Replace nested `showModalBottomSheet` chain (PDF → MediaBottomSheet → AudioPlayerWidget) with a single-sheet swap.
- [ ] Add unit tests for `MediaItem.fromJson` and provider success/failure paths.
- [ ] iOS release pipeline.
- [ ] Background-audio behaviour (media session / foreground service).
