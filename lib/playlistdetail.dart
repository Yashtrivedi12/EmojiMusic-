import 'package:flutter/material.dart';

class PlaylistDetailPage extends StatelessWidget {
  final String playlistName;

  PlaylistDetailPage({
    required this.playlistName, required List songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          playlistName,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color.fromARGB(192, 0, 0, 0),
        child: ListView.builder(
          // itemCount: songs.length,
          itemBuilder: (context, index) {
            return const ListTile(
                // title: Text(songs[index]),
                );
          },
        ),
      ),
    );
  }
}
