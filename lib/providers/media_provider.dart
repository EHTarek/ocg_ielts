import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_item.dart';

final audioListProvider = FutureProvider<List<MediaItem>>((ref) async {
  final String response = await rootBundle.loadString(
    'assets/jsons/audio.json',
  );
  final List<dynamic> data = json.decode(response);
  return data.map((item) => MediaItem.fromJson(item)).toList();
});

final videoListProvider = FutureProvider<List<MediaItem>>((ref) async {
  final String response = await rootBundle.loadString(
    'assets/jsons/video.json',
  );
  final List<dynamic> data = json.decode(response);
  return data.map((item) => MediaItem.fromJson(item)).toList();
});
