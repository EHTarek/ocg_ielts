# Build and Test Summary

## Baseline Status (snapshot 2026-05-13)
- **Android release APK:** Produced automatically by GitHub Actions on `v*` tag push (Flutter 3.41.1 stable). Latest commits on `dev` include Android release permission fixes (internet + media).
- **iOS:** Buildable locally via `flutter build ios --release`; no automated pipeline yet.
- **Localization:** `flutter gen-l10n` succeeds against `assets/jsons/app_en.arb` (single locale `en`).

## Test Results
- **Unit / widget tests (`flutter test`):** Only the default Flutter scaffold widget test exists in `test/`. No coverage of provider JSON parsing, player lifecycle, or navigation.
- **Integration tests:** None.
- **Manual QA targets** (not yet automated): PDF pan + page navigation FABs, audio play/pause/seek/skip, video autoplay + scrub + fullscreen, tab switching in `ResourcesScreen`, modal-on-modal flow inside `PDFViewScreen → MediaBottomSheet`.

## Architecture Health
- File-level structure matches `inception/application-design/components.md`.
- Riverpod usage is limited to two `FutureProvider`s; no orphaned providers or unused widget files.
- All player widgets dispose their controllers (see `code-quality-assessment.md` for verification).
- Known gaps: no error UI on stream failure, no localized strings beyond `appTitle`/`appDescription`, `Color.withOpacity` deprecation warnings, nested modal-sheet pattern in the PDF reader.

## Next Steps
1. Write a `MediaItem.fromJson` unit test plus `audioListProvider` / `videoListProvider` golden tests against the bundled JSON.
2. Add a widget test that verifies `LandingScreen` → `PDFViewScreen` and `LandingScreen` → `ResourcesScreen` navigation.
3. Wire an iOS build job into GitHub Actions.
4. Add an error-and-retry widget for streaming players.
