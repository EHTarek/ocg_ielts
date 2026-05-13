---
name: aidlc-status
description: Print a one-page snapshot of the current AI-DLC state for this project — phase, last sync, shipped epics, open backlog, and known doc drift. Read-only; never edits files. Use when the user asks "where are we", "what's left", or "status".
---

# AI-DLC status snapshot

A pure read-only summary. **Do not edit any file.**

## What to gather
Read these in parallel:
1. `aidlc-docs/aidlc-state.md` — current phase, last-sync date.
2. `aidlc-docs/audit.md` — most recent 3–5 entries.
3. `aidlc-docs/construction/plans/mobile-app-code-generation-plan.md` — checklist; count `[x]` vs `[ ]` in each section.
4. `aidlc-docs/inception/user-stories/stories.md` — count shipped stories per epic and any "Open / not-yet-implemented" items.
5. `aidlc-docs/inception/requirements/requirement-verification-questions.md` — unanswered questions.
6. `pubspec.yaml` — current version (`version:` line) and SDK constraint.
7. (Quick) `flutter analyze` output if cheap — note any new issues beyond the two known `withOpacity` warnings.

## Output format
Emit a single concise markdown report — under ~25 lines. Use this exact skeleton, filling in real values from the files above:

```
## AI-DLC status — <YYYY-MM-DD>

**Phase:** <Inception | Construction | Operations>  •  **Last sync:** <date from aidlc-state.md>
**App version:** <pubspec.yaml version>  •  **Flutter SDK:** <constraint>

### Shipped epics
- Epic <n> — <name>  ✅ <m> stories
- ...

### Open backlog (from construction plan)
- [ ] <item>
- [ ] <item>

### Open verification questions
- <one-liner per question, or "none">

### Recent audit entries
- <date>: <one-line gist>
- <date>: <one-line gist>

### Doc/code drift signals
- <only include if you notice obvious drift while reading; otherwise "none detected"
```

## Rules
- **Read-only.** Do not call Edit, Write, or any tool that mutates the repo. `flutter analyze` is allowed because it does not modify files; skip it if it would be slow.
- **No invention.** If a section is empty in the source files, say so explicitly — do not paraphrase from memory.
- **Brevity.** The whole report should fit on one screen. Cut anything that doesn't change action.
- **Link paths.** Use `[path](path)` markdown links for any file you reference so the user can jump straight there.
