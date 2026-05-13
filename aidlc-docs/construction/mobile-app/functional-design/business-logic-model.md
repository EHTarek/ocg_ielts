# Business Logic Model: mobile-app

## 1. Core Flow
1. User launches the app → `SplashScreen` animates a fade for 2 s, then after 3 s `Navigator.pushReplacement` swaps it for `LandingScreen`.
2. From `LandingScreen` the user chooses one of two branches:
   - **Read Study Book** → `PDFViewScreen`: looks for a cached `<applicationDocumentsDirectory>/book.pdf`. If present, renders `SfPdfViewer.file(...)`; the user can pan/zoom the page, tap FABs to move pages, or tap the AppBar menu to open `MediaBottomSheet`. If absent, shows a *Download book* card; tapping it streams `AppConfig.bookPdfUrl` to disk with a progress indicator, then transitions to the viewer.
   - **View Resources** → `ResourcesScreen` (tabbed Audio / Video). Each tab lists items from a Riverpod `FutureProvider`. Tapping an audio item shows a modal `AudioPlayerWidget`; tapping a video pushes `VideoPlayerScreen`.

## 2. State Model

### Catalog state — Riverpod
- `audioListProvider: FutureProvider<List<MediaItem>>` and `videoListProvider: FutureProvider<List<MediaItem>>`.
- Loaded once, cached for the `ProviderScope`'s lifetime. Consumers receive `AsyncValue<List<MediaItem>>` and render `data` / `loading` / `error` via `.when(...)`.

### Audio playback state — local to `AudioPlayerWidget`
- Constructor inputs: `playlist: List<MediaItem>` + `initialIndex: int`.
- Fields kept in widget state: `_currentIndex: int`, `_audioPlayer: AudioPlayer`, `_playerState: PlayerState`, `_duration: Duration`, `_position: Duration`. Derived: `_currentItem == widget.playlist[_currentIndex]`.
- Transitions driven by three subscriptions:
  - `onPlayerStateChanged` → updates `_playerState` (mirrors `audioplayers` `PlayerState`: `stopped`, `playing`, `paused`, `completed`, `disposed`).
  - `onDurationChanged` → updates `_duration`.
  - `onPositionChanged` → updates `_position`.
- User intents:
  - Play FAB: if `_playerState == playing` → `pause()`; else `play(UrlSource(_currentItem.link))`.
  - Slider `onChanged`: `seek(Duration(milliseconds: value.toInt()))`.
  - Skip back: `seek(max(zero, _position - 10 s))`.
  - Skip forward: `seek(min(_duration, _position + 10 s))`.
  - Previous track (enabled iff `_currentIndex > 0`): `_goToIndex(_currentIndex - 1)`.
  - Next track (enabled iff `_currentIndex < playlist.length - 1`): `_goToIndex(_currentIndex + 1)`.
- `_goToIndex(int newIndex)`: `await _audioPlayer.stop()`; reset `_position` / `_duration` to `Duration.zero`; `setState(() => _currentIndex = newIndex)`; `await _audioPlayer.setSourceUrl(_currentItem.link)`; `await _audioPlayer.play(UrlSource(_currentItem.link))` so the new track auto-resumes.
- `dispose()` calls `_audioPlayer.dispose()`.

### Video playback state — local to `VideoPlayerScreen`
- Constructor inputs: `playlist: List<MediaItem>` + `initialIndex: int`.
- Fields: `_currentIndex: int`, `_videoPlayerController: VideoPlayerController` and `_chewieController: ChewieController?` (nullable until initialised).
- Lifecycle:
  - `initState()` → kick off `_initializePlayer()` async against `_currentItem`.
  - After `_videoPlayerController.initialize()` resolves, construct `ChewieController(autoPlay: true, looping: false, aspectRatio: <source>)` and `setState({})` to mount `Chewie(controller: _chewieController!)`.
  - Until then, render `CircularProgressIndicator()`.
  - `_goToIndex(int newIndex)`: dispose both existing controllers, set `_chewieController = null` (re-shows the spinner), `setState(() => _currentIndex = newIndex)`, then `_initializePlayer()` against the new `_currentItem`.
  - Prev / next AppBar buttons are disabled (`onPressed: null`) at list boundaries, enabled otherwise.
  - `dispose()` releases both controllers.

### PDF reader state — local to `PDFViewScreen`
- Fields:
  - `_pdfViewerController: PdfViewerController`, `_pdfViewerKey: GlobalKey<SfPdfViewerState>` — used by the viewer once a file exists.
  - `_state: PdfDownloadState` — one of `checking`, `needsDownload`, `downloading`, `ready`, `error`.
  - `_localFile: File?` — the resolved on-disk PDF; non-null only when `_state == ready`.
  - `_received: int`, `_total: int?` — bytes for the determinate progress UI.
  - `_error: Object?` — exception captured when a download fails.
  - `_httpClient: HttpClient?` (dart:io), `_subscription: StreamSubscription<List<int>>?`, `_sink: IOSink?` — released in `_cleanupDownload()` and `dispose()`.
- Transitions:
  - `initState` → `_resolve()`: `state = checking`; query `path_provider.getApplicationDocumentsDirectory()` → build target path; `await File(target).exists()`; if exists and `lengthSync() > 0`, set `_localFile = File(target)` and `state = ready`; else `state = needsDownload`.
  - User taps *Download book* (only enabled in `needsDownload` and `error`) → `_startDownload()`: `state = downloading`; `received = 0; total = null`; open `<docs>/book.pdf.part` sink; `HttpClient().getUrl(uri)` with `followRedirects = true, maxRedirects = 8` then `await request.close()`; on the streamed response read `total = response.contentLength`; for each chunk: `sink.add(chunk)`, `received += chunk.length`, `setState()`; on `onDone`: `await sink.flush(); await sink.close()`. Then **PDF magic-byte check**: read the first 4 bytes of `.part` and confirm they are `%PDF` (0x25/0x50/0x44/0x46); if not, throw `_NotAPdfException` which surfaces a localized "downloaded file isn't a valid PDF" message and triggers the same cleanup as any other failure. On success: atomic `.part → book.pdf` rename, `_localFile = ...`, `state = ready`. On `onError`, header-check failure, *or* any other exception above: `_cleanupDownload()` (cancel sub, close sink, force-close HttpClient), delete `.part` if it exists, capture `_error`, `state = error`.
  - User taps *Retry* (only visible in `error`) → `_startDownload()` again (the `.part` was already cleaned up).
  - `dispose()` cancels any active subscription, closes the sink, and closes the `http.Client`. The downloader cancels-and-exits if `mounted` is false after an `await`.
- Invariants:
  - When `state == ready`, `_localFile` is non-null **and** the file exists on disk.
  - The view never reads from a `.part` file — only the renamed `book.pdf` is mounted.
  - No more than one in-flight download per `PDFViewScreen` instance.

### Package metadata — `FutureProvider`
- `packageInfoProvider: FutureProvider<PackageInfo>` calls `PackageInfo.fromPlatform()` once and caches the result for the `ProviderScope`'s lifetime.
- Consumed by the *About* footer in `SettingsScreen`, which renders `'<appName> <version> (<buildNumber>)'`.

### Distribution actions — pure side-effecting functions
- *Privacy Policy* / *Terms of Service* tiles call `_openLegal(context, title, body)` which `Navigator.push`es a `LegalDocumentScreen(title: ..., body: ...)`. Bodies come from `LegalTexts.privacyPolicy` / `LegalTexts.termsOfService` — these flows never leave the app.
- `_openUrl(BuildContext context, String url)` (used by *Rate on Play Store* and *Share App*) calls `launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)`; if the launch returns `false` (no compatible app on the device), a `couldNotOpenLink` `SnackBar` is shown.
- `_emailSupport(BuildContext context)` builds a `mailto:` URI with a pre-filled subject and falls through the same placeholder check.
- `_shareApp(BuildContext context, String storeUrl)` reuses `_openUrl` against the Play Store URL (no platform Share plugin required).
- `_showLicenses(BuildContext context, PackageInfo info)` calls Flutter's `showLicensePage(applicationName: info.appName, applicationVersion: '${info.version} (${info.buildNumber})', applicationIcon: ...)`.

### Theme settings — Riverpod `Notifier`
- `themeSettingsProvider: NotifierProvider<ThemeSettingsNotifier, ThemeSettings>`.
- `ThemeSettings` = `{ ThemeMode mode; AppPalette palette; }` (immutable, `copyWith`). Defaults: `mode = ThemeMode.system`, `palette = AppPalette.ieltsBlue`.
- `AppPalette` exposes a `seed` getter:
  - `ieltsBlue → Color(0xFF1E3A8A)`
  - `emerald   → Color(0xFF047857)`
  - `crimson   → Color(0xFFBE123C)`
- Lifecycle:
  - `build()` returns the default `ThemeSettings`, then schedules `_hydrate()` asynchronously which reads `SharedPreferences` and `state = ...` if a saved value exists.
  - `setMode(ThemeMode m)` → `state = state.copyWith(mode: m)` then `prefs.setString('theme_mode', m.name)`.
  - `setPalette(AppPalette p)` → `state = state.copyWith(palette: p)` then `prefs.setString('theme_palette', p.name)`.
- Persistence keys are `theme_mode` and `theme_palette`; values stored as `enum.name` strings. Unknown values fall back to defaults.

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
- Playback controllers are **per-widget** and never escape their owning widget's lifecycle. The playlist is also **per-widget**: each player instance is told which list it belongs to at construction time and never reaches back into a `FutureProvider` to resolve neighbours.
- `_currentIndex` in both player widgets is always within `[0, playlist.length - 1]`. Prev/next buttons enforce this by disabling at the boundaries; there is no wrap-around.
- The study-book URL is **owned by `AppConfig`** (`AppConfig.bookPdfUrl`), not the caller. `LandingScreen` invokes `PDFViewScreen()` with no parameters; the screen resolves both the cached file path and the network URL on its own.
- `MyApp` is the **only** consumer of `themeSettingsProvider` for `MaterialApp` wiring; individual screens never read `themeMode` directly and rely on `Theme.of(context)` instead.
- `SharedPreferences` writes are **fire-and-forget**: UI updates immediately on `setMode` / `setPalette`; if the disk write fails the in-memory state is still authoritative for the session.
