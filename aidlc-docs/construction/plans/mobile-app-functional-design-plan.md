# Functional Design Plan: mobile-app

This plan dictates the structural and behavioral logic mapping for the Flutter mobile application unit (`ocg_ielts`).

## Core Objectives
1. Formulate exact data structures for `MediaItem` consumption.
2. Outline specific widget trees for complex screens (`pdf_view`, `video_player`).
3. Define strict interaction patterns (gestures, background states).

## Required Details
- **Media Definitions:** We must define how audio, video, and PDFs vary in the provider.
- **Provider Architecture:** Which states are asynchronous streams versus simple variable watchers.

## User Questions
- Does `pdf_view` require an embedded annotation or highlighting system?
  - [Answer]:
