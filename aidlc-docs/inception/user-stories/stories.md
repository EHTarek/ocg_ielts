# User Stories

## Epics
- **Epic 1 — Study Book Reader.** Deliver the Cambridge Guide PDF as an in-app, offline reader.
- **Epic 2 — Listening Practice.** Stream and control the bundled audio catalog.
- **Epic 3 — Lesson Videos.** Stream and control the bundled video catalog.
- **Epic 4 — Cross-resource Navigation.** Let the candidate switch between book and media without losing context.
- **Epic 5 — Appearance Settings.** Let the candidate personalise the app's brightness and accent palette.

## Shipped stories

### Epic 1
1. **As an** IELTS candidate, **I want** the app to open directly into a study hub, **so that** I do not have to log in or configure anything.
   - **Acceptance:** `SplashScreen` auto-routes to `LandingScreen` after 3 s; no auth gate exists in the codebase.
2. **As an** IELTS candidate, **I want** to read the official guide PDF with smooth pan/zoom, **so that** I can study the book on my phone.
   - **Acceptance:** `PDFViewScreen` mounts `SfPdfViewer.file('<docs>/book.pdf')` with `PdfInteractionMode.pan` once the file is downloaded and cached.
3. **As an** IELTS candidate, **I want** explicit prev/next page buttons, **so that** I can flip pages without precise gestures.
   - **Acceptance:** Two mini `FloatingActionButton`s call `_pdfViewerController.previousPage() / .nextPage()` (mounted only once the viewer is in the `ready` state).
15. **As an** IELTS candidate, **I want** the app to download the study book on demand the first time I open it (instead of installing a fat APK), **so that** the initial install is small and I can read the book again offline afterwards.
    - **Acceptance:** On first open of `PDFViewScreen`, the screen detects no cached PDF and shows a *Download book* card. Tapping it streams `AppConfig.bookPdfUrl` into `<applicationDocumentsDirectory>/book.pdf` while showing a determinate progress UI. On every subsequent open the cached file is reused (no network call). A failed download surfaces an error + *Retry* button and never leaves a partial file on disk.

### Epic 2
4. **As an** IELTS candidate, **I want** a list of all listening tracks, **so that** I can pick one to play.
   - **Acceptance:** `AudioListScreen` watches `audioListProvider` and renders a `ListView` of cards labelled `Track ${sl}`.
5. **As an** IELTS candidate, **I want** a full audio player with play/pause, scrub, and ±10 s skip, **so that** I can practise listening drills.
   - **Acceptance:** `AudioPlayerWidget` (modal sheet) wires `AudioPlayer` events into a slider, play/pause FAB, and skip-back/skip-forward `IconButton`s.
13. **As an** IELTS candidate, **I want** previous- and next-track buttons inside the audio player, **so that** I can move between listening drills without closing the player and reopening the list.
    - **Acceptance:** `AudioPlayerWidget` receives `playlist: List<MediaItem>` + `initialIndex: int`, displays `Icons.skip_previous` / `Icons.skip_next` `IconButton`s flanking the play/pause FAB, disables each when at a list boundary, and on tap swaps the source to the neighbouring track and auto-resumes playback.

### Epic 3
6. **As an** IELTS candidate, **I want** a list of lesson videos, **so that** I can choose one.
   - **Acceptance:** `VideoListScreen` watches `videoListProvider` and renders cards labelled `Lesson ${sl}`.
7. **As an** IELTS candidate, **I want** a polished video player with native controls, **so that** I can scrub, pause, and fullscreen lessons.
   - **Acceptance:** `VideoPlayerScreen` initialises `VideoPlayerController.networkUrl(item.link)` and wraps it in `ChewieController(autoPlay: true, looping: false, aspectRatio: <native>)`.
14. **As an** IELTS candidate, **I want** previous- and next-lesson buttons inside the video player, **so that** I can step through the syllabus without backing out to the list.
    - **Acceptance:** `VideoPlayerScreen` receives `playlist: List<MediaItem>` + `initialIndex: int`, exposes `Icons.skip_previous` / `Icons.skip_next` `IconButton`s in the AppBar `actions`, disables each at a list boundary, and on tap disposes the old controllers, re-initialises against the neighbouring item, and auto-plays.

### Epic 4
8. **As an** IELTS candidate, **I want** to switch between audio and video lists in one place, **so that** I do not have to back out and re-enter.

   - **Acceptance:** `ResourcesScreen` is a `DefaultTabController` with rounded-pill `TabBar` ("Audio" / "Video") over `AudioListScreen` + `VideoListScreen`.
9. **As an** IELTS candidate, **I want** to open the media catalog from inside the book reader, **so that** I can play a related clip without losing my place.
   - **Acceptance:** `PDFViewScreen` AppBar menu icon calls `showModalBottomSheet` with `MediaBottomSheet`, which mirrors the same Audio/Video tabbed list.

### Epic 5
10. **As an** IELTS candidate, **I want** to switch the app between light and dark mode (or follow my system), **so that** reading at night is comfortable on my eyes.
    - **Acceptance:** Gear icon on `LandingScreen` opens `SettingsScreen`; the brightness selector exposes Light / Dark / System; `MaterialApp.themeMode` reflects the choice immediately and after restart.
11. **As an** IELTS candidate, **I want** to pick an accent colour for the app, **so that** the UI matches my taste.
    - **Acceptance:** `SettingsScreen` shows three palette swatches (IELTS Blue, Emerald, Crimson). Selecting one rebuilds `MaterialApp.theme` and `darkTheme` from the new seed, and the value persists across launches.
12. **As an** IELTS candidate, **I want** to see what version of the app I am running and find privacy/terms, **so that** I can trust the app and report issues.
    - **Acceptance:** `SettingsScreen` shows an *About* section with the app version and build number (from `package_info_plus`), tappable rows for *Privacy Policy*, *Terms of Service*, *Open Source Licenses*, *Contact Support*, *Rate on Play Store*, and *Share App*. URLs are sourced from `AppConfig` constants.

## Open / not-yet-implemented stories
- **As an** IELTS candidate, **I want** a clear error message and retry button when a stream fails to load, **so that** I do not stare at a spinner forever. *(Not implemented — see `requirement-verification-questions.md` #1.)*
- **As an** IELTS candidate, **I want** audio to keep playing when I lock my screen, **so that** I can practise listening hands-free. *(Not implemented — see #6.)*
- **As a** product owner, **I want** human-readable titles on tracks/lessons, **so that** users see "Cambridge 1 — Listening Test 1" instead of `Track 1` / `Cam01_q08q4x`. *(Schema change needed — see #5.)*
