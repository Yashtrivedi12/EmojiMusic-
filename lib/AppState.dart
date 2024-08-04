import 'package:flutter/material.dart';
import 'package:musicapp_/PlayIng%20Pages/nowplayingpage.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';

class MusicData {
  final String title;
  final String path;
  final String subtitle;

  MusicData(String readString, {
    required this.title,
    required this.path,
    required this.subtitle, required String file,
  });
}

class AppState extends ChangeNotifier {
  List<MusicData> _favoriteSongs = [];
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  AppState(AssetsAudioPlayer assetsAudioPlayer);

  List<MusicData> _musicList = []; // Add this line

  List<MusicData> get musicList => _musicList;

  List<MusicData> get favoriteSongs => _favoriteSongs;
}

// in AppState.dart
