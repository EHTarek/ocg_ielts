# Business Logic Model: mobile-app

## 1. Core Logic Flow 
The core business logic centers around resource routing and state persistence.
- Users begin at `landing_screen.dart`, selecting their desired preparation material.
- If Video/Audio is selected, `media_provider.dart` intercepts the configuration defined in `media_item.dart` to instantiate localized or remote Streams.

## 2. State Mapping (Riverpod)
- **`media_provider` State:** Stores the `currentMedia`, `isPlaying`, `duration`, and `position`. 
- **Transitions:** 
  - Play -> Pause (Triggered via UI or OS level interruption).
  - Stop -> Destroy (Controller is disposed when navigating away from the resource branch).

## 3. Data Entities
```dart
class MediaItem {
  final String id;
  final String title;
  final String url; // Or local asset path
  final MediaType type; // enum: audio, video, pdf
}
```
