# Requirements

## 1. Executive Summary
The goal of the **OCG IELTS** project is to serve students preparing for the IELTS exams by delivering seamless multi-modal educational resources directly to their mobile devices. The core focus is reliable access to text (PDFs), sound (Audio Tracks), and visual (Videos) content managed locally via Riverpod state.

## 2. Functional Requirements
1. **Landing Hub:** The app must present a primary entry point allowing selection between varying resource types.
2. **Video Delivery:** Must render video lists and present a unified player (Chewie) for video consumption.
3. **Audio Delivery:** Must feature a dedicated audio playback widget with standardized controls (Play, Pause, Progress).
4. **PDF Engine:** Must support large document rendering via Syncfusion to display IELTS exams.
5. **Global State Control:** A bottom sheet (`media_bottom_sheet.dart`) must allow contextual media interactions while navigating lists.

## 3. Non-Functional Requirements (NFRs)
1. **State Preservation:** Media states (like video playing position or currently buffered audio) must not be unnecessarily wiped when transitioning between the media list and the reader view.
2. **Platform Native Feel:** iOS and Android codecs must be cleanly integrated without visual tearing on device rotation.
3. **Media Lifecycle:** OS-level audio interruptions (phone calls, backgrounding) must appropriately mute or pause the `chewie` and `audioplayers` instances to prevent resource leaks.

## 4. Acceptance Criteria
- All routes mapped from `landing_screen.dart` load successfully.
- Media provider handles rapid component mounts/dismounts gracefully without crashing the engine.
