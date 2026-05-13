# User Stories

## Epics
- **Epic 1 — Study Book Reader.** Deliver the Cambridge Guide PDF as an in-app, offline reader.
- **Epic 2 — Listening Practice.** Stream and control the bundled audio catalog.
- **Epic 3 — Lesson Videos.** Stream and control the bundled video catalog.
- **Epic 4 — Cross-resource Navigation.** Let the candidate switch between book and media without losing context.

## Shipped stories

### Epic 1
1. **As an** IELTS candidate, **I want** the app to open directly into a study hub, **so that** I do not have to log in or configure anything.
   - **Acceptance:** `SplashScreen` auto-routes to `LandingScreen` after 3 s; no auth gate exists in the codebase.
2. **As an** IELTS candidate, **I want** to read the official guide PDF with smooth pan/zoom, **so that** I can study the book on my phone.
   - **Acceptance:** `PDFViewScreen` mounts `SfPdfViewer.asset('assets/pdfs/book.pdf')` with `PdfInteractionMode.pan`.
3. **As an** IELTS candidate, **I want** explicit prev/next page buttons, **so that** I can flip pages without precise gestures.
   - **Acceptance:** Two mini `FloatingActionButton`s call `_pdfViewerController.previousPage() / .nextPage()`.

### Epic 2
4. **As an** IELTS candidate, **I want** a list of all listening tracks, **so that** I can pick one to play.
   - **Acceptance:** `AudioListScreen` watches `audioListProvider` and renders a `ListView` of cards labelled `Track ${sl}`.
5. **As an** IELTS candidate, **I want** a full audio player with play/pause, scrub, and ±10 s skip, **so that** I can practise listening drills.
   - **Acceptance:** `AudioPlayerWidget` (modal sheet) wires `AudioPlayer` events into a slider, play/pause FAB, and skip-back/skip-forward `IconButton`s.

### Epic 3
6. **As an** IELTS candidate, **I want** a list of lesson videos, **so that** I can choose one.
   - **Acceptance:** `VideoListScreen` watches `videoListProvider` and renders cards labelled `Lesson ${sl}`.
7. **As an** IELTS candidate, **I want** a polished video player with native controls, **so that** I can scrub, pause, and fullscreen lessons.
   - **Acceptance:** `VideoPlayerScreen` initialises `VideoPlayerController.networkUrl(item.link)` and wraps it in `ChewieController(autoPlay: true, looping: false, aspectRatio: <native>)`.

### Epic 4
8. **As an** IELTS candidate, **I want** to switch between audio and video lists in one place, **so that** I do not have to back out and re-enter.
   - **Acceptance:** `ResourcesScreen` is a `DefaultTabController` with rounded-pill `TabBar` ("Audio" / "Video") over `AudioListScreen` + `VideoListScreen`.
9. **As an** IELTS candidate, **I want** to open the media catalog from inside the book reader, **so that** I can play a related clip without losing my place.
   - **Acceptance:** `PDFViewScreen` AppBar menu icon calls `showModalBottomSheet` with `MediaBottomSheet`, which mirrors the same Audio/Video tabbed list.

## Open / not-yet-implemented stories
- **As an** IELTS candidate, **I want** a clear error message and retry button when a stream fails to load, **so that** I do not stare at a spinner forever. *(Not implemented — see `requirement-verification-questions.md` #1.)*
- **As an** IELTS candidate, **I want** audio to keep playing when I lock my screen, **so that** I can practise listening hands-free. *(Not implemented — see #6.)*
- **As a** product owner, **I want** human-readable titles on tracks/lessons, **so that** users see "Cambridge 1 — Listening Test 1" instead of `Track 1` / `Cam01_q08q4x`. *(Schema change needed — see #5.)*
