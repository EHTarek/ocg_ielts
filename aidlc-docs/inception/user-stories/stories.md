# User Stories

## EPICS
- **Epic 1:** Media Hub Navigation
- **Epic 2:** Interactive Document Study
- **Epic 3:** Audio/Video Playback Management

## Active Stories
1. **As an** IELTS student, **I want to** select my path from a landing screen, **so that** I can easily access videos, audios, or reading materials without confusion.
   - **Acceptance Criteria:** `landing_screen.dart` correctly pushes the respective media list routes.

2. **As an** IELTS student, **I want to** seamlessly read PDF materials via a dedicated view, **so that** I can practice the reading section or review grammar guides.
   - **Acceptance Criteria:** `pdf_view_screen.dart` allows zooming and scrolling over complex page setups reliably.

3. **As an** IELTS student, **I want to** play listening test tracks and video tutorials, **so that** I can train my comprehension skills.
   - **Acceptance Criteria:** The `audio_player_widget.dart` and `video_player_screen.dart` must properly load streams, display duration/progress, and handle backgrounding smoothly.
