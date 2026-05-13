# Business Logic Model: mobile-app

## 1. Core Flow
1. User launches the app → `SplashScreen` animates a fade for 2 s, then after 3 s `Navigator.pushReplacement` swaps it for `LandingScreen`.
2. From `LandingScreen` the user chooses one of two branches:
   - **Read Study Book** → `PDFViewScreen` opens `assets/pdfs/book.pdf`. The user can pan/zoom the page, tap FABs to move pages, or tap the AppBar menu to open `MediaBottomSheet`.
   - **View Resources** → `ResourcesScreen` (tabbed Audio / Video). Each tab lists items from a Riverpod `FutureProvider`. Tapping an audio item shows a modal `AudioPlayerWidget`; tapping a video pushes `VideoPlayerScreen`.

## 2. State Model

### Catalog state — Riverpod
- `audioListProvider: FutureProvider<List<MediaItem>>` and `videoListProvider: FutureProvider<List<MediaItem>>`.
- Loaded once, cached for the `ProviderScope`'s lifetime. Consumers receive `AsyncValue<List<MediaItem>>` and render `data` / `loading` / `error` via `.when(...)`.

### Audio playback state — local to `AudioPlayerWidget`
- Fields kept in widget state: `_audioPlayer: AudioPlayer`, `_playerState: PlayerState`, `_duration: Duration`, `_position: Duration`.
- Transitions driven by three subscriptions:
  - `onPlayerStateChanged` → updates `_playerState` (mirrors `audioplayers` `PlayerState`: `stopped`, `playing`, `paused`, `completed`, `disposed`).
  - `onDurationChanged` → updates `_duration`.
  - `onPositionChanged` → updates `_position`.
- User intents:
  - Play FAB: if `_playerState == playing` → `pause()`; else `play(UrlSource(item.link))`.
  - Slider `onChanged`: `seek(Duration(milliseconds: value.toInt()))`.
  - Skip back: `seek(max(zero, _position - 10 s))`.
  - Skip forward: `seek(min(_duration, _position + 10 s))`.
- `dispose()` calls `_audioPlayer.dispose()`.

### Video playback state — local to `VideoPlayerScreen`
- Fields: `_videoPlayerController: VideoPlayerController` and `_chewieController: ChewieController?` (nullable until initialised).
- Lifecycle:
  - `initState()` → kick off `_initializePlayer()` async.
  - After `_videoPlayerController.initialize()` resolves, construct `ChewieController(autoPlay: true, looping: false, aspectRatio: <source>)` and `setState({})` to mount `Chewie(controller: _chewieController!)`.
  - Until then, render `CircularProgressIndicator()`.
  - `dispose()` releases both controllers.

### PDF reader state — local to `PDFViewScreen`
- Fields: `_pdfViewerController: PdfViewerController`, `_pdfViewerKey: GlobalKey<SfPdfViewerState>`.
- No additional app state — `SfPdfViewer` handles page tracking internally.

## 3. Data Entities

```dart
enum MediaType { audio, video }

class MediaItem {
  final int sl;
  final String link;   // network URL (Cloudinary)
  final String file;   // display/filename
  final MediaType type;

  MediaItem({required this.sl, required this.link, required this.file, required this.type});

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        sl: json['sl'] as int,
        link: json['link'] as String,
        file: json['file'] as String,
        type: json['type'] == 'audio' ? MediaType.audio : MediaType.video,
      );

  Map<String, dynamic> toJson() => {
        'sl': sl,
        'link': link,
        'file': file,
        'type': type == MediaType.audio ? 'audio' : 'video',
      };
}
```

Sample asset JSON entry (`assets/jsons/audio.json`):
```json
{ "sl": 1, "link": "https://res.cloudinary.com/dwl9piiu1/video/upload/v1771737537/Cam01_q08q4x.mp3", "file": "Cam01_q08q4x", "type": "audio" }
```

## 4. Invariants
- The catalog is **read-only**; there is no path that mutates `MediaItem` instances.
- Playback controllers are **per-widget** and never escape their owning widget's lifecycle.
- The PDF asset path is **provided by the caller** (`LandingScreen` passes `'assets/pdfs/book.pdf'`) and is not hard-coded inside `PDFViewScreen`.
