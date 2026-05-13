# Components

All paths are relative to `lib/`.

## 1. Entry & Theming
- **`main.dart`** — `void main()` wraps `MyApp` in `ProviderScope`. `MyApp` is a `StatelessWidget` returning `MaterialApp` with:
  - `title` = `AppLocalizations.of(context)!.appTitle` ("OCG IELTS").
  - Theme: Material 3, seed `#1E3A8A`, secondary `#FACC15`, Poppins text theme, transparent zero-elevation `AppBarTheme` with `centerTitle: true`.
  - Localization delegates: `AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`.
  - `supportedLocales: [Locale('en')]`.
  - `home: SplashScreen()`.

## 2. Navigation Screens
- **`screens/splash_screen.dart` — `SplashScreen`** (`StatefulWidget` + `SingleTickerProviderStateMixin`)
  - 2 s `AnimationController` + `CurvedAnimation(easeIn)` powering a `FadeTransition`.
  - `Future.delayed(Duration(seconds: 3))` then `Navigator.pushReplacement` to `LandingScreen` (guarded by `mounted`).
  - UI: circular white icon container with `Icons.auto_stories` and the title "The Official Cambridge Guide to IELTS" on the blue background.
- **`screens/landing_screen.dart` — `LandingScreen`** (`StatelessWidget`)
  - Empty AppBar; body is a `Column` of two `_buildOptionCard` cards.
  - Card 1: "Read Study Book" / "Digital version of the Official Guide" → `PDFViewScreen(assetPath: 'assets/pdfs/book.pdf')`.
  - Card 2: "View Resources" / "Audio and Video practice materials" → `ResourcesScreen`.
- **`screens/resources_screen.dart` — `ResourcesScreen`** (`StatelessWidget`)
  - `DefaultTabController(length: 2)` with a custom rounded-pill `TabBar` ("Audio" / "Video") in the AppBar.
  - Body: `TabBarView(children: [AudioListScreen(), VideoListScreen()])`.

## 3. Media List Screens
- **`screens/audio_list_screen.dart` — `AudioListScreen`** (`ConsumerWidget`)
  - `ref.watch(audioListProvider).when(data, loading, error)`.
  - `data` → `ListView.builder` of cards (`Icons.audiotrack`, title `Track ${item.sl}`, subtitle `item.file`, `play_circle_fill` trailing).
  - On tap: `showModalBottomSheet` rendering `AudioPlayerWidget(item: item)`.
- **`screens/video_list_screen.dart` — `VideoListScreen`** (`ConsumerWidget`)
  - Same shape as `AudioListScreen` but `Icons.movie_outlined`, title `Lesson ${item.sl}`, and `Navigator.push` to `VideoPlayerScreen(item: item)`.

## 4. Player Screens / Widgets
- **`screens/pdf_view_screen.dart` — `PDFViewScreen`** (`StatefulWidget`, required `String assetPath`)
  - Owns `PdfViewerController` + `GlobalKey<SfPdfViewerState>`.
  - Body: `SfPdfViewer.asset(widget.assetPath, controller: _pdfViewerController, key: _pdfViewerKey, interactionMode: PdfInteractionMode.pan)`.
  - AppBar action: menu `IconButton` → `showModalBottomSheet(builder: => MediaBottomSheet())`.
  - `floatingActionButton`: `Column` with two mini FABs (`heroTag: 'prev'/'next'`) wired to `_pdfViewerController.previousPage()` / `.nextPage()`.
- **`screens/video_player_screen.dart` — `VideoPlayerScreen`** (`StatefulWidget`, required `MediaItem item`)
  - `initState()` → `_initializePlayer()`: creates `VideoPlayerController.networkUrl(Uri.parse(item.link))`, awaits `initialize()`, then builds `ChewieController(autoPlay: true, looping: false, aspectRatio: <video aspectRatio>, materialProgressColors: red/grey/white70, autoInitialize: true)` and calls `setState`.
  - Black scaffold, transparent AppBar with white icon theme.
  - `dispose()` releases both controllers.
- **`widgets/audio_player_widget.dart` — `AudioPlayerWidget`** (`StatefulWidget`, required `MediaItem item`)
  - Owns one `AudioPlayer` and three subscriptions: `onPlayerStateChanged`, `onDurationChanged`, `onPositionChanged` (each updates a local state field).
  - `_initAudio()` calls `_audioPlayer.setSourceUrl(item.link)`.
  - 350 px modal sheet with: drag handle, "Track ${sl}" title, file name subtitle, `Slider` (clamped to `[0, duration]`), formatted position/duration labels (`MM:SS`), and a button row: `replay_10` / large play-pause FAB / `forward_10`. Play FAB triggers `audioPlayer.play(UrlSource(item.link))` if not currently playing, else `.pause()`.

## 5. Shared Widget
- **`widgets/media_bottom_sheet.dart` — `MediaBottomSheet`** (`ConsumerWidget`)
  - 70 % screen-height sheet with the same rounded-pill `TabBar` ("Audio" / "Video") as `ResourcesScreen`.
  - Two private inner `ConsumerWidget`s (`_AudioListTab`, `_VideoListTab`) replicate the catalog list pattern. Tapping an audio entry stacks another modal sheet with `AudioPlayerWidget`; tapping a video pushes `VideoPlayerScreen`.

## 6. State & Models
- **`providers/media_provider.dart`**
  - `audioListProvider` — `FutureProvider<List<MediaItem>>` that loads `assets/jsons/audio.json`, decodes JSON, maps to `MediaItem.fromJson`.
  - `videoListProvider` — same as above with `assets/jsons/video.json`.
- **`models/media_item.dart`**
  - `enum MediaType { audio, video }`.
  - `class MediaItem` with `int sl`, `String link`, `String file`, `MediaType type`, plus `fromJson` and `toJson`. Type round-trips as the string `'audio'` or `'video'`.

## 7. Localization
- **`l10n/app_localizations.dart`** (generated) + **`l10n/app_localizations_en.dart`** — currently exposes only `appTitle` and `appDescription`.
- ARB source: `assets/jsons/app_en.arb`.
- `l10n.yaml` at repo root drives generation.
