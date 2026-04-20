# Application Design

## 1. High-Level Architecture
- **Layered UI & State:** The application separates view code (`lib/screens` and `lib/widgets`) from state logic (`lib/providers`). 
- **Riverpod Implementation:** Uses `media_provider.dart` to maintain the central state of loaded media, ensuring that audio/video streaming remains consistent across screen navigation via `media_bottom_sheet.dart` or active players.

## 2. Resource Mapping
- Data is modeled by `MediaItem.dart` which acts as the uniform contract for all viewable content types.
- The `landing_screen.dart` determines the branch of resource consumption, leading users to video hubs, audio lists, or the PDF reading interface.

## 3. Technology Choices
- **Flutter:** Mobile cross-platform rendering.
- **Chewie & AudioPlayers:** Robust packages for handling the underlying OS-level audio/video codecs on iOS and Android.
- **Syncfusion PDF:** Efficient document rendering that allows students to smoothly read dense test materials and IELTS curriculum without leaving the app.
