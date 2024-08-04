import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:musicapp_/search%20Page/search.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

// ignore: use_key_in_widget_constructors
class FavoritePage extends StatefulWidget {
  final String userEmail;

  const FavoritePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: const Color(0xFF0c091c),
          elevation: 0,
          title: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Icon(size: 28, Icons.favorite, color: Colors.red),
                SizedBox(
                  height: 10,
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favorite Songs',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                          fontSize: 20),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Let\'s listen your favorite songs',
                      style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: Colors.white54,
                          fontSize: 12),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF0c091c),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return const FractionallySizedBox(
                          heightFactor: 1.0, // Adjust the factor as needed
                          child: newpage());
                    },
                  );
                },
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blueAccent,
                        Colors.blue,
                        Colors.lightBlue,
                        Colors.lightBlueAccent,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(
                            0.3), // Adjust the opacity for a lighter or darker shadow
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Lottie.asset('assets/like.json', height: 50),
                          Text(
                            'Favorite Song',
                            style: GoogleFonts.aBeeZee(
                              textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: .5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class newpage extends StatefulWidget {
  const newpage({super.key});

  @override
  State<newpage> createState() => _newpageState();
}

class _newpageState extends State<newpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1a1b1f),
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFFFFFFF),
              )),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Your Favorite Songs Is Here',
            style: GoogleFonts.aBeeZee(
              textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .5),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Center(
              child: Consumer<FavoriteModel>(
                builder: (context, favoriteModel, child) {
                  List<String> favoriteSongs = favoriteModel.favoriteSongs;
                  List<MusicData> allMusicData = favoriteModel.allMusicData;

                  return ListView.builder(
                    itemCount: favoriteSongs.length,
                    itemBuilder: (BuildContext context, int index) {
                      String docId = favoriteSongs[index];

                      // Find the corresponding MusicData in allMusicData
                      MusicData? favoriteSong = allMusicData.firstWhereOrNull(
                        (music) => music.docId == docId,
                      );

                      if (favoriteSong != null) {
                        return SongItem(
                          title: favoriteSong.title,
                          subtitle: favoriteSong.subtitle,
                          path: favoriteSong.path,
                          file: favoriteSong.file,
                          docId: favoriteSong.docId,
                          isFavorite: true,
                          onToggleFavorite: (isFavorite) {
                            Provider.of<FavoriteModel>(context, listen: false)
                                .toggleFavorite(favoriteSong.docId);
                          },
                        );
                      } else {
                        Provider.of<FavoriteModel>(context, listen: false)
                            .toggleFavorite(docId);

                        // return SizedBox.shrink();
                      }
                      return null;
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
