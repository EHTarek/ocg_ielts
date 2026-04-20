# Build Instructions

## Prerequisites
- **Flutter SDK:** ^3.11.0
- **Platform Targets:** iOS (requires Xcode), Android (requires Android Studio)
- **Environment:** Supabase environment variables must be loaded into `.env` or matched to the current config.

## Local Execution
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Build iOS:
   ```bash
   flutter build ios --release
   ```
3. Build Android:
   ```bash
   flutter build apk --release
   ```

## Unit Test Execution
- Currently, tests are initialized via:
  ```bash
  flutter test
  ```
