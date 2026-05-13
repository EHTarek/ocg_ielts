import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../l10n/app_localizations.dart';
import '../models/media_item.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<MediaItem> playlist;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.playlist,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late int _currentIndex;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _initStarted = false;
  Color _accent = Colors.red;

  MediaItem get _currentItem => widget.playlist[_currentIndex];
  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.playlist.length - 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accent = Theme.of(context).colorScheme.primary;
    if (!_initStarted) {
      _initStarted = true;
      _initializePlayer();
    }
  }

  ChewieProgressColors _progressColors() => ChewieProgressColors(
    playedColor: _accent,
    handleColor: _accent,
    backgroundColor: Colors.white.withValues(alpha: 0.15),
    bufferedColor: Colors.white.withValues(alpha: 0.45),
  );

  Future<void> _initializePlayer() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_currentItem.link),
    );
    _videoPlayerController = controller;
    await controller.initialize();
    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        materialProgressColors: _progressColors(),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );
    });
  }

  Future<void> _goToIndex(int newIndex) async {
    if (newIndex < 0 || newIndex >= widget.playlist.length) return;
    final oldVideo = _videoPlayerController;
    final oldChewie = _chewieController;
    setState(() {
      _currentIndex = newIndex;
      _videoPlayerController = null;
      _chewieController = null;
    });
    oldChewie?.dispose();
    await oldVideo?.dispose();
    await _initializePlayer();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chewie = _chewieController;
    final ready =
        chewie != null && chewie.videoPlayerController.value.isInitialized;
    // Cinema convention: keep the scaffold black + white icons regardless of
    // app theme so the video itself is the focus. The Chewie progress bar
    // picks up the active palette via _accent so a palette switch is visible.
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: l10n.playerPrevious,
            icon: const Icon(Icons.skip_previous),
            onPressed: _hasPrevious
                ? () => _goToIndex(_currentIndex - 1)
                : null,
          ),
          IconButton(
            tooltip: l10n.playerNext,
            icon: const Icon(Icons.skip_next),
            onPressed: _hasNext ? () => _goToIndex(_currentIndex + 1) : null,
          ),
        ],
      ),
      body: Center(
        child: ready
            ? Chewie(controller: chewie)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
