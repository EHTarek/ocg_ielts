# Dependencies

## Internal Dependencies
- **Screens (`lib/screens/`)**: 
  - `landing_screen.dart`, `splash_screen.dart`, `resources_screen.dart` are core navigation.
  - `pdf_view_screen.dart`, `audio_list_screen.dart`, `video_list_screen.dart`, `video_player_screen.dart` handle media delivery.
- **Widgets (`lib/widgets/`)**: 
  - `audio_player_widget.dart` and `media_bottom_sheet.dart` are reused components attached to the screens.
- **Providers (`lib/providers/`)**: 
  - `media_provider.dart` handles the global state logic for media playback.
- **Models (`lib/models/`)**: 
  - `media_item.dart` structures the properties for the resources.

## External Dependencies
**Core Packages:**
- `flutter`: UI toolkit
- `flutter_riverpod` (^2.6.1): Reactive State Management

**Media Plugins:**
- `audioplayers` (^6.1.1): Core audio streaming
- `video_player` (^2.9.2): Core video streaming
- `chewie` (^1.9.0): UI scaffolding for the video player
- `syncfusion_flutter_pdfviewer` (^28.1.33): PDF rendering engine
