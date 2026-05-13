import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/media_item.dart';

class AudioPlayerWidget extends StatefulWidget {
  final List<MediaItem> playlist;
  final int initialIndex;

  const AudioPlayerWidget({
    super.key,
    required this.playlist,
    required this.initialIndex,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  late int _currentIndex;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  MediaItem get _currentItem => widget.playlist[_currentIndex];
  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.playlist.length - 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    await _audioPlayer.setSourceUrl(_currentItem.link);
  }

  Future<void> _goToIndex(int newIndex) async {
    if (newIndex < 0 || newIndex >= widget.playlist.length) return;
    await _audioPlayer.stop();
    setState(() {
      _currentIndex = newIndex;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    await _audioPlayer.play(UrlSource(_currentItem.link));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Track ${_currentItem.sl}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                _currentItem.file,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Slider(
                value: _position.inMilliseconds.toDouble().clamp(
                  0.0,
                  _duration.inMilliseconds.toDouble() > 0
                      ? _duration.inMilliseconds.toDouble()
                      : 1.0,
                ),
                max: _duration.inMilliseconds.toDouble() > 0
                    ? _duration.inMilliseconds.toDouble()
                    : 1.0,
                onChanged: (value) {
                  _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_position)),
                    Text(_formatDuration(_duration)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: l10n.playerPrevious,
                    icon: const Icon(Icons.skip_previous, size: 32),
                    onPressed: _hasPrevious
                        ? () => _goToIndex(_currentIndex - 1)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_10, size: 32),
                    onPressed: () {
                      final newPos = _position - const Duration(seconds: 10);
                      _audioPlayer.seek(
                        newPos < Duration.zero ? Duration.zero : newPos,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.large(
                    onPressed: () {
                      if (_playerState == PlayerState.playing) {
                        _audioPlayer.pause();
                      } else {
                        _audioPlayer.play(UrlSource(_currentItem.link));
                      }
                    },
                    child: Icon(
                      _playerState == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.forward_10, size: 32),
                    onPressed: () {
                      final newPos = _position + const Duration(seconds: 10);
                      _audioPlayer.seek(
                        newPos > _duration ? _duration : newPos,
                      );
                    },
                  ),
                  IconButton(
                    tooltip: l10n.playerNext,
                    icon: const Icon(Icons.skip_next, size: 32),
                    onPressed: _hasNext
                        ? () => _goToIndex(_currentIndex + 1)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
