# Frontend Components: mobile-app

The widget tree is intentionally shallow — every flow is at most three pushes deep from `LandingScreen`.

## Splash
```
SplashScreen (Stateful + SingleTickerProviderStateMixin)
└── Scaffold (#1E3A8A background)
    └── Center → FadeTransition(opacity: easeIn 2s)
        └── Padding → Column
            ├── Container(circle, white) → Icon(Icons.auto_stories)
            └── Text("The Official Cambridge Guide to IELTS", Poppins 32 bold white)
```
- `Future.delayed(3 s)` → `Navigator.pushReplacement(LandingScreen)`.

## Landing
```
LandingScreen (Stateless)
└── Scaffold (centered empty AppBar)
    └── Padding(24) → Column
        ├── Container(circle blue) → Icon(Icons.auto_stories, white)
        ├── Text("What would you like to do today?", Poppins 20 w600 grey800)
        ├── _buildOptionCard("Read Study Book", menu_book_rounded, #1E3A8A)
        │     onTap → push(PDFViewScreen(assetPath: 'assets/pdfs/book.pdf'))
        └── _buildOptionCard("View Resources", play_lesson_rounded, #FACC15, iconColor: #1E3A8A)
              onTap → push(ResourcesScreen)
```
- Each card is a rounded `Card` (radius 24, elevation 8) with a colored `Container`, a circular icon badge, and two stacked `Text`s for title/subtitle.

## Resources Hub
```
ResourcesScreen (Stateless)
└── DefaultTabController(length: 2)
    └── Scaffold
        ├── AppBar(title: rounded pill TabBar [Audio | Video])
        └── TabBarView(children: [AudioListScreen(), VideoListScreen()])
```

## Audio list & player
```
AudioListScreen (ConsumerWidget)
└── ref.watch(audioListProvider).when(
      data → ListView.builder
              └── Card → ListTile(audiotrack, Track ${sl}, file, play_circle_fill)
                    onTap → showModalBottomSheet → AudioPlayerWidget(item: item)
      loading → CircularProgressIndicator
      error  → Text('Error: $err'))

AudioPlayerWidget (Stateful)
└── Container(350h, top-rounded white)
    └── Column
        ├── drag-handle
        ├── Text('Track ${sl}', Poppins 24 bold)
        ├── Text(item.file, grey)
        ├── Slider(value: clamp(position, 0, max(1, duration_ms)))
        ├── Row [position MM:SS, duration MM:SS]
        └── Row [IconButton(replay_10), FloatingActionButton.large(play/pause), IconButton(forward_10)]
```

## Video list & player
```
VideoListScreen (ConsumerWidget)
└── ref.watch(videoListProvider).when(
      data → ListView.builder
              └── Card → ListTile(movie_outlined, Lesson ${sl}, file, play_circle_outline)
                    onTap → Navigator.push(VideoPlayerScreen(item: item))
      loading/error → as above)

VideoPlayerScreen (Stateful)
└── Scaffold (black, transparent AppBar, white icons)
    └── Center → either Chewie(controller) when initialised
                  or CircularProgressIndicator()
```
- `ChewieController(autoPlay: true, looping: false, aspectRatio: _videoPlayerController.value.aspectRatio, materialProgressColors: red/grey/white70, autoInitialize: true)`.
- `dispose()` releases `_videoPlayerController` and `_chewieController`.

## PDF reader & inline media sheet
```
PDFViewScreen (Stateful, required assetPath)
└── Scaffold
    ├── AppBar(actions: IconButton(menu) → showModalBottomSheet → MediaBottomSheet())
    ├── body: SfPdfViewer.asset(assetPath, controller, key, interactionMode: pan)
    └── floatingActionButton: Column
        ├── FAB(mini, heroTag: 'prev', icon: keyboard_arrow_up) → controller.previousPage()
        └── FAB(mini, heroTag: 'next', icon: keyboard_arrow_down) → controller.nextPage()

MediaBottomSheet (ConsumerWidget)
└── Container(70% height, top-rounded white)
    └── DefaultTabController(length: 2) → Column
        ├── drag-handle
        ├── rounded pill TabBar [Audio | Video]
        └── Expanded → TabBarView([_AudioListTab, _VideoListTab])
              _AudioListTab → ListTile → showModalBottomSheet → AudioPlayerWidget
              _VideoListTab → ListTile → Navigator.push(VideoPlayerScreen)
```
