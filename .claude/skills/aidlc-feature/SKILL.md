---
name: aidlc-feature
description: Drive a new feature or scope change through the AI-DLC workflow used by this project — update inception docs, then construction docs, then implement, then verify, then audit. Use this whenever the user asks to add, change, or remove app behaviour.
---

# AI-DLC feature workflow

This is the canonical workflow for any behaviour change in `ocg_ielts`. Follow it in order; do not skip steps. Mark steps in TodoWrite as you go.

## When to invoke
Use this skill any time the user asks for one of:
- a new feature / new screen / new widget
- a meaningful UX change (new control, new flow, new section)
- introducing or removing a dependency
- a refactor that changes externally visible behaviour or component boundaries

Do **not** use this skill for purely internal tweaks (a single-line bug fix, lint cleanup, comment edit). For those, just edit and run `flutter analyze`.

## Step 0 — Clarify scope (if ambiguous)
If the user request has more than one reasonable interpretation, ask one focused `AskUserQuestion` *before* touching docs. Examples: persistence approach, where the entry point lives, palette choices. Skip if the request is unambiguous.

## Step 1 — Update inception docs
Edit only the files that the change actually affects. The full set lives at `aidlc-docs/inception/`:

| File | When to update |
|---|---|
| `requirements/requirements.md` | New functional or non-functional requirement, or a new acceptance criterion. |
| `requirements/requirement-verification-questions.md` | The change reveals a question only the user can answer. |
| `user-stories/personas.md` | A new persona enters scope (rare). |
| `user-stories/stories.md` | Almost always — add story under an existing epic or create a new epic. |
| `application-design/application-design.md` | The state or data-flow story changes. |
| `application-design/components.md` | New screen, widget, provider, model, or config file. |
| `context/dependencies.md` | New `pubspec.yaml` package, new internal file, or removed component. |
| `context/system-context.md` | A new external service, new data source, or a top-level architectural shift. |
| `context/glossary.md` | A new domain term that will appear in code or other docs. |
| `context/code-quality-assessment.md` | The change introduces or pays down tracked technical debt. |

Do not rewrite a doc just to touch it. If the change does not affect a file, leave it alone.

## Step 2 — Update construction docs
| File | When to update |
|---|---|
| `construction/plans/mobile-app-code-generation-plan.md` | Always — add the new feature as a sub-checklist (mark `[x]` as you ship each item; `[ ]` for known deferred work). |
| `construction/plans/mobile-app-functional-design-plan.md` | Behavioural rules or open design questions changed. |
| `construction/mobile-app/functional-design/business-logic-model.md` | State machine, data entity, or invariant changed. |
| `construction/mobile-app/functional-design/frontend-components.md` | Widget tree changed. Update or add the ASCII tree for the affected screen. |
| `construction/build-and-test/build-instructions.md` | New build / l10n / signing step required to run the app. |
| `construction/build-and-test/build-and-test-summary.md` | New test coverage shipped, or new manual-QA target identified. |

## Step 3 — Implement
Conventions enforced by `CLAUDE.md`:
- Use `flutter_riverpod` for app state; use `FutureProvider` for load-once async, `Notifier` for mutable.
- Player controllers stay local to `StatefulWidget`s and dispose in `dispose()`.
- Colours come from `Theme.of(context).colorScheme.*`, never hard-coded outside `main.dart` / `app_theme.dart`.
- User-visible strings go through `AppLocalizations` (edit `lib/l10n/app_en.arb`, then `flutter gen-l10n` if needed).
- Use `Color.withValues(alpha: x)`, never `withOpacity`.
- Do not introduce a new top-level doc file outside `aidlc-docs/` without explicit user instruction.

If a new package is added: update `pubspec.yaml`, run `flutter pub get`. For native plugins (Android/iOS code), a `flutter clean && flutter pub get` may be required once.

## Step 4 — Verify
Run all three in parallel where independent:
```bash
flutter analyze
flutter build apk --debug --target-platform android-arm64
```
Goal: zero **new** issues. The two pre-existing `withOpacity` warnings in `audio_list_screen.dart` and `video_list_screen.dart` are tracked in the open backlog and acceptable until that backlog item is picked up.

If the change is UI-only, also describe to the user what you would test manually (light/dark mode, palette switch, etc.) — you cannot drive the UI yourself.

## Step 5 — Audit
Append a single dated bullet to `aidlc-docs/audit.md` summarising:
- the epic / feature name,
- the files created and modified,
- the new dependencies (if any),
- explicitly which related items were *deferred* and where they are tracked.

Update `aidlc-docs/aidlc-state.md` "Last Sync" if a phase boundary moved.

## Reporting back
End with a short summary listing: docs touched, code touched (with `[path](path)` links), build/analyze result, and any pre-release TODOs the user still needs to fill in (e.g. real privacy/terms URLs in `AppConfig`).
