# Functional Design Plan: mobile-app

This plan captures the behavioural design of the Flutter app `ocg_ielts` as it currently exists. The app is intentionally small: one PDF reader, one tabbed catalog, one audio player, one video player.

## Core Objectives
1. Render the Cambridge Guide PDF from a bundled asset with pan/zoom and explicit page navigation.
2. Load audio/video catalogs from bundled JSON via Riverpod `FutureProvider`s.
3. Provide a modal audio player and a full-page video player, each managing its own controllers.
4. Expose the same catalog inside the PDF reader so the user can switch media without losing place.

## Required Behaviour

### Catalog loading (`media_provider.dart`)
- Each provider reads its JSON file via `rootBundle.loadString` exactly once and caches the parsed list for the lifetime of the `ProviderScope`.
- Items deserialize through `MediaItem.fromJson`, with `type` derived from the string literal `'audio'` / `'video'`.

### PDF reader (`PDFViewScreen`)
- `assetPath` is required; no hard-coded fallback inside the screen.
- `PdfInteractionMode.pan` so two-finger pinch zoom is preserved; single-finger drag pans the page.
- Page navigation FABs use `PdfViewerController.previousPage()` / `.nextPage()` — no jump-to-page UI today.

### Audio player (`AudioPlayerWidget`)
- Fixed-height (350 px) modal sheet — never full-screen.
- Source bound via `setSourceUrl(item.link)` during `initState` so playback can start as soon as the user taps the play FAB.
- Slider value is clamped to `[0, max(1, duration_ms)]` to avoid NaN before duration is reported.
- Skip buttons clamp to `[Duration.zero, duration]`.

### Video player (`VideoPlayerScreen`)
- `ChewieController` is constructed only *after* `VideoPlayerController.initialize()` resolves, then a `setState` flushes the player into the tree.
- Aspect ratio is taken from the source.
- Black scaffold with transparent AppBar gives an immersive feel.

### Cross-resource navigation
- `MediaBottomSheet` reuses `audioListProvider` / `videoListProvider` — there is no second copy of the catalog.

## Strict interaction patterns
- **No background play.** Pausing on app background is implicit (no explicit handler today).
- **Disposal is mandatory.** Every `Stateful` player widget calls `controller.dispose()`.
- **No deep-link routing.** Navigation is push/pushReplacement only.

## Open Design Questions
- Should `MediaItem` gain a human-readable `title` field, or should display copy stay derived from `sl`/`file`?
- Should the PDF reader add a search and jump-to-page control?
- Should playback state move into Riverpod (e.g. a `Notifier<PlayerState>`) to enable a persistent mini-player across screens?
  - **Answer:**
