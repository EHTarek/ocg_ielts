# System Context

## 1. System Overview
The **OCG IELTS** (Official Cambridge Guide to IELTS) is a Flutter mobile application that delivers IELTS preparation content. The app bundles the official guide as a single PDF booklet and streams a curated set of audio tracks and video lessons hosted on Cloudinary. There is no backend, no authentication, and no remote user data — the catalog itself ships as JSON assets inside the app bundle.

## 2. Architecture & Tech Stack
- **Frontend Framework:** Flutter (Dart, SDK `^3.11.0`).
- **State Management:** `flutter_riverpod` ^2.6.1. Currently used only for asynchronously loading the audio/video catalogs from bundled JSON (`audioListProvider`, `videoListProvider`). Playback state is kept locally inside the player widgets.
- **Video Playback:** `video_player` ^2.9.2 + `chewie` ^1.9.0, network streaming via `VideoPlayerController.networkUrl`.
- **Audio Playback:** `audioplayers` ^6.1.1, streaming via `UrlSource` from each `MediaItem.link`.
- **PDF Rendering:** `syncfusion_flutter_pdfviewer` ^28.1.33 mounted as `SfPdfViewer.asset` over `assets/pdfs/book.pdf`.
- **Typography:** `google_fonts` ^6.2.1 (Poppins text theme).
- **Localization:** `flutter_localizations` + `intl` ^0.20.2, ARB-generated delegates in `lib/l10n/`. Supported locales: English only.
- **Domain Model:** `MediaItem` (single class) representing both audio and video catalog entries.

## 3. Key Domains & Boundaries
- **App Entry & Theming:** `main.dart` wires `ProviderScope`, sets the Material 3 theme (IELTS Blue `#1E3A8A` primary, IELTS Yellow `#FACC15` secondary, Poppins text), and installs localization delegates.
- **Onboarding & Navigation:** `splash_screen.dart` runs a 2 s fade animation then auto-pushes `landing_screen.dart` after 3 s. The landing screen exposes two cards: *Read Study Book* (PDF) and *View Resources* (audio + video).
- **Document Reading:** `pdf_view_screen.dart` renders the bundled PDF and exposes a top-bar menu that opens `MediaBottomSheet` so the user can dip into audio/video without leaving the book.
- **Resources Tab Hub:** `resources_screen.dart` is a `DefaultTabController` with two tabs — `AudioListScreen` and `VideoListScreen` — both `ConsumerWidget`s reading the catalog providers.
- **Audio Playback:** `audio_player_widget.dart` is a `StatefulWidget` shown as a modal bottom sheet; it owns its own `AudioPlayer` instance and tracks state/duration/position via the `audioplayers` event streams.
- **Video Playback:** `video_player_screen.dart` is a full-page `StatefulWidget` that creates and disposes its own `VideoPlayerController` + `ChewieController`.

## 4. External Dependencies
- **Cloudinary CDN:** All audio (`.mp3`) and video (`.mp4`) URLs in `assets/jsons/audio.json` and `assets/jsons/video.json` point to `res.cloudinary.com/dwl9piiu1/...`. No upload/auth flow — the app is a pure consumer.
- **Bundled Assets:** `assets/pdfs/book.pdf` (the Cambridge Guide), `assets/jsons/audio.json`, `assets/jsons/video.json`, `assets/images/`.
- **CI/CD:** `.github/workflows/` builds a release APK and creates a GitHub Release on `v*` tags using Flutter 3.41.1 stable.
