# Code Quality Assessment

## Overview
This document evaluates the `ocg_ielts` codebase as it stands today. The app is a small, self-contained Flutter project: ~13 Dart files in `lib/`, no backend, no auth, and a single PDF + two JSON catalogs as its content surface.

- **Layering:** Clean three-tier split — `models/`, `providers/`, `screens/` + `widgets/`. No leakage of plugin types upward through the model layer.
- **State strategy:** `flutter_riverpod` is used narrowly for async catalog loading (`FutureProvider`). Per-player runtime state (`AudioPlayer`, `VideoPlayerController`, `ChewieController`) is owned locally by the corresponding `StatefulWidget`. This is intentional and appropriate for the current scope, but means there is no shared "now playing" state across screens.
- **Theme & typography:** Centralised in `main.dart` (Material 3, seed `#1E3A8A`, secondary `#FACC15`, Poppins via `google_fonts`).

## Strengths
- **Resource disposal** is wired correctly: `VideoPlayerScreen.dispose()` releases both controllers; `AudioPlayerWidget.dispose()` releases its `AudioPlayer`; `SplashScreen` disposes its `AnimationController`.
- **Localization scaffolding** is in place (`flutter_localizations`, generated ARB delegates) even though only English is shipped.
- **JSON parsing** in `MediaItem.fromJson` is tolerant of the canonical schema and round-trips through `toJson`.
- **CI release pipeline** is automated for Android via GitHub Actions on `v*` tags.

## Technical Debt & Risk Areas
- **Hard-coded asset path** — `LandingScreen` passes `'assets/pdfs/book.pdf'` as a string literal; if the asset is renamed or removed nothing fails until runtime.
- **No error UI for missing/blocked network media** — `VideoPlayerScreen` shows only a `CircularProgressIndicator` while `_chewieController` is null; a permanent network failure will hang the spinner indefinitely. `AudioPlayerWidget` likewise has no error surface for `setSourceUrl` failures.
- **PDF asset menu is empty of context** — `MediaBottomSheet` shows the same audio/video tabs but tapping an audio item pushes another modal bottom sheet *on top of* the existing one (`showModalBottomSheet` over the PDF's modal). Stack management of nested sheets is fragile under rotation.
- **`withOpacity` deprecation** — Flutter 3.27+ deprecates `Color.withOpacity` in favour of `withValues`. Several call sites (`landing_screen.dart`, `audio_list_screen.dart`, `video_list_screen.dart`, `media_bottom_sheet.dart`) still use it.
- **Hard-coded display strings** ("Track ${sl}", "Lesson ${sl}", "What would you like to do today?", "Read Study Book", "View Resources", splash title) are not routed through `AppLocalizations`, even though l10n is set up.
- **No tests beyond the default scaffold** — `test/` only contains the Flutter template's widget test; there is no coverage of provider JSON parsing, player lifecycle, or navigation.
- **No `MediaItem` validation** — `fromJson` casts raw JSON without null checks; a malformed asset JSON crashes the provider.
- **Catalog growth** — `audioListProvider` / `videoListProvider` rebuild the full `List<MediaItem>` on every read of the bundled JSON (cached by Riverpod, but parsed eagerly on first use). Fine for current ~tens of entries; would warrant lazy/streaming parsing only if the catalog grew substantially.

## Recommended Next Steps (prioritised)
1. Add an error state widget to `VideoPlayerScreen` and `AudioPlayerWidget` (timeout + retry).
2. Migrate hard-coded strings into `app_en.arb` to make additional locales possible.
3. Replace `Color.withOpacity(x)` with `Color.withValues(alpha: x)`.
4. Add unit tests for `MediaItem.fromJson` round-trips and provider success/failure paths.
5. Pin the PDF asset path in a single constant (e.g. `AppAssets.studyBook`) shared by the landing card and any future deep links.
