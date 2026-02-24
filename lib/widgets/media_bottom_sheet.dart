import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/media_provider.dart';
import '../screens/video_player_screen.dart';
import 'audio_player_widget.dart';

class MediaBottomSheet extends ConsumerWidget {
  const MediaBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.maxFinite,
              margin: EdgeInsets.fromLTRB(12, 8, 12, 0),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.zero,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: const [
                  Tab(text: "Audio"),
                  Tab(text: "Video"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(children: [_AudioListTab(), _VideoListTab()]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioListAsync = ref.watch(audioListProvider);

    return audioListAsync.when(
      data: (audioList) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: audioList.length,
        itemBuilder: (context, index) {
          final item = audioList[index];
          return ListTile(
            leading: Icon(
              Icons.audiotrack,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'Track ${item.sl}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item.file, style: GoogleFonts.poppins(fontSize: 12)),
            trailing: const Icon(Icons.play_circle_fill),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AudioPlayerWidget(item: item),
              );
            },
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _VideoListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoListAsync = ref.watch(videoListProvider);

    return videoListAsync.when(
      data: (videoList) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          final item = videoList[index];
          return ListTile(
            leading: Icon(
              Icons.movie_outlined,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              'Lesson ${item.sl}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item.file, style: GoogleFonts.poppins(fontSize: 12)),
            trailing: const Icon(Icons.play_circle_outline),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(item: item),
                ),
              );
            },
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
