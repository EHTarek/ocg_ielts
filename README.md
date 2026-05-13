# OCG IELTS

Flutter mobile app — *Official Cambridge Guide to IELTS*. Bundles the official guide PDF and streams a curated Cloudinary-hosted catalog of audio listening tracks and video lessons. No backend, no auth.

## Quick start

```bash
flutter pub get          # fetch deps + regenerate l10n
flutter run              # launch on a connected device / emulator
flutter analyze          # lint
flutter test             # unit / widget tests
```

Release APK (matches the CI artifact):
```bash
flutter build apk --release
```

After adding any **native** plugin, you may need to do a one-time clean:
```bash
flutter clean && flutter pub get
```

## Source layout

```
lib/
├── main.dart                   # ProviderScope + MaterialApp + theme + l10n
├── config/app_config.dart      # distribution URLs / support email (placeholders until release)
├── models/                     # MediaItem, ThemeSettings, AppPalette
├── providers/                  # media_provider, theme_provider
├── screens/                    # splash, landing, resources, audio/video list, players, pdf_view, settings
├── widgets/                    # audio_player_widget, media_bottom_sheet
└── l10n/                       # generated; ARB source is lib/l10n/app_en.arb
assets/
├── pdfs/book.pdf
├── jsons/{audio,video}.json    # Cloudinary URLs
└── images/
```

## Conventions

These are enforced by `CLAUDE.md` and the `/aidlc-feature` workflow — please follow them when contributing.

- **State management:** `flutter_riverpod`.
  - `FutureProvider` for load-once async (catalog JSON, `PackageInfo`).
  - `Notifier` / `StateNotifier` for mutable state (theme settings).
  - Player controllers (`AudioPlayer`, `VideoPlayerController`, `ChewieController`) live inside their owning `StatefulWidget` — never lift them into Riverpod.
- **Theming:** Read colours from `Theme.of(context).colorScheme.*`. Do **not** hard-code `Color(0xFF...)` outside `lib/models/app_theme.dart` or `lib/main.dart`. New widgets must work in both light and dark mode.
- **Localization:** Every user-facing string goes through `AppLocalizations`. Edit `lib/l10n/app_en.arb`, then `flutter pub get` (auto-regenerates) or `flutter gen-l10n`.
- **Deprecations:** Use `Color.withValues(alpha: x)`, **not** `Color.withOpacity(x)`.
- **Disposal:** Every player controller, animation controller, and stream subscription must be released in `dispose()`. Adding a new player widget without disposal is a regression.
- **No new top-level docs.** All project docs live under `aidlc-docs/`. Don't create README/architecture/CHANGELOG files at the repo root unless explicitly requested.

## AI-DLC workflow

This project follows an **AI-Driven Development Lifecycle**: every behaviour change keeps `aidlc-docs/` in sync with `lib/`. The doc tree:

```
aidlc-docs/
├── aidlc-state.md                              # current phase + last-sync timestamps
├── audit.md                                    # append-only changelog
├── inception/
│   ├── context/                                # system-context, glossary, dependencies, code-quality-assessment
│   ├── requirements/                           # requirements + open verification questions
│   ├── user-stories/                           # personas + stories
│   └── application-design/                     # architecture + components
└── construction/
    ├── plans/                                  # code-generation + functional-design plans
    ├── build-and-test/                         # build instructions + test summary
    └── mobile-app/functional-design/           # business-logic-model + frontend-components
```

### Invocable skills

Three project-scoped skills under `.claude/skills/`. Invoke from any Claude Code session by typing `/<skill-name>`:

| Skill | When to use |
|---|---|
| **`/aidlc-feature`** | Adding a feature, updating an existing one, adding/removing a dependency, or any refactor that changes externally visible behaviour. Walks: clarify → inception docs → construction docs → implement → analyze + build → audit. |
| **`/aidlc-sync`** | Docs and code have drifted. Read-only against `lib/`; only edits `aidlc-docs/`. Run this first if you notice stale claims in the inception docs before starting a feature. |
| **`/aidlc-status`** | Read-only one-page snapshot — current phase, app version, shipped epics, open backlog, recent audit entries. |

See [`CLAUDE.md`](CLAUDE.md) for the full conventions and [`.claude/skills/aidlc-feature/SKILL.md`](.claude/skills/aidlc-feature/SKILL.md) for the step-by-step workflow.

### Manual workflow (if not using Claude Code)

For any behaviour change:

1. **Update inception docs** that the change actually affects (`requirements.md`, `stories.md`, `components.md`, `dependencies.md`, etc.). Don't touch docs the change doesn't impact.
2. **Update construction docs** — at minimum tick a checklist entry in `mobile-app-code-generation-plan.md`. Update `business-logic-model.md` if state/data changed, `frontend-components.md` if the widget tree changed.
3. **Implement** following the conventions above.
4. **Verify:** `flutter analyze` (target: 0 new issues beyond the 2 tracked `withOpacity` warnings) and a debug build sanity check.
5. **Audit:** append a dated bullet to `aidlc-docs/audit.md` and update the "Last Sync" line in `aidlc-docs/aidlc-state.md`.

## Pre-release checklist

Before publishing to the Play Store / App Store, replace the placeholders in [`lib/config/app_config.dart`](lib/config/app_config.dart) and complete the items tracked in [`aidlc-docs/construction/plans/mobile-app-code-generation-plan.md`](aidlc-docs/construction/plans/mobile-app-code-generation-plan.md):

- [ ] Real `privacyPolicyUrl`, `termsUrl`, `playStoreUrl`, `supportEmail`.
- [ ] Android release keystore signing (`android/key.properties` + `signingConfigs`).
- [ ] CI: switch APK → AAB.
- [ ] Branded adaptive launcher icon + native splash.
- [ ] Error/retry UI for streaming players.

## CI / Release

GitHub Actions builds a release APK and attaches it to a GitHub Release on `v*` tag push (Flutter `3.41.1` stable). To cut a release:

```bash
git tag vX.Y.Z && git push origin vX.Y.Z
```

## Tech stack

Flutter `^3.11.0` · Material 3 · `flutter_riverpod` · `audioplayers` · `video_player` + `chewie` · `syncfusion_flutter_pdfviewer` · `google_fonts` (Poppins) · `shared_preferences` · `package_info_plus` · `url_launcher` · `flutter_localizations` + `intl`.

## Further reading

- [`CLAUDE.md`](CLAUDE.md) — project memory, full conventions.
- [`aidlc-docs/inception/context/system-context.md`](aidlc-docs/inception/context/system-context.md) — system overview.
- [`aidlc-docs/inception/application-design/application-design.md`](aidlc-docs/inception/application-design/application-design.md) — architecture diagram.
- [`aidlc-docs/construction/build-and-test/build-instructions.md`](aidlc-docs/construction/build-and-test/build-instructions.md) — full build setup.
