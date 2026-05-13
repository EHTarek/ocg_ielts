# Build Instructions

## Prerequisites
- **Flutter SDK:** `^3.11.0` (CI pins `3.41.1` stable channel).
- **Dart:** ships with the Flutter SDK.
- **Android toolchain:** Android Studio + JDK 17 (Zulu in CI), Android SDK and platform tools.
- **iOS toolchain (optional):** Xcode (latest stable) with command-line tools, CocoaPods.
- **No environment variables** are required by the Flutter code — there is no backend, no API key, no `.env` consumed at runtime.

## Local Execution

1. Fetch dependencies:
   ```bash
   flutter pub get
   ```

2. (Optional) Regenerate localizations after editing `assets/jsons/app_en.arb`:
   ```bash
   flutter gen-l10n
   ```

3. Run on a connected device or emulator:
   ```bash
   flutter run
   ```

4. Build a release APK (Android):
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`.

5. Build a release IPA (iOS — local only, no CI yet):
   ```bash
   flutter build ios --release
   ```

## CI / Release
- GitHub Actions workflow `.github/workflows/release.yml` (or equivalent under `.github/workflows/`) triggers on tags matching `v*`:
  1. Checks out the repo.
  2. Installs JDK 17 (Zulu) and Flutter 3.41.1 stable.
  3. Runs `flutter pub get`.
  4. Runs `flutter build apk --release`.
  5. Uses `softprops/action-gh-release@v2` to attach `app-release.apk` to a GitHub Release named `Release <tag>`.
- To cut a release: `git tag vX.Y.Z && git push origin vX.Y.Z`.

## Test Execution
- Unit / widget tests:
  ```bash
  flutter test
  ```
  (Currently only the default scaffold test exists in `test/`.)

## Common Troubleshooting
- **`SfPdfViewer` blank page:** confirm `assets/pdfs/book.pdf` is declared under `flutter > assets` in `pubspec.yaml` (it is) and that the asset is committed.
- **Audio/video won't load:** the URLs in `assets/jsons/{audio,video}.json` are public Cloudinary links; verify internet permission is granted and the Cloudinary host is reachable.
- **Localization missing strings:** ensure `flutter gen-l10n` has been run after editing the ARB file, and that `l10n.yaml` is at repo root.
