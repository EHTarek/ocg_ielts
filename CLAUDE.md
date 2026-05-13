# Project: OCG IELTS (Flutter)

Cross-platform Flutter app — Official Cambridge Guide to IELTS. Bundled PDF + Cloudinary-streamed audio/video catalog. No backend, no auth.

## Source layout (read these before suggesting structure)
- `lib/main.dart` — `MyApp` is a `ConsumerWidget`; wires `ProviderScope`, Material 3 theme, `AppLocalizations` delegates.
- `lib/screens/` — `splash_screen.dart`, `landing_screen.dart`, `resources_screen.dart`, `audio_list_screen.dart`, `video_list_screen.dart`, `video_player_screen.dart`, `pdf_view_screen.dart`, `settings_screen.dart`.
- `lib/widgets/` — `audio_player_widget.dart`, `media_bottom_sheet.dart`.
- `lib/providers/` — `media_provider.dart` (catalog FutureProviders), `theme_provider.dart` (`ThemeSettingsNotifier`).
- `lib/models/` — `media_item.dart`, `app_theme.dart`.
- `lib/config/app_config.dart` — distribution-endpoint constants (privacy/terms/playstore/email, all `TODO` until release).
- `lib/l10n/` — generated; ARB source is `lib/l10n/app_en.arb`, config at `l10n.yaml`.
- `assets/` — `pdfs/book.pdf`, `jsons/audio.json` + `video.json` (Cloudinary URLs), `images/`.

## AI-DLC methodology — this project is driven by `aidlc-docs/`
Every behaviour change (feature, fix, refactor) must keep the docs in `aidlc-docs/` in sync with the code. The directory layout is:

```
aidlc-docs/
├── aidlc-state.md            # current phase + last-sync timestamps
├── audit.md                  # append-only changelog of doc + code resyncs
├── inception/
│   ├── context/              # system-context, glossary, dependencies, code-quality-assessment, reverse-engineering-timestamp
│   ├── requirements/         # requirements.md + open verification questions
│   ├── user-stories/         # personas + epics/stories
│   └── application-design/   # architecture diagram + component descriptions
└── construction/
    ├── plans/                # mobile-app-code-generation-plan + functional-design-plan
    ├── build-and-test/       # build-instructions + summary
    └── mobile-app/functional-design/  # business-logic-model + frontend-components
```

**Invocable skills** (in `.claude/skills/`):
- `/aidlc-feature` — full workflow for any new feature or scope change. Updates inception → construction → code → analyze/build → audit. Use this whenever the user asks for a new behaviour.
- `/aidlc-sync` — resync `aidlc-docs/` against the current source tree (drift correction).
- `/aidlc-status` — print a one-page snapshot: current phase, last sync, open backlog items, gaps.

## Conventions
- **State management:** `flutter_riverpod`. Use `FutureProvider` for async load-once data (catalogs, `PackageInfo`). Use `Notifier`/`StateNotifier` for mutable state (theme settings). Player controllers (`AudioPlayer`, `VideoPlayerController`, `ChewieController`) are owned locally by their `StatefulWidget` — never lifted into Riverpod.
- **Theming:** Always read colours from `Theme.of(context).colorScheme.*`. Never hard-code `Color(0xFF...)` outside `models/app_theme.dart` or `main.dart`. New widgets must work in both light and dark mode.
- **Localization:** Any user-facing string must go through `AppLocalizations` (`l10n/app_en.arb`). After editing the ARB, run `flutter gen-l10n` (or `flutter pub get` which auto-regenerates).
- **Deprecation:** Use `Color.withValues(alpha: x)`, not `Color.withOpacity(x)`. All callsites have been migrated; `flutter analyze` should stay at 0 warnings — any new `withOpacity` is a regression.
- **Disposal:** Every player controller, animation controller, and subscription must be released in `dispose()`. Adding a new player widget without disposal is a regression.
- **No new top-level docs.** Don't create README/architecture/CHANGELOG files outside `aidlc-docs/` unless the user explicitly asks.

## Build commands
- `flutter pub get` — fetch deps (auto-regenerates l10n).
- `flutter analyze` — lint. Goal: 0 issues.
- `flutter build apk --debug --target-platform android-arm64` — quick build sanity check.
- After adding a native plugin: `flutter clean && flutter pub get` once, then build.
- Release pipeline: GitHub Actions on `v*` tag → Flutter 3.41.1 stable → release APK attached to GitHub Release. (AAB switch is on the backlog.)

## Distribution backlog (do not implement silently)
The following are tracked in [aidlc-docs/construction/plans/mobile-app-code-generation-plan.md](aidlc-docs/construction/plans/mobile-app-code-generation-plan.md) and require explicit user go-ahead:
- Replace `AppConfig` `TODO` URLs with real Privacy / Terms / Play Store URLs and support email.
- Android release keystore signing (`android/key.properties` + `signingConfigs` in `build.gradle.kts`).
- CI: switch APK → AAB.
- Branded adaptive launcher icon + native splash (`flutter_launcher_icons`, `flutter_native_splash`).
- Error/retry UI for streaming players.
- Lift remaining hard-coded strings into ARB.
