import 'package:flutter/material.dart';
import 'audio_list_screen.dart';
import 'video_list_screen.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Container(
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
        ),
        body: TabBarView(children: [AudioListScreen(), VideoListScreen()]),
      ),
    );
  }
}
