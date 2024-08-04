import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:musicapp_/AppState.dart';
import 'package:musicapp_/PlayIng%20Pages/nowplayingpage.dart';

class SearchPage extends StatefulWidget {
  final String userEmail;

  const SearchPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _emojiSearchFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _manualSearchFormKey = GlobalKey<FormState>();
  Map<String, List<MusicData>> filteredSongsMap = {};
  TextEditingController _emojiKeyboard = TextEditingController();
  TextEditingController _manualKeyboard = TextEditingController();
  List<MusicData> emojiSearchList = [];
  List<MusicData> manualSearchList = [];
  late AppState appState;
  int filteredSongsIndex = 0;
  bool _hasPerformedSearch = false;
  bool showClearIcon = false;
  late TabController _tabController;
  List<MusicData> fullMusicList = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appState = Provider.of<AppState>(context,
        listen: false); // Initialize appState here
  }

  @override
  void initState() {
    super.initState();
    _hasPerformedSearch = false;
    // Add a listener to the textEditingController to check for changes
    _tabController = TabController(length: 2, vsync: this);
    _emojiKeyboard.addListener(() {
      setState(() {
        // Show the clear icon if the text is not empty
        showClearIcon = _emojiKeyboard.text.isNotEmpty;
      });
    });

    _manualKeyboard.addListener(() {
      setState(() {
        // Show the clear icon if the text is not empty
        showClearIcon = _manualKeyboard.text.isNotEmpty;
      });
    });

    // Fetch and display all inbuilt music with a subtitle initially
    displayAllMusicWithSubtitleInEmojiSeach();
    displayAllMusicWithSubtitleInManualSearch();
    fetchFullMusicList();
  }

  Future<void> fetchFullMusicList() async {
    try {
      fullMusicList = await fetchAllMusic();
    } catch (e) {
      print('Error fetching full music data: $e');
    }
  }

  Future<void> displayAllMusicWithSubtitleInEmojiSeach() async {
    setState(() {
      isLoading = true;
    });

    List<MusicData> musicList = await fetchAllMusic();

    // Update the itemList with all music with a subtitle
    emojiSearchList.clear();
    emojiSearchList.addAll(musicList);

    // Set all music data in the FavoriteModel
    Provider.of<FavoriteModel>(context, listen: false)
        .setAllMusicData(musicList);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> displayAllMusicWithSubtitleInManualSearch() async {
    setState(() {
      isLoading = true;
    });

    List<MusicData> musicList = await fetchAllMusic();

    // Update the itemList with all music with a subtitle
    manualSearchList.clear();
    manualSearchList.addAll(musicList);

    // Set all music data in the FavoriteModel
    Provider.of<FavoriteModel>(context, listen: false)
        .setAllMusicData(musicList);

    setState(() {
      isLoading = false;
    });
  }

  void _showEmojiKeyboard() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          children: [
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (Category? category, Emoji emoji) {
                  String selectedEmoji = '${emoji.emoji}';
                  addEmoji(selectedEmoji);
                },
                config: Config(
                  columns: 7,
                  emojiSizeMax: 32.0,
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _emojiKeyboard.clear();
                  // You don't need to check the condition here
                });
              },
            ),
          ],
        );
      },
    );
  }

  void addEmoji(String selectedEmoji) {
    setState(() {
      _emojiKeyboard.text += selectedEmoji;
    });
  }

  void playSong(MusicData song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NowPlayingPage(
          title: song.title,
          path: song.path,
          subtitle: song.subtitle,
          playlists: [],
          file: song.file,
          docId: song.docId, // Pass the docId to NowPlayingPage
        ),
      ),
    );
  }

  // Future<List<MusicData>> fetchAllMusicWithSubtitle() async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('Music').get();
  //     List<MusicData> musicList = querySnapshot.docs.map((doc) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       return MusicData(
  //         doc.id, // Use document ID as the path
  //         title: data['name'] ?? '', // Provide a default value if null
  //         subtitle: data['subtitle'] ?? '', // Provide a default value if null
  //         file: data['file'] ?? '', // Provide a default value if null
  //         path: data['path'] ?? '', // Provide a default value if null
  //       );
  //     }).toList();

  //     // Filter out the music where subtitle is null or empty
  //     musicList =
  //         musicList.where((music) => music.subtitle.isNotEmpty).toList();

  //     return musicList;
  //   } catch (e) {
  //     print('Error fetching music data: $e');
  //     return []; // Return an empty list or handle the error appropriately
  //   }
  // }

  Future<List<MusicData>> fetchAllMusic() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Music').get();
      List<MusicData> musicList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return MusicData(
          doc.id, // Use document ID as the path
          title: data['name'] ?? '', // Provide a default value if null
          subtitle: data['subtitle'] ?? '', // Provide a default value if null
          file: data['file'] ?? '', // Provide a default value if null
          path: data['path'] ?? '', // Provide a default value if null
        );
      }).toList();

      return musicList;
    } catch (e) {
      print('Error fetching music data: $e');
      return []; // Return an empty list or handle the error appropriately
    }
  }

  List<MusicData> filterSongs(String emoji, List<MusicData> musicList) {
    List<MusicData> filteredSongs;
    if (emoji == '😀' ||
        emoji == '😃' ||
        emoji == '😄' ||
        emoji == '😁' ||
        emoji == '😆' ||
        emoji == '😅' ||
        emoji == '😂' ||
        emoji == '🤣' ||
        emoji == '☺' ||
        emoji == '😊' ||
        emoji == '😇' ||
        emoji == '💩' ||
        emoji == '😺' ||
        emoji == '😸' ||
        emoji == '😹') {
      // return musicList.where((music) => music.subtitle == 'happy').toList();
      filteredSongs =
          musicList.where((music) => music.subtitle == 'happy').toList();
    } else if (emoji == '😠' || emoji == '😡' || emoji == '🤬' || emoji == '👺'
        // emoji == '👿' ||
        // emoji == '😈'
        ) {
      // return musicList.where((music) => music.subtitle == 'angry').toList();
      filteredSongs =
          musicList.where((music) => music.subtitle == 'angry').toList();
    } else if (emoji == '😞' ||
        emoji == '😔' ||
        emoji == '😟' ||
        emoji == '😕' ||
        emoji == '🙁' ||
        emoji == '☹' ||
        emoji == '😣' ||
        emoji == '😖' ||
        emoji == '😫' ||
        emoji == '😩' ||
        emoji == '🥺' ||
        emoji == '😰' ||
        emoji == '😢' ||
        emoji == '😥' ||
        emoji == '😭' ||
        emoji == '😿') {
      // return musicList.where((music) => music.subtitle == 'sad').toList();
      filteredSongs =
          musicList.where((music) => music.subtitle == 'sad').toList();
    } else if (emoji == '😍' ||
        emoji == '🥰' ||
        emoji == '😘' ||
        emoji == '😻' ||
        emoji == '❤' ||
        emoji == '💖' ||
        emoji == '💕' ||
        emoji == '💝' ||
        emoji == '💝' ||
        emoji == '💞') {
      // return musicList.where((music) => music.subtitle == 'love').toList();
      filteredSongs =
          musicList.where((music) => music.subtitle == 'love').toList();
    } else if (emoji == '🚗' ||
        emoji == '🚕' ||
        emoji == '🚙' ||
        emoji == '🚌' ||
        emoji == '🚎' ||
        emoji == '🏎' ||
        emoji == '🚐' ||
        emoji == '🛻' ||
        emoji == '🚚' ||
        emoji == '🚛' ||
        emoji == '🚜' ||
        emoji == '🚲' ||
        emoji == '🚴‍♂' ||
        emoji == '🛵' ||
        emoji == '🏍' ||
        emoji == '🛺' ||
        emoji == '🚍' ||
        emoji == '🚘' ||
        emoji == '🚖' ||
        emoji == '🚃' ||
        emoji == '🚋' ||
        emoji == '🚞' ||
        emoji == '🚝' ||
        emoji == '🚄' ||
        emoji == '🚅' ||
        emoji == '🚈' ||
        emoji == '🚂' ||
        emoji == '🚆' ||
        emoji == '🚇' ||
        emoji == '🚊' ||
        emoji == '🚉' ||
        emoji == '🚁' ||
        emoji == '🛩' ||
        emoji == '✈' ||
        emoji == '🛫' ||
        emoji == '🛬' ||
        emoji == '🚀' ||
        emoji == '🛸' ||
        emoji == '🛰' ||
        emoji == '⛵' ||
        emoji == '🛥' ||
        emoji == '🚤' ||
        emoji == '🛳' ||
        emoji == '⛴' ||
        emoji == '🚢' ||
        emoji == '🚴' ||
        emoji == '🚴‍♂️' ||
        emoji == '🚴‍♀️') {
      // return musicList.where((music) => music.subtitle == 'traveling').toList();
      filteredSongs =
          musicList.where((music) => music.subtitle == 'traveling').toList();
    } else if (emoji == '🥳' ||
        emoji == '🎂' ||
        emoji == '🎉  ' ||
        emoji == '🎊') {
      filteredSongs =
          musicList.where((music) => music.subtitle == 'birthday').toList();
    } else if (emoji == '🇮🇳') {
      filteredSongs =
          musicList.where((music) => music.subtitle == 'india').toList();
    } else if (emoji == '🙏') {
      filteredSongs =
          musicList.where((music) => music.subtitle == 'prayer').toList();
    } else {
      filteredSongs = [];
    }

    // Shuffle the list to get a random order
    filteredSongs.shuffle();

    // Return a fixed number of randomly selected songs (e.g., 5 songs)
    return filteredSongs.take(8).toList();
  }

  bool isLoading = false;

  bool _showError = false;

  void handleEmojiSearch() async {
    setState(() {
      isLoading = true;
      _hasPerformedSearch = true;
      _showError = false; // Reset the error state
    });

    List<MusicData> musicList = [];

    if (_emojiKeyboard.text.isNotEmpty) {
      // If the user has entered an emoji, filter the music
      musicList = await fetchAllMusic();
      String emoji = _emojiKeyboard.text;
      List<MusicData> filteredSongs = filterSongs(emoji, musicList);
      emojiSearchList.clear();

      if (filteredSongs.isNotEmpty) {
        emojiSearchList.addAll(filteredSongs);
      } else {
        _showError = true; // Set the error state
        emojiSearchList.add(MusicData(
          '',
          title: 'No matching song found',
          subtitle: '',
          file: '',
          path: '',
        ));
      }
    } else {
      // If no emoji is entered, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Text(
            'Please enter an Emoji !!',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
                fontSize: 19),
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Set the error state to display a custom error message
      _showError = true;
    }

    // Set all music data in the FavoriteModel
    Provider.of<FavoriteModel>(context, listen: false)
        .setAllMusicData(musicList);

    setState(() {
      isLoading = false;
    });
  }

  void handleManualSearch() async {
    setState(() {
      isLoading = true;
      _hasPerformedSearch = true;
      _showError = false; // Reset the error state
    });

    List<MusicData> musicList = fullMusicList;

    if (_manualKeyboard.text.isNotEmpty) {
      String keyword = _manualKeyboard.text.toLowerCase();
      List<MusicData> filteredSongs = musicList.where((music) {
        // Filter based on the keyword (music title or subtitle)
        return music.title.toLowerCase().contains(keyword) ||
            music.subtitle.toLowerCase().contains(keyword);
      }).toList();

      manualSearchList.clear();

      if (filteredSongs.isNotEmpty) {
        manualSearchList.addAll(filteredSongs);
      } else {
        _showError = true;
        manualSearchList.add(MusicData(
          '',
          title: 'No matching song found',
          subtitle: '',
          file: '',
          path: '',
        ));
      }
    }

    Provider.of<FavoriteModel>(context, listen: false)
        .setAllMusicData(musicList);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0c091c),
          elevation: 0,
          title: const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Icon(
                  size: 32,
                  Icons.search,
                  color: Color(0xFF27bc5c),
                ),
                SizedBox(
                  height: 10,
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Music',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                          fontSize: 20),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Let\'s search music according to your mood',
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white, // Customize text color
                indicatorColor: Color(0xFF27bc5c), // Customize indicator color
                tabs: [
                  Tab(
                    text: 'Emoji Search',
                  ),
                  Tab(text: 'Manual Search'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Container(
              color: Color(0xFF0c091c),
              child: Form(
                key: _emojiSearchFormKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.0),
                                border: Border.all(color: Colors.white),
                              ),
                              child: TextFormField(
                                controller: _emojiKeyboard,
                                onTap: () {
                                  _showEmojiKeyboard();
                                },
                                readOnly: true,

                                style: TextStyle(color: Colors.white),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1),
                                ],
                                keyboardType: TextInputType
                                    .text, // Set the keyboard type to text
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  hintText: 'Enter One Emoji Like.....😊',
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              setState(() {
                                _hasPerformedSearch = true;
                              });
                              if (_emojiSearchFormKey.currentState!
                                  .validate()) {
                                if (!_hasPerformedSearch) {
                                  // Clear the emoji for the first search
                                  setState(() {
                                    _emojiKeyboard.text = '';
                                  });
                                }
                                handleEmojiSearch();
                              }
                            },
                            child: isLoading
                                ? SpinKitHourGlass(
                                    color: Colors.black,
                                    size: 20.0,
                                  )
                                : Icon(Icons.search),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: emojiSearchList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (_showError &&
                              emojiSearchList[index].title ==
                                  'No matching song found') {
                            // Display a different widget when no matching song is found
                            return Center(
                              child: Text(
                                emojiSearchList[index].title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return Card(
                              color: Color(0xFF2C2C2E),
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 13,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, left: 10),
                                child: SongItem(
                                  title: emojiSearchList[index].title,
                                  subtitle: emojiSearchList[index].subtitle,
                                  path: emojiSearchList[index].path,
                                  file: emojiSearchList[index].file,
                                  docId: emojiSearchList[index].docId,
                                  isFavorite: Provider.of<FavoriteModel>(
                                          context)
                                      .favoriteSongs
                                      .contains(emojiSearchList[index].docId),
                                  onToggleFavorite: (isFavorite) {
                                    // Implement your logic to toggle favorite
                                    Provider.of<FavoriteModel>(context,
                                            listen: false)
                                        .toggleFavorite(
                                            emojiSearchList[index].docId);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Color(0xFF0c091c),
              child: Form(
                key: _manualSearchFormKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.0),
                                border: Border.all(color: Colors.white),
                              ),
                              child: TextFormField(
                                controller: _manualKeyboard,
                                onTap: () {
                                  handleManualSearch();
                                },
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  hintText: 'Search Different Music....',
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          isLoading
                              ? Lottie.asset('assets/loader1.json')
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hasPerformedSearch = true;
                                    });
                                    if (_manualKeyboard.text.isNotEmpty) {
                                      handleManualSearch();
                                    } else {
                                      // If no text is entered, show an error message
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please enter a song name !!',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 19,
                                            ),
                                          ),
                                          duration: Duration(seconds: 3),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  },
                                  child: isLoading
                                      ? SpinKitHourGlass(
                                          color: Colors.black,
                                          size: 20.0,
                                        )
                                      : Icon(Icons.search),
                                )
                        ],
                      ),
                    ),
                    //   Expanded(
                    //     child: ListView.builder(
                    // itemCount: manualSearchList.length,
                    // itemBuilder: (BuildContext context, int index) {
                    //         return Card(
                    //           color: Color(0xFF2C2C2E),
                    //           elevation: 2,
                    //           margin: EdgeInsets.symmetric(
                    //             vertical: 10,
                    //             horizontal: 13,
                    //           ),
                    //           child: Padding(
                    //             padding:
                    //                 const EdgeInsets.only(right: 10, left: 10),
                    //             child: SongItem(
                    //               title: manualSearchList[index].title,
                    //               subtitle: manualSearchList[index].subtitle,
                    //               path: manualSearchList[index].path,
                    //               file: manualSearchList[index].file,
                    //               docId: manualSearchList[index].docId,
                    //               isFavorite: Provider.of<FavoriteModel>(context)
                    //                   .favoriteSongs
                    //                   .contains(manualSearchList[index].docId),
                    //               onToggleFavorite: (isFavorite) {
                    //                 // Implement your logic to toggle favorite
                    //                 Provider.of<FavoriteModel>(context,
                    //                         listen: false)
                    //                     .toggleFavorite(
                    //                         manualSearchList[index].docId);
                    //               },
                    //             ),
                    //           ),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: manualSearchList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (_showError &&
                              manualSearchList[index].title ==
                                  'No matching song found') {
                            // Display a different widget when no matching song is found
                            return Center(
                              child: Text(
                                manualSearchList[index].title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return Card(
                              color: Color(0xFF2C2C2E),
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 13,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, left: 10),
                                child: SongItem(
                                  title: manualSearchList[index].title,
                                  subtitle: manualSearchList[index].subtitle,
                                  path: manualSearchList[index].path,
                                  file: manualSearchList[index].file,
                                  docId: manualSearchList[index].docId,
                                  isFavorite: Provider.of<FavoriteModel>(
                                          context)
                                      .favoriteSongs
                                      .contains(manualSearchList[index].docId),
                                  onToggleFavorite: (isFavorite) {
                                    // Implement your logic to toggle favorite
                                    Provider.of<FavoriteModel>(context,
                                            listen: false)
                                        .toggleFavorite(
                                            manualSearchList[index].docId);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _isValidUtf16(String text) {
  try {
    for (int i = 0; i < text.length; ++i) {
      int codeUnit = text.codeUnitAt(i);

      if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF) {
        // Check if the character is part of a surrogate pair
        if (i + 1 < text.length &&
            text.codeUnitAt(i + 1) >= 0xDC00 &&
            text.codeUnitAt(i + 1) <= 0xDFFF) {
          ++i; // Skip the low surrogate
        } else {
          throw FormatException('Invalid UTF-16 string');
        }
      }
    }
    return true;
  } catch (e) {
    return false;
  }
}

class SongItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String path;
  final String file;
  final String docId;

  final bool isFavorite;
  final Function(bool) onToggleFavorite;

  const SongItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.path,
    required this.file,
    required this.docId,
    required this.isFavorite,
    required this.onToggleFavorite,
  }) : super(key: key);

  void playSong(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 1.0,
          child: NowPlayingPage(
            title: title,
            path: path,
            subtitle: subtitle,
            playlists: [],
            file: file,
            docId: docId, // Pass the docId to NowPlayingPage
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        playSong(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/logo.png'),
              radius: 24,
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isValidUtf16(title)
                        ? title
                        : 'Invalid Text', // Replace 'Invalid Text' with a suitable fallback
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                onToggleFavorite(!isFavorite);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteModel extends ChangeNotifier {
  late String _userEmail;
  List<String> _favoriteSongs = [];
  List<MusicData> _allMusicData = [];

  // Constructor that takes the user email as a parameter
  FavoriteModel(String userEmail) {
    _userEmail = userEmail;

    // Load favorite songs and all music data from Firestore during app startup
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      // Clear previous user's data
      _favoriteSongs.clear();
      _allMusicData.clear();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userEmail)
          .collection('FavoriteSongs')
          .where('IsFavorite', isEqualTo: true)
          .get();

      _favoriteSongs =
          querySnapshot.docs.map((doc) => doc.id).toList(); // Extract docId

      // Load all music data from Firestore
      List<MusicData> allMusicData = await fetchMusicData();

      // Add all loaded music data to _allMusicData
      _allMusicData.addAll(allMusicData);

      notifyListeners();
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  void clearData() {
    _favoriteSongs.clear();
    _allMusicData.clear();
    notifyListeners();
  }

  Future<List<MusicData>> fetchMusicData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Music').get();
    List<MusicData> musicList = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return MusicData(
        doc.id, // Use document ID as the path
        title: data['name'] ?? '', // Provide a default value if null
        subtitle: data['subtitle'] ?? '', // Provide a default value if null
        file: data['file'] ?? '', // Provide a default value if null
        path: data['path'] ?? '', // Provide a default value if null
      );
    }).toList();
    return musicList;
  }

  List<String> get favoriteSongs => _favoriteSongs;

  Future<void> toggleFavorite(String docId) async {
    try {
      bool isFavorite = _favoriteSongs.contains(docId);

      if (isFavorite) {
        _favoriteSongs.remove(docId);

        // Remove the document from the user's 'FavoriteSongs' subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userEmail)
            .collection('FavoriteSongs')
            .doc(docId)
            .delete();

        // Remove the document from the 'FavoriteSongs' collection
        await FirebaseFirestore.instance
            .collection('FavoriteSongs')
            .doc(docId)
            .delete();
      } else {
        _favoriteSongs.add(docId);

        // Add the document to the user's 'FavoriteSongs' subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userEmail)
            .collection('FavoriteSongs')
            .doc(docId)
            .set({'IsFavorite': true});
      }

      // Load favorite songs and all music data from Firestore again
      await loadFavorites();

      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  List<MusicData> get allMusicData => _allMusicData;

  void setAllMusicData(List<MusicData> allMusicData) {
    _allMusicData = allMusicData;
    notifyListeners();
  }
}

class MusicData {
  final String docId;
  final String title;
  final String subtitle;
  final String path;
  final String file;

  MusicData(this.docId,
      {required this.title,
      required this.subtitle,
      required this.file,
      required this.path});
}

class NoMatchingSongsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/out-of-stock.png', // Provide the correct image path
        width: 250, // Adjust width as needed
        height: 250, // Adjust height as needed
        color: Colors.white,
      ),
    );
  }
}
