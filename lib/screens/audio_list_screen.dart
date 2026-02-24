import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/media_provider.dart';
import '../widgets/audio_player_widget.dart';

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
