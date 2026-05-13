---
name: aidlc-sync
description: Re-sync the aidlc-docs/ tree against the current source code when documentation has drifted from reality. Use when the user says "update aidlc docs", "the docs are stale", "resync docs", or after a stretch of undocumented changes.
---

# AI-DLC documentation resync

Pure documentation operation — **do not change `lib/` code** unless the user asks. The goal is to make `aidlc-docs/` reflect what `lib/` already does.

## When to invoke
- User asks to update / refresh / resync `aidlc-docs/`.
- You inspect the docs and find claims that contradict the code (wrong file names, dead dependencies, stale schema).
- You are about to start a feature and notice the inception docs are out of date — sync first, then run `/aidlc-feature`.

## Inputs to read (source of truth)
Read every one of these before editing any doc. Don't skip — drifted claims usually hide in the file you didn't open.

1. `pubspec.yaml` — real dependency versions.
2. `lib/main.dart` — entry point, theme wiring, localization wiring.
3. `lib/models/*.dart` — data classes; treat their actual fields as authoritative against `business-logic-model.md`.
4. `lib/providers/*.dart` — the real provider types and what they load.
5. `lib/screens/*.dart` and `lib/widgets/*.dart` — actual widget trees.
6. `lib/config/*.dart` — distribution constants, feature flags, env hooks.
7. `lib/l10n/app_en.arb` — supported strings; `l10n.yaml`.
8. `assets/jsons/audio.json`, `assets/jsons/video.json` — catalog schema.
9. `assets/pdfs/` — asset names.
10. `.github/workflows/*.yml` — CI flow, what artifact ships, Flutter version pin.
11. `android/app/build.gradle.kts` and `android/app/src/main/AndroidManifest.xml` — applicationId, signing config, permissions.

## Targets to write
Touch every file in `aidlc-docs/` whose claims are now wrong. Common drift patterns:

| Doc | Common drift |
|---|---|
| `inception/context/system-context.md` | references services that no longer exist (or were never there); wrong tech-stack version. |
| `inception/context/glossary.md` | terms for removed features still listed. |
| `inception/context/dependencies.md` | missing newly-added packages, stale file lists. |
| `inception/context/code-quality-assessment.md` | debt items already paid down still listed as open. |
| `inception/context/reverse-engineering-timestamp.md` | stamp + checklist needs the new date. |
| `inception/requirements/requirements.md` | shipped features still phrased as "must"-be-built; missing recent AC. |
| `inception/user-stories/stories.md` | shipped stories not marked shipped; open stories missing. |
| `inception/application-design/{application-design,components}.md` | architecture diagram and component list misaligned with `lib/`. |
| `construction/plans/mobile-app-code-generation-plan.md` | wrong checklist state. |
| `construction/mobile-app/functional-design/{business-logic-model,frontend-components}.md` | wrong field names, wrong widget trees. |
| `construction/build-and-test/{build-instructions,build-and-test-summary}.md` | references to old build commands or test results. |

## Rules
- **No code changes** unless the user explicitly authorises them. If you notice a real bug while reading source, mention it in the report but don't fix it in this skill.
- **No invented behaviour.** If the docs claim something the code doesn't do, delete the claim — don't preserve it.
- **Be specific.** Doc snippets should reference actual symbol names, actual file paths, actual class fields. Generic prose ages worse than specific prose.
- **Update the audit log.** Append a dated bullet to `aidlc-docs/audit.md` listing every file you touched and the most important corrections you made. Update `aidlc-docs/aidlc-state.md` "Last Sync" date.
- **Preserve open questions.** If `requirement-verification-questions.md` still has unanswered items, leave them — only edit if the question itself has been answered by the code.

## Reporting back
End with: a short bulleted list of corrections made (e.g. "removed Supabase references — never existed in code"), the count of files touched, and the new "Last Sync" date written to `aidlc-state.md`.
