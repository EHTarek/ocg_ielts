# Personas

## 1. The IELTS Candidate (Primary, only end-user persona)
- **Profile:** Self-study learner preparing for the IELTS exam, using a personal Android (and eventually iOS) device.
- **Goals:**
  - Read the Official Cambridge Guide PDF on the go (offline-capable).
  - Practise listening with the bundled Cambridge audio tracks (`Cam01`…`Cam0N` MP3s on Cloudinary).
  - Watch lesson videos (`Cam_VIDEO_01`…`Cam_VIDEO_0N` MP4s on Cloudinary) for technique walkthroughs.
- **Pain points:**
  - Wants to start studying within seconds of opening the app — hence no auth / no onboarding.
  - Needs to jump between the book and a related listening clip without losing place — addressed by `MediaBottomSheet` inside the PDF reader.
  - Expects standard player controls: play/pause, scrub, ±10 s skip on audio; fullscreen + scrub on video.

## 2. Release Engineer (Internal)
- **Profile:** Maintainer who tags a release.
- **Workflow:** Pushes a `v*` tag → GitHub Actions builds a release APK with Flutter 3.41.1 stable → APK is attached to a GitHub Release. No manual signing step at present (default debug signing for the APK artifact).
- **Pain points:** No iOS pipeline yet; no automated tests gate the release.

## Out of scope
There is **no** authenticated user, **no** content-author persona, and **no** backend service in the current architecture. Earlier docs referenced Supabase-backed accounts and FCM notifications — those personas were aspirational and do not match the shipping code.
