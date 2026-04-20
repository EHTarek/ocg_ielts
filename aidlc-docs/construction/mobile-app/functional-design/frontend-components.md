# Frontend Components: mobile-app

This outlines the specific Widget trees mapped in the UI layer of the `ocg_ielts` project.

## Video Delivery
- **Tree:** `video_list_screen.dart` -> `video_player_screen.dart`.
- **Logic:** `video_player_screen.dart` initializes a `ChewieController` wrapped around a `VideoPlayerController`. Upon destruction (`dispose`), both controllers must be correctly killed.

## Audio Delivery
- **Tree:** `audio_list_screen.dart` -> `audio_player_widget.dart` / `media_bottom_sheet.dart`.
- **Logic:** `audio_player_widget.dart` listens dynamically to the `audio_provider` to update its internal slider progress without requiring a full screen rebuild.

## PDF Delivery
- **Tree:** `resources_screen.dart` -> `pdf_view_screen.dart`.
- **Logic:** Relies entirely on `SfPdfViewer.asset` or `SfPdfViewer.network`.
