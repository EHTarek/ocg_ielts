# Requirement Verification Questions

These questions are open against the current implementation (`lib/` as of 2026-05-13). Each one corresponds to behaviour that is *not* fixed by the code today.

1. **Offline / error handling for streaming media.**
   - `VideoPlayerScreen` and `AudioPlayerWidget` show only a spinner while initialising and have no timeout. What is the desired UX when Cloudinary is unreachable — inline error with retry, snackbar, or auto-pop the route?
   - [Answer]:

2. **Catalog source of truth.**
   - The audio/video catalog is shipped as `assets/jsons/{audio,video}.json` and updates require an app release. Is that intentional, or should the JSON eventually be fetched from a remote URL?
   - [Answer]:

3. **Localization coverage.**
   - `AppLocalizations` currently exposes only `appTitle` and `appDescription`, but most user-facing copy ("Read Study Book", "View Resources", "Track {n}", "Lesson {n}", splash title, etc.) is hard-coded. Do we want to lift all of these into ARB now, or defer until a second locale is requested?
   - [Answer]:

4. **Nested bottom sheets in the PDF reader.**
   - Tapping an audio entry from inside `MediaBottomSheet` (opened on top of the PDF) calls `showModalBottomSheet` again, stacking a second sheet over the first. Is this acceptable, or should we replace the inner sheet rather than stack?
   - [Answer]:

5. **Display labels.**
   - List items are labelled `Track ${sl}` / `Lesson ${sl}` with the Cloudinary filename shown as subtitle. Should friendlier human-readable titles be added to the JSON schema (e.g. a `title` field on `MediaItem`)?
   - [Answer]:

6. **Background audio.**
   - `audioplayers` is configured with defaults — no foreground service, no media-session integration. Should audio continue playing when the app is backgrounded or the screen is locked?
   - [Answer]:

7. **iOS release pipeline.**
   - The GitHub Actions workflow builds an Android APK only. Is an iOS/TestFlight pipeline in scope?
   - [Answer]:
