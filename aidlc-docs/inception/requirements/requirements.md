# Requirements

## 1. Executive Summary
The **OCG IELTS** mobile app gives self-study IELTS candidates one-tap access to (a) the Official Cambridge Guide PDF bundled in the app and (b) a curated catalog of audio listening tracks and video lessons streamed from Cloudinary. The app runs fully client-side with no authentication, no user accounts, and no remote backend; the catalog itself ships as JSON inside the asset bundle.

## 2. Functional Requirements
1. **Splash & launch.** On launch, show a 3 s branded splash (`SplashScreen`) and then auto-route to `LandingScreen` with no user interaction required.
2. **Landing hub.** `LandingScreen` must present exactly two primary actions: *Read Study Book* and *View Resources*.
3. **PDF reader.** *Read Study Book* opens `PDFViewScreen` with `assets/pdfs/book.pdf` rendered by `SfPdfViewer.asset`, supporting pan/zoom and explicit prev/next page controls (mini FABs).
4. **In-reader media access.** While the PDF is open, an AppBar menu icon must open `MediaBottomSheet` so the user can browse audio/video tabs without leaving the book.
5. **Audio/Video tab hub.** *View Resources* opens `ResourcesScreen` with two tabs ("Audio", "Video") rendered as a rounded-pill `TabBar`.
6. **Audio playback.** Selecting an audio item shows `AudioPlayerWidget` as a modal bottom sheet with: play/pause FAB, ±10 s skip, seek slider, current position and total duration labels.
7. **Video playback.** Selecting a video item pushes a full-page `VideoPlayerScreen` using `Chewie` (autoplay on, looping off) sized to the source aspect ratio.
8. **Catalog data source.** Audio and video lists must be loaded from `assets/jsons/audio.json` and `assets/jsons/video.json` via `audioListProvider` / `videoListProvider` (`FutureProvider<List<MediaItem>>`).

## 3. Non-Functional Requirements
1. **Disposal correctness.** Every player (`AudioPlayer`, `VideoPlayerController`, `ChewieController`) and animation controller must be released in `dispose()`. (Currently satisfied; see `code-quality-assessment.md`.)
2. **Offline resilience.** The PDF must work fully offline (bundled asset). Streaming media degrades gracefully to a loading indicator when offline — *gap: there is no explicit error/retry UI today; see Acceptance Criteria #4.*
3. **Theme consistency.** Material 3 with seed `#1E3A8A` (IELTS Blue) primary and `#FACC15` (IELTS Yellow) secondary, Poppins text theme.
4. **Localization-ready.** All user-facing strings should eventually flow through `AppLocalizations`; the delegate is already wired in `main.dart`. Today English only.
5. **Release pipeline.** Android release APK must be produced by the `v*`-tag GitHub Actions workflow with Flutter 3.41.1 stable.

## 4. Acceptance Criteria
- Splash auto-advances to landing without manual tap.
- Both landing cards navigate to their respective destinations.
- PDF reader can flip pages via FABs and via gesture; menu icon opens the media sheet.
- Audio modal sheet shows correct duration, slider tracks position in real time, ±10 s skip clamps to `[0, duration]`.
- Video player initialises with the source's native aspect ratio and starts playing automatically.
- Killing the audio or video screen frees the underlying controllers (verifiable via no leaked listeners).
- **Open gap:** A long network timeout should surface an error message to the user instead of an indefinite spinner. *(Not yet implemented.)*
