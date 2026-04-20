# System Context

## 1. System Overview
The **OCG IELTS** is a mobile application built with Flutter that assists users in their IELTS preparation. It provides interactive multimedia content including an audio list and player, video lists and playback, and PDF document viewing. The application is designed to act as a centralized resource hub for IELTS students to access their study materials seamlessly.

## 2. Architecture & Tech Stack
- **Frontend Framework:** Flutter (Dart)
- **State Management:** Riverpod (`flutter_riverpod`) via `media_provider.dart`.
- **Multimedia:** `chewie` and `video_player` for video delivery, `audioplayers` for audio features.
- **Document Viewing:** `syncfusion_flutter_pdfviewer` for rendering PDF booklets.
- **Domain Models:** Custom `MediaItem` models parse the structure of the audio/video content.

## 3. Key Domains & Boundaries
- **Resource Navigation:** Navigating between different media types via `landing_screen.dart` and `resources_screen.dart`.
- **Document Reading:** `pdf_view_screen.dart` provides an integrated interface for studying text-based materials.
- **Media Playback:** Unified bottom sheet and list screens (`media_bottom_sheet.dart`, `audio_player_widget.dart`, `video_player_screen.dart`) that handle media states securely.

## 4. External Dependencies
- **Assets:** Local PDFs, videos, audio files, or remotes linked through the `MediaItem` configuration.
