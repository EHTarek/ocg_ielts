# Components

## 1. UI Navigation Components
- **`splash_screen.dart`**: Entry point of the application handling initial loading logic.
- **`landing_screen.dart`**: The main hub allowing the user to select their study direction.
- **`resources_screen.dart`**: Directory routing for different types of media resources.

## 2. Media Delivery Components
- **`pdf_view_screen.dart`**: Mounts `syncfusion_flutter_pdfviewer` to load IELTS booklets.
- **`audio_list_screen.dart`**: Renders list of audio tracks.
- **`video_list_screen.dart` / `video_player_screen.dart`**: Renders lists and playback UI using `chewie`.

## 3. Shared Widgets & Dialogs
- **`audio_player_widget.dart`**: Modular audio controls (play, pause, seek).
- **`media_bottom_sheet.dart`**: A contextual pop-up likely handling media selection or overlay interactions.

## 4. State & Models
- **`media_provider.dart`**: Riverpod controller to manage the active media stream and list data.
- **`media_item.dart`**: The strict data definition structure mapping media URL/Path, title, and type.
