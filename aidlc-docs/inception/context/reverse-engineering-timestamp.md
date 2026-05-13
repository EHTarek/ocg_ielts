# Reverse Engineering Timestamp

## Metadata
- **Snapshot Date:** 2026-05-13
- **Scope:** Re-synced `aidlc-docs/` against the actual `lib/` source tree, `pubspec.yaml`, `assets/`, and CI workflow. Previous snapshot (2026-03-31) referenced Supabase, FCM, and a `MediaType.pdf` enum that never existed in code.

## Source-of-truth files inspected
- `lib/main.dart`, `lib/models/media_item.dart`, `lib/providers/media_provider.dart`
- `lib/screens/{splash,landing,resources,audio_list,video_list,video_player,pdf_view}_screen.dart`
- `lib/widgets/{audio_player_widget,media_bottom_sheet}.dart`
- `lib/l10n/app_localizations*.dart`
- `pubspec.yaml`
- `assets/jsons/audio.json`, `assets/jsons/video.json`
- `.github/workflows/*.yml`

## Artifact Checklist (refreshed)
- [x] `system-context.md` — replaced Supabase/FCM references with the actual Cloudinary + bundled-asset model.
- [x] `glossary.md` — removed Supabase/FCM; added MediaItem field schema, Cloudinary, MediaBottomSheet.
- [x] `dependencies.md` — now reflects the real package list (`google_fonts`, `intl`, `flutter_localizations`) and accurate file-level responsibilities.
- [x] `code-quality-assessment.md` — debt list rewritten against current implementation.

*This file marks when the documentation was last realigned with the implementation. Update it whenever the architecture drifts.*
