import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/media_provider.dart';
import 'video_player_screen.dart';

class VideoListScreen extends ConsumerWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoListAsync = ref.watch(videoListProvider);

    return videoListAsync.when(
      data: (videoList) {
        final scheme = Theme.of(context).colorScheme;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videoList.length,
          itemBuilder: (context, index) {
            final item = videoList[index];
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
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.movie_outlined,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  'Lesson ${item.sl}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item.file,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: Icon(
                  Icons.play_circle_outline,
                  size: 32,
                  color: scheme.primary,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        playlist: videoList,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
