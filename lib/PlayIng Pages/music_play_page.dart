import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class MusicPlayPage extends StatefulWidget {
  final String musicName;
  final String code;
  final String downloadUrl;
  final String documentId;

  MusicPlayPage(
      {required this.musicName,
      required this.code,
      required this.downloadUrl,
      required this.documentId});

  @override
  State<MusicPlayPage> createState() => _MusicPlayPageState();
}

class _MusicPlayPageState extends State<MusicPlayPage>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  bool _play = true;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  final assetsAudioPlayer = AssetsAudioPlayer();
  late AnimationController _rotationController;
  bool musicLoaded = false;

  @override
  void initState() {
    super.initState();

    // Initialize the audio player and open the music file from the asset path
    assetsAudioPlayer.open(
      Audio.network(widget.downloadUrl),
      autoStart: true,
      showNotification: true,
    );

    // Initialize the animation controller
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Adjust the duration as needed
    );

    // Listen for audio playback completion to update the play/pause icon
    assetsAudioPlayer.playlistAudioFinished.listen((finishedEvent) {
      setState(() {
        _play = false;
      });
    });

    assetsAudioPlayer.current.listen((playing) {
      // Update duration when the audio is loaded and its duration is available
      setState(() {
        _duration = playing!.audio.duration;
        musicLoaded = true; // Music is loaded
      });
    });

    assetsAudioPlayer.currentPosition.listen((currentPosition) {
      // Update position when the audio position changes
      setState(() {
        _position = currentPosition;
      });
    });

    // Listen to changes in the play state and start/stop the animation
    assetsAudioPlayer.isPlaying.listen((isPlaying) {
      if (isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    _rotationController.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void skipForward() {
    setState(() {
      Duration newPosition = _position + const Duration(seconds: 10);
      if (newPosition > _duration) {
        newPosition = _duration;
      }
      assetsAudioPlayer.seek(newPosition);
    });
  }

  void skipBackward() {
    setState(() {
      Duration newPosition = _position - const Duration(seconds: 10);
      if (newPosition < Duration.zero) {
        newPosition = Duration.zero;
      }
      assetsAudioPlayer.seek(newPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF0c091c),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.70,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: widget.code.isNotEmpty
                          ? null
                          : const Color(0xFF30384b),
                      image: widget.code.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.code as String),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                const Color(0xFF0c091c).withOpacity(0.6),
                                BlendMode.multiply,
                              ),
                            )
                          : null,
                    ),
                    child: Center(
                      child: musicLoaded
                          ? RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_rotationController),
                              child: CircleAvatar(
                                maxRadius: 90,
                                backgroundImage: widget.code.isNotEmpty
                                    ? NetworkImage(widget.code as String)
                                    : AssetImage('assets/logo.png')
                                        as ImageProvider<Object>?,
                                child: widget.code.isNotEmpty
                                    ? null
                                    : const Icon(
                                        color: Colors.white,
                                        Icons.music_note_rounded,
                                        size: 60,
                                      ),
                              ),
                            )
                          : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.lightBlue!,
                              child: const CircleAvatar(
                                maxRadius: 80,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 28, // Adjust the top position as needed
                    left: 10, // Adjust the left position as needed
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        size: 30,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                  // Positioned(
                  //     top: 58, // Adjust the top position as needed
                  //     left: -10, // Adjust the left position as needed
                  //     child: Lottie.asset(
                  //       'assets/songwave.json',
                  //       width: 380, // Specify the desired width
                  //       height: 380,
                  //     )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent, // Start color
                              const Color(0xFF0c091c)
                            ],
                            stops: [
                              0.1,
                              0.8
                            ]),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Wrap with a Container to set a width constraint
                    Container(
                      width: 250, // Adjust the width as needed
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          widget.musicName,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color:
                            isFavorite ? const Color(0xFF27bc5c) : Colors.white,
                      ),
                      onPressed: () {
                        // Toggle the favorite state
                        setState(() {
                          isFavorite = !isFavorite;
                        });

                        // Add/remove the documentId to/from the "favoriteMusic" collection
                        if (isFavorite) {
                          // Add the documentId to the "favoriteMusic" collection
                          addToFavorites(widget.documentId);
                        } else {
                          // Remove the documentId from the "favoriteMusic" collection
                          removeFromFavorites(widget.documentId);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 32.0,
                  right: 28.0,
                ),
                child: Container(
                  width: 350,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      widget.musicName,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
              ),
              Slider(
                activeColor: const Color(0xFF27bc5c),
                inactiveColor: const Color(0xFF404040),
                value: _position.inSeconds.toDouble(),
                min: 0,
                max: _duration.inSeconds.toDouble(),
                onChanged: (double value) {
                  setState(() {
                    assetsAudioPlayer.seek(Duration(seconds: value.toInt()));
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 28,
                  right: 28,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(_position),
                      style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: Color(0xFFFFFFFF)),
                    ),
                    Text(
                      formatDuration(_duration),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFFFFFFF)),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(
                    color: Colors.white,
                    size: 30,
                    Icons.skip_previous_rounded,
                  ),
                  IconButton(
                    onPressed: () {
                      skipBackward();
                    },
                    icon: const Icon(
                      Icons.replay_10,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Container(
                    width: 60, // Adjust the size as needed
                    height: 60, // Adjust the size as needed
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFFFFF), // Adjust the color as needed
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          _play ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _play = !_play;
                            if (_play) {
                              assetsAudioPlayer.play();
                            } else {
                              assetsAudioPlayer.pause();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      skipForward();
                    },
                    icon: const Icon(
                      Icons.forward_10,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const Icon(
                    Icons.skip_next_rounded,
                    size: 30,
                    color: Color(0xFFFFFFFF),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addToFavorites(String documentId) {
    // Assuming you have an instance of FirebaseFirestore
    FirebaseFirestore.instance.collection('favoriteMusic').add({
      'documentId': documentId,
      'timestamp': FieldValue.serverTimestamp(), // Optional: Store a timestamp
    }).then((value) {
      print('Document added to favorites: $value');
    }).catchError((error) {
      print('Failed to add document to favorites: $error');
    });
  }

  void removeFromFavorites(String documentId) {
    // Assuming you have an instance of FirebaseFirestore
    FirebaseFirestore.instance
        .collection('favoriteMusic')
        .where('documentId', isEqualTo: documentId)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete().then((_) {
          print('Document removed from favorites');
        }).catchError((error) {
          print('Failed to remove document from favorites: $error');
        });
      });
    }).catchError((error) {
      print('Error querying favorites: $error');
    });
  }
}
