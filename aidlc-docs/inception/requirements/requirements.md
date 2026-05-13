# Requirements

## 1. Executive Summary
The **OCG IELTS** mobile app gives self-study IELTS candidates one-tap access to (a) the Official Cambridge Guide PDF bundled in the app and (b) a curated catalog of audio listening tracks and video lessons streamed from Cloudinary. The app runs fully client-side with no authentication, no user accounts, and no remote backend; the catalog itself ships as JSON inside the asset bundle.

## 2. Functional Requirements
1. **Splash & launch.** On launch, show a 3 s branded splash (`SplashScreen`) and then auto-route to `LandingScreen` with no user interaction required.
2. **Landing hub.** `LandingScreen` must present exactly two primary actions: *Read Study Book* and *View Resources*.
3. **PDF reader.** *Read Study Book* opens `PDFViewScreen`. The screen first checks `<applicationDocumentsDirectory>/book.pdf`:
   - **Cached** → render via `SfPdfViewer.file(File)` with pan/zoom and explicit prev/next page mini-FAB controls.
   - **Missing** → show an info card with a single **Download book** action. Tapping it streams the PDF from `AppConfig.bookPdfUrl` (currently `https://raw.githubusercontent.com/EHTarek/resources/main/book.pdf`) into the documents directory, displaying a determinate progress indicator (`bytes received / total`). On success the viewer mounts immediately.
   - **Download failure** → surface a retry card with the error message; partial files are deleted so the next attempt starts fresh.
   The cached file persists across launches and app upgrades; it is only removed when the user clears the app's storage.
4. **In-reader media access.** While the PDF is open, an AppBar menu icon must open `MediaBottomSheet` so the user can browse audio/video tabs without leaving the book.
5. **Audio/Video tab hub.** *View Resources* opens `ResourcesScreen` with two tabs ("Audio", "Video") rendered as a rounded-pill `TabBar`.
6. **Audio playback.** Selecting an audio item shows `AudioPlayerWidget` as a modal bottom sheet with: play/pause FAB, ±10 s skip, seek slider, current position and total duration labels.
7. **Video playback.** Selecting a video item pushes a full-page `VideoPlayerScreen` using `Chewie` (autoplay on, looping off) sized to the source aspect ratio.
8. **Catalog data source.** Audio and video lists must be loaded from `assets/jsons/audio.json` and `assets/jsons/video.json` via `audioListProvider` / `videoListProvider` (`FutureProvider<List<MediaItem>>`).
9. **Settings — Appearance.** A gear icon in the `LandingScreen` AppBar must open a `SettingsScreen` exposing:
   - **Brightness mode** — Light, Dark, or System (follow OS).
   - **Accent palette** — one of three presets: *IELTS Blue* (default `#1E3A8A`), *Emerald* (`#047857`), *Crimson* (`#BE123C`).
   - **Live preview** — a sample card on the settings screen must repaint immediately when either control changes, and the change must propagate to the whole app via `MaterialApp.theme` / `darkTheme` / `themeMode`.
   - **Persistence** — selected mode and palette must survive app restarts (stored via `shared_preferences`).
10. **Settings — About & Legal.** The same `SettingsScreen` must include a second section exposing the items expected of a publicly distributed app:
    - **App version & build number** — fetched at runtime via `package_info_plus`.
    - **Privacy Policy** link — opens `AppConfig.privacyPolicyUrl` in the system browser.
    - **Terms of Service** link — opens `AppConfig.termsUrl`.
    - **Open-source Licenses** — opens Flutter's built-in `showLicensePage()` populated with `applicationName`, `applicationVersion`, and an icon.
    - **Contact support** — opens a `mailto:` to `AppConfig.supportEmail` with a pre-filled subject line.
    - **Rate on Play Store** — opens `AppConfig.playStoreUrl`.
    - **Share app** — opens `AppConfig.playStoreUrl` via the system share sheet (or share intent fallback through `url_launcher`).

## 3. Non-Functional Requirements
1. **Disposal correctness.** Every player (`AudioPlayer`, `VideoPlayerController`, `ChewieController`) and animation controller must be released in `dispose()`. (Currently satisfied; see `code-quality-assessment.md`.)
2. **Offline resilience.** The PDF must work fully offline (bundled asset). Streaming media degrades gracefully to a loading indicator when offline — *gap: there is no explicit error/retry UI today; see Acceptance Criteria #4.*
3. **Theme consistency.** Material 3 with a user-selectable seed colour (default `#1E3A8A` / IELTS Blue), Poppins text theme. Light and dark `ColorScheme`s are both derived from the same seed via `ColorScheme.fromSeed(brightness: ...)`; the secondary tone is *also* derived from the seed (no hard-coded brand yellow override) so palette switches re-tint every accent surface. The dark scheme uses `contrastLevel: -0.3` and a softer `surface` (~`#1B1C1F`) so the night experience is mild rather than near-black + neon. Every navigation surface, card, tab, icon, and shadow must read its colour from `Theme.of(context).colorScheme.*` — no hard-coded `Colors.white`/`Colors.black` outside of `main.dart`, `app_theme.dart`, or the deliberately black `VideoPlayerScreen` scaffold.
4. **Localization-ready.** All user-facing strings should eventually flow through `AppLocalizations`; the delegate is already wired in `main.dart`. Today English only.
5. **Release pipeline.** Android release APK must be produced by the `v*`-tag GitHub Actions workflow with Flutter 3.41.1 stable.

## 4. Acceptance Criteria
- Splash auto-advances to landing without manual tap.
- Both landing cards navigate to their respective destinations.
- First time the user opens the PDF reader, a *Download book* card appears; tapping it streams the PDF with a determinate progress indicator and switches to the viewer on completion.
- Second (and later) opens skip the prompt entirely and render the cached `<docs>/book.pdf` via `SfPdfViewer.file`.
- A failed download leaves no partial file on disk and offers a *Retry* button.
- PDF reader can flip pages via FABs and via gesture; menu icon opens the media sheet.
- Audio modal sheet shows correct duration, slider tracks position in real time, ±10 s skip clamps to `[0, duration]`.
- Video player initialises with the source's native aspect ratio and starts playing automatically.
- Killing the audio or video screen frees the underlying controllers (verifiable via no leaked listeners).
- **Open gap:** A long network timeout should surface an error message to the user instead of an indefinite spinner. *(Not yet implemented.)*
- Tapping the gear icon on Landing opens Settings; changing brightness or palette is reflected app-wide within one frame and survives a process kill / cold start.
- The About & Legal section shows the real version string from the installed package (e.g. `1.0.0 (1)`), not a hard-coded constant.
- Every legal/contact action either opens the expected destination or, if the URL is still the placeholder TODO, surfaces a `SnackBar` rather than crashing.
