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
└── Scaffold (AppBar with trailing IconButton(Icons.settings) → push(SettingsScreen))
    └── Padding(24) → Column
        ├── Container(circle blue) → Icon(Icons.auto_stories, white)
        ├── Text("What would you like to do today?", Poppins 20 w600 grey800)
        ├── _buildOptionCard("Read Study Book", menu_book_rounded, primary)
        │     onTap → push(PDFViewScreen())
        └── _buildOptionCard("View Resources", play_lesson_rounded, #FACC15, iconColor: primary)
              onTap → push(ResourcesScreen)
```
- Card colours pull from `Theme.of(context).colorScheme.primary` so they re-tint when the user changes accent palette.

## Settings
```
SettingsScreen (ConsumerWidget)
└── Scaffold(AppBar(title: 'Settings'))
    └── ListView
        ├── Section header: 'Appearance'
        ├── SegmentedButton<ThemeMode> [Light | Dark | System]
        │     onSelectionChanged → ref.read(themeSettingsProvider.notifier).setMode(...)
        ├── Section header: 'Accent colour'
        ├── Row of three palette swatches (CircleAvatar + label) with selected ring
        │     onTap → ref.read(themeSettingsProvider.notifier).setPalette(...)
        ├── Section header: 'Preview'
        ├── Preview Card
        │     ├── Filled button (primary)
        │     ├── Outlined button (primary)
        │     └── Sample text using textTheme
        ├── Section header: 'About & Legal'
        ├── Card → Column of ListTile rows
        │     ├── ListTile(privacy_tip)        → _openLegal(privacyPolicy, LegalTexts.privacyPolicy)
        │     ├── ListTile(description)        → _openLegal(termsOfService, LegalTexts.termsOfService)
        │     ├── ListTile(workspace_premium)  → showLicensePage(...)
        │     ├── ListTile(mail_outline)       → _emailSupport()
        │     ├── ListTile(star_outline)       → _openUrl(playStoreUrl)
        │     └── ListTile(share)              → _shareApp(playStoreUrl)
        └── Footer
              Text('OCG IELTS — <version> (<build>)') from packageInfoProvider
```
- Selected states are visualised with a `CircleAvatar` border in `colorScheme.primary`.
- The preview card is wrapped in a `Theme` widget that simply uses the inherited theme so any change reflows instantly.
- All About & Legal handlers funnel through one `_openUrl` helper, so the placeholder-URL guard rail is enforced in a single place.
- The version footer reads `ref.watch(packageInfoProvider).when(data: ..., loading: '…', error: '—')`.

## Legal document viewer
```
LegalDocumentScreen (Stateless, required title + body)
└── Scaffold(AppBar(title))
    └── SafeArea → SingleChildScrollView(padding 20/16/20/32)
        └── SelectableText(body, Poppins 14 / line-height 1.55, onSurface)
```
- Used by Settings → Privacy Policy / Terms of Service. The body is a Dart constant from `LegalTexts`.

## Theming contract (applies everywhere below)
- All container backgrounds, label colours, icon colours, indicator colours, and shadow tints come from `Theme.of(context).colorScheme.*` — never hard-coded `Colors.white/black/grey[300]/0xFFE5E7EB`.
- `surface` / `onSurface` are read for plain backgrounds + body text. `surfaceContainerHighest` for "pill" backgrounds (tab strips). `primary` for selected/active accent; `onPrimary` for foreground on a primary fill. `secondaryContainer` / `onSecondaryContainer` for the LandingScreen second card (replaces the hard-coded yellow). `outlineVariant` for thin separators and drag-handle pills.
- Dark theme: see `main.dart::_schemeFor` — `contrastLevel: -0.3` plus softened surface tones so the night UI is a mild near-charcoal, not near-black.

## Resources Hub
```
ResourcesScreen (Stateless)
└── DefaultTabController(length: 2)
    └── Scaffold
        ├── AppBar(title: rounded pill TabBar [Audio | Video])
        │     ├── pill bg:  surfaceContainerHighest
        │     ├── indicator: primary  (white text on primary)
        │     ├── label:    onPrimary
        │     └── unselected: onSurface
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

AudioPlayerWidget (Stateful, required playlist + initialIndex)
└── Container(top-rounded surface, no fixed height)
    └── SafeArea(top:false) → Padding(24,12,24,24)
        └── Column(mainAxisSize:min)        // grows with content
            ├── drag-handle (outlineVariant)
            ├── Text('Track ${_currentItem.sl}', Poppins 24 bold, onSurface)
            ├── Text(_currentItem.file, onSurfaceVariant, maxLines:2, ellipsis)
            ├── Slider(value: clamp(position, 0, max(1, duration_ms)))
            ├── Row [position MM:SS, duration MM:SS]
            └── Row [IconButton(skip_previous, disabled iff _currentIndex == 0),
                     IconButton(replay_10),
                     FloatingActionButton.large(play/pause),
                     IconButton(forward_10),
                     IconButton(skip_next, disabled iff _currentIndex == playlist.length - 1)]
```
- Tapping `skip_previous` / `skip_next` calls `_goToIndex(±1)` which stops the current track, resets position/duration, swaps the source, and auto-plays the neighbour.
- No fixed sheet height: the `Column(mainAxisSize.min)` sizes to its children and `SafeArea(top:false)` extends the bottom padding past the gesture inset on devices that have one.

## Video list & player
```
VideoListScreen (ConsumerWidget)
└── ref.watch(videoListProvider).when(
      data → ListView.builder
              └── Card → ListTile(movie_outlined, Lesson ${sl}, file, play_circle_outline)
                    onTap → Navigator.push(VideoPlayerScreen(item: item))
      loading/error → as above)

VideoPlayerScreen (Stateful, required playlist + initialIndex)
└── Scaffold (black, transparent AppBar, white icons)
    ├── AppBar(actions: [
    │     IconButton(skip_previous, disabled iff _currentIndex == 0)        → _goToIndex(_currentIndex - 1),
    │     IconButton(skip_next,     disabled iff _currentIndex == last)     → _goToIndex(_currentIndex + 1),
    │   ])
    └── Center → either Chewie(controller) when initialised
                  or CircularProgressIndicator()
```
- `ChewieController(autoPlay: true, looping: false, aspectRatio: _videoPlayerController.value.aspectRatio, materialProgressColors: red/grey/white70, autoInitialize: true)`.
- `_goToIndex(int)` disposes both controllers, nulls `_chewieController` so the spinner re-appears, advances `_currentIndex`, and re-runs `_initializePlayer()` against the new `_currentItem`.
- `dispose()` releases `_videoPlayerController` and `_chewieController`.

## PDF reader & inline media sheet
```
PDFViewScreen (Stateful, no required parameters)
└── Scaffold
    ├── AppBar(actions: IconButton(menu) → showModalBottomSheet → MediaBottomSheet())
    ├── body: AnimatedSwitcher / switch over _state
    │     ├── checking        → CircularProgressIndicator
    │     ├── needsDownload   → Card
    │     │                     ├── Icon(cloud_download_outlined)
    │     │                     ├── Text(downloadBookTitle, headlineSmall)
    │     │                     ├── Text(downloadBookMessage, bodyMedium)
    │     │                     └── FilledButton.icon(download) onPressed → _startDownload()
    │     ├── downloading     → Card
    │     │                     ├── Text(downloadBookProgressTitle)
    │     │                     ├── LinearProgressIndicator(value: _total != null ? _received / _total : null)
    │     │                     └── Text('${MB(_received)} / ${MB(_total)}' or 'MB(_received)' if total unknown)
    │     ├── error           → Card
    │     │                     ├── Icon(error_outline)
    │     │                     ├── Text(downloadFailedTitle, headlineSmall)
    │     │                     ├── Text('$_error', bodyMedium)
    │     │                     └── FilledButton.tonalIcon(refresh) onPressed → _startDownload()
    │     └── ready           → SfPdfViewer.file(_localFile!, controller, key, interactionMode: pan)
    └── floatingActionButton: (only when _state == ready) Column
        ├── FAB(mini, heroTag: 'prev', icon: keyboard_arrow_up) → controller.previousPage()
        └── FAB(mini, heroTag: 'next', icon: keyboard_arrow_down) → controller.nextPage()

MediaBottomSheet (ConsumerWidget)
└── Container(70% height, top-rounded white)
    └── DefaultTabController(length: 2) → Column
        ├── drag-handle
        ├── rounded pill TabBar [Audio | Video]
        └── Expanded → TabBarView([_AudioListTab, _VideoListTab])
              _AudioListTab → ListTile → showModalBottomSheet → AudioPlayerWidget(playlist: audioList, initialIndex: index)
              _VideoListTab → ListTile → Navigator.push(VideoPlayerScreen(playlist: videoList, initialIndex: index))
```
