# Glossary

- **AI-DLC (AI-Driven Development Lifecycle):** A methodology designed to heavily integrate AI into the software development process from inception to operations, emphasizing structured collaboration and explicit planning.
- **OCG IELTS:** *Official Cambridge Guide to IELTS* — the name of the Flutter application that bundles the Cambridge guide PDF and a Cloudinary-hosted audio/video catalog for IELTS preparation.
- **Riverpod:** Reactive state-management framework for Flutter. In this app it is used exclusively to wrap two `FutureProvider`s that load `audio.json` / `video.json` from the asset bundle. Playback state is not in Riverpod.
- **MediaItem:** Catalog entry model (`lib/models/media_item.dart`). Fields: `sl` (int), `link` (network URL), `file` (display name), `type` (`MediaType.audio` or `MediaType.video`).
- **MediaType:** Enum with two values — `audio`, `video`. There is no `pdf` member; the study book is downloaded on first open and rendered from the on-disk cache, not via the catalog.
- **Chewie:** UI wrapper around `video_player` providing Material/Cupertino playback controls; used in `VideoPlayerScreen`.
- **Syncfusion PDF Viewer:** Commercial-grade PDF rendering widget (`SfPdfViewer.file`) used to render the cached study book with `PdfInteractionMode.pan` and prev/next page FABs.
- **Cloudinary:** Third-party media CDN (`res.cloudinary.com/dwl9piiu1/...`) that hosts every audio and video stream referenced by the catalog JSON.
- **Book cache:** `<applicationDocumentsDirectory>/book.pdf` — the file the app writes after a successful first-open download. Persists across launches and app upgrades; removed only when the user clears app data. Resolved via `path_provider`.
- **MediaBottomSheet:** Reusable modal sheet (`lib/widgets/media_bottom_sheet.dart`) that surfaces the audio/video catalog as a two-tab list from within the PDF reader.
