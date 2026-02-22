import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/media_item.dart';
import '../providers/media_provider.dart';

class AudioListScreen extends ConsumerWidget {
  const AudioListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioListAsync = ref.watch(audioListProvider);

    return audioListAsync.when(
      data: (audioList) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: audioList.length,
        itemBuilder: (context, index) {
          final item = audioList[index];
          return Card(
            elevation: 4,
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.audiotrack,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                'Track ${item.sl}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                item.file,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              trailing: const Icon(Icons.play_circle_fill, size: 40),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AudioPlayerWidget(item: item),
                );
              },
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final MediaItem item;

  const AudioPlayerWidget({super.key, required this.item});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
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
    await _audioPlayer.setSourceUrl(widget.item.link);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Track ${widget.item.sl}',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.item.file,
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, size: 36),
                onPressed: () {
                  final newPos = _position - const Duration(seconds: 10);
                  _audioPlayer.seek(
                    newPos < Duration.zero ? Duration.zero : newPos,
                  );
                },
              ),
              const SizedBox(width: 24),
              FloatingActionButton.large(
                onPressed: () {
                  if (_playerState == PlayerState.playing) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play(UrlSource(widget.item.link));
                  }
                },
                child: Icon(
                  _playerState == PlayerState.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.forward_10, size: 36),
                onPressed: () {
                  final newPos = _position + const Duration(seconds: 10);
                  _audioPlayer.seek(newPos > _duration ? _duration : newPos);
                },
              ),
            ],
          ),
        ],
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
