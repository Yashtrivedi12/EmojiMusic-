import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:provider/provider.dart';
import 'AppState.dart';
import 'PlayIng Pages/nowplayingpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  final assetsAudioPlayer = AssetsAudioPlayer();
  TextEditingController searchController = TextEditingController();
  final double _currentPosition = 0.0;
  final double _totalDuration = 1.0;
  List<MusicData> searchResults = []; // Store search results

  void playSong(MusicData song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NowPlayingPage(
          title: song.title,
          path: song.path,
          subtitle: song.subtitle,
          playlists: [],
          file: 'song.file',
          docId: '',
        ),
      ),
    );
  }

  // Function to filter the music list based on the search input
  void filterMusicList(String query, AppState appState) {
    final List<MusicData> musicList = appState.musicList;
    final List<MusicData> filteredList = musicList
        .where((song) =>
            song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.subtitle.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      searchResults = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>(); // Access the app state
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(192, 0, 0, 0),
        child: Column(
          children: [
            const SizedBox(
              width: 20,
            ),
            Container(
              margin: const EdgeInsets.only(top: 40, right: 20, left: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                        child: TextField(
                      controller: searchController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search Musics...',
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    )),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      // Call the filterMusicList function when the search button is pressed
                      filterMusicList(
                          searchController.text, context.read<AppState>());
                    },
                    child: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            Expanded(
              child: searchResults.isEmpty
                  ? Consumer<AppState>(
                      builder: (context, appState, _) {
                        List<MusicData> musicList = appState.musicList;
                        return ListView.builder(
                          itemCount: musicList.length,
                          itemBuilder: (context, index) {
                            final song = musicList[index];
                            // bool isFavorite = appState.isFavorite(song.path);

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 190, 137, 134),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 29, 25, 25),
                                ),
                                shape: BoxShape.rectangle,
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.music_note,
                                  color: Colors.black,
                                  size: 30,
                                ),
                                title: Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  song.subtitle,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 75, 75),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  playSong(song);
                                },
                              ),
                            );
                          },
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final song = searchResults[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 190, 137, 134),
                            border: Border.all(
                              color: const Color.fromARGB(255, 29, 25, 25),
                            ),
                            shape: BoxShape.rectangle,
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.music_note,
                              color: Colors.black,
                              size: 30,
                            ),
                            title: Text(
                              song.title,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              song.subtitle,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 75, 75),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              playSong(song);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


// class MusicPage extends StatefulWidget {
//   const MusicPage({Key? key});

//   @override
//   State<MusicPage> createState() => _MusicPageState();
// }

// class _MusicPageState extends State<MusicPage> {
//   final assetsAudioPlayer = AssetsAudioPlayer();
//   TextEditingController searchController = TextEditingController();
//   final double _currentPosition = 0.0;
//   final double _totalDuration = 1.0;

//   void playSong(MusicData song) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NowPlayingPage(
//           title: song.title,
//           path: song.path,
//           subtitle: song.subtitle,
//           playlists: [],
//         ),
//       ),
//     );
//   }

//   // Function to filter the music list based on the search input
//   void filterMusicList(String query, AppState appState) {
//     final List<MusicData> musicList = appState.musicList;
//     final List<MusicData> filteredList = musicList
//         .where((song) =>
//             song.title.toLowerCase().contains(query.toLowerCase()) ||
//             song.subtitle.toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     setState(() {
//       // Update the searchResults with filteredList
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: const Color.fromARGB(192, 0, 0, 0),
//         child: Column(
//           children: [
//             SizedBox(width: 20),
//             Container(
//               margin: EdgeInsets.only(top: 40, right: 20, left: 20),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       child: TextField(
//                         controller: searchController,
//                         style: TextStyle(
//                           color: Colors.white,
//                         ),
//                         decoration: InputDecoration(
//                           hintText: 'Search Musics...',
//                           border: InputBorder.none,
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(20),
//                             ),
//                             borderSide: BorderSide(
//                               color: Colors.blue,
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(20),
//                             ),
//                             borderSide: BorderSide(
//                               color: Colors.blue,
//                             ),
//                           ),
//                           hintStyle: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8.0),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 20.0,
//                         vertical: 12.0,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50.0),
//                       ),
//                       elevation: 5,
//                     ),
//                     onPressed: () {
//                       // Call the filterMusicList function when the search button is pressed
//                       filterMusicList(
//                           searchController.text, context.read<AppState>());
//                     },
//                     child: Icon(Icons.search),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream:
//                     FirebaseFirestore.instance.collection('Music').snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return Center(
//                       child: CircularProgressIndicator(),
//                     );
//                   } else {
//                     // Extract the list of music data from the snapshot
//                     // Update the ListView with the necessary logic
//                     return ListView.builder(
//                       itemCount: snapshot.data!.docs.length,
//                       itemBuilder: (context, index) {
//                         DocumentSnapshot document = snapshot.data!.docs[index];
//                         String title = document['name'];
//                         String subtitle = document['subtitle'];
//                         String path = document['file'];

//                         MusicData musicData = MusicData(
//                           title: title,
//                           subtitle: subtitle,
//                           path: path,
//                         );

//                         return ListTile(
//                           leading: Icon(Icons.music_note),
//                           title: Text(title),
//                           subtitle: Text(subtitle),
//                           onTap: () {
//                             playSong(musicData);
//                           },
//                         );
//                       },
//                     );
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
