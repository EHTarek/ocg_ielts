# Application Design

## 1. High-Level Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                       main.dart (ProviderScope)              │
│      Material 3 theme, GoogleFonts.poppins, AppLocalizations │
└───────────────────────────┬──────────────────────────────────┘
                            │ home
                            ▼
                    SplashScreen (3 s fade)
                            │ pushReplacement
                            ▼
                       LandingScreen
                       ┌────┴────┐
            Read Study Book      View Resources
                 │                     │
                 ▼                     ▼
          PDFViewScreen         ResourcesScreen
          (SfPdfViewer.asset)   (DefaultTabController)
                 │                ┌────┴────┐
                 │             AudioList   VideoList
                 │             Screen      Screen
                 ▼                 │            │
          MediaBottomSheet  ───────┘            │
          (audio/video tabs)                     │
                 │                                ▼
                 │                       VideoPlayerScreen
                 ▼                       (Chewie + video_player)
          AudioPlayerWidget
          (audioplayers)
```

- **UI layer:** Stateless / stateful widgets in `lib/screens/` and `lib/widgets/`. No business logic outside of player lifecycle management.
- **State layer:** `lib/providers/media_provider.dart` exposes two `FutureProvider<List<MediaItem>>`s. Riverpod is *not* used for playback state — each player widget owns its own controllers.
- **Model layer:** Single `MediaItem` class with `MediaType { audio, video }`.

## 2. Data Flow

### Catalog load (one-shot per provider, cached by Riverpod)
```
assets/jsons/audio.json ─┐
                          ├─ rootBundle.loadString
assets/jsons/video.json ─┘        │
                                  ▼
                          json.decode (List<dynamic>)
                                  ▼
                          MediaItem.fromJson per element
                                  ▼
            audioListProvider / videoListProvider (FutureProvider)
                                  ▼
              ConsumerWidget.ref.watch(...) → .when(data/loading/error)
```

### Audio playback (per modal sheet)
```
ListTile tap → showModalBottomSheet → AudioPlayerWidget
                                          │
                                          ▼
                                    AudioPlayer() init
                                          │
       ┌──────────────────────────────────┼──────────────────────────┐
       │                                  │                          │
       ▼                                  ▼                          ▼
 onPlayerStateChanged          onDurationChanged           onPositionChanged
       │                                  │                          │
       └────────── setState ──────────────┴─────── slider / labels ──┘
                                          │
                                          ▼
                                       dispose()
```

### Video playback (per route)
```
ListTile tap → Navigator.push(VideoPlayerScreen(item))
                            │
                            ▼
            VideoPlayerController.networkUrl(item.link)
                            │   initialize()
                            ▼
                  ChewieController(autoPlay, aspectRatio, ...)
                            │
                            ▼
                          Chewie(widget)
                            │
                            ▼
                  dispose() → release both controllers
```

## 3. Technology Choices & Rationale
- **Flutter (^3.11.0):** Single codebase for Android (and iOS-ready). Material 3.
- **Riverpod (^2.6.1):** Picked for the type-safe `FutureProvider` API and zero-boilerplate caching of the catalog JSON. Deliberately *not* extended to playback state — the controllers from `audioplayers` and `video_player` already encapsulate their own state machines.
- **Chewie + video_player:** Standard combo for cross-platform video with built-in controls; aspect ratio is derived from the source so no fixed sizing is hard-coded.
- **audioplayers (^6.1.1):** Lightweight, stream-based player suitable for a modal-sheet UI; gives us `PlayerState` + duration/position streams without a service layer.
- **Syncfusion PDF Viewer:** Robust commercial-grade rendering for the dense study book; supports `PdfViewerController` programmatic page navigation used by the FABs.
- **google_fonts + Poppins:** Free, consistent typography across platforms without bundling font files.

## 4. Notable Design Decisions
- **No global "now playing" state.** Each playback session is owned by the widget that triggered it; the trade-off is no cross-screen mini-player, but the win is simpler lifecycle and no orphan controllers.
- **PDF asset path is passed explicitly.** `LandingScreen` passes `'assets/pdfs/book.pdf'` to `PDFViewScreen(assetPath: ...)` rather than hard-coding inside the screen — allows future reuse for additional books.
- **Splash uses `pushReplacement`**, so users cannot back-navigate to the splash.
- **`MediaBottomSheet` reuses the same providers** as the standalone list screens — single source of truth for the catalog.
