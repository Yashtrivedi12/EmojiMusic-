import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:musicapp_/search%20Page/search.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:shimmer/shimmer.dart';

class NowPlayingPage extends StatefulWidget {
  final String title;
  final String path;
  final String subtitle;
  final List playlists;
  final String file;
  final String docId;

  const NowPlayingPage({
    Key? key,
    required this.title,
    required this.path,
    required this.subtitle,
    required this.playlists,
    required this.file,
    required this.docId,
  }) : super(key: key);

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with AutomaticKeepAliveClientMixin {
  bool _isPlaying = false;
  bool _play = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late final AssetsAudioPlayer assetsAudioPlayer;
  late double _rotationPercentage = 0.0;
  bool _isDisposed = false;
  bool _isLoading = true;
  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
    assetsAudioPlayer.stop();
    assetsAudioPlayer.dispose();
  }

  @override
  void initState() {
    super.initState();

    assetsAudioPlayer = AssetsAudioPlayer();

    assetsAudioPlayer.currentPosition.listen((position) {
      if (!_isDisposed) {
        setState(() {
          _currentPosition = position ?? Duration.zero;
          if (_totalDuration.inMilliseconds > 0) {
            _rotationPercentage =
                _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
          }
        });
      }
    });

    assetsAudioPlayer.current.listen((playingAudio) {
      if (!_isDisposed) {
        if (playingAudio != null) {
          setState(() {
            _totalDuration = playingAudio.audio.duration ?? Duration.zero;
            _isLoading =
                false; // Set loading state to false when music is loaded
          });
        }
      }
    });

    assetsAudioPlayer.open(
      Audio.network(widget.file),
      showNotification: true,
    );

    _isPlaying = true;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (!_isDisposed && _isPlaying) {
        assetsAudioPlayer.play();
      }
    });

    _playPauseMusic();
  }

  void _playPauseMusic() {
    if (_isPlaying) {
      assetsAudioPlayer.pause();
    } else {
      assetsAudioPlayer.open(
        Audio(widget.path,
            metas: Metas(title: widget.title, artist: widget.subtitle)),
      );
      assetsAudioPlayer.play();

      assetsAudioPlayer.playlistFinished.listen((finished) {
        if (finished) {
          assetsAudioPlayer.play();
        }
      });
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    super.build(context);

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
                    height: MediaQuery.of(context).size.height * 0.72,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: const Color(0xFF30384b),
                      borderRadius: BorderRadius.circular(18),
                      image: DecorationImage(
                        image: const AssetImage('assets/logo.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          const Color(0xFF1a1b1f)
                              .withOpacity(0.7), // Adjust the opacity as needed
                          BlendMode.multiply,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.lightBlue!,
                            child: const CircleAvatar(
                              maxRadius: 40,
                            ),
                          )
                        : RotationTransition(
                            turns: AlwaysStoppedAnimation(_rotationPercentage),
                            child: Padding(
                              padding: const EdgeInsets.all(80.0),
                              child: CircleAvatar(
                                maxRadius: 90,
                                backgroundImage: AssetImage('assets/logo.png'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Toggle favorite when the heart icon is pressed
                      Provider.of<FavoriteModel>(context, listen: false)
                          .toggleFavorite(widget.docId);
                    },
                    icon: Icon(
                      Icons.favorite,
                      color: Provider.of<FavoriteModel>(context)
                              .favoriteSongs
                              .contains(widget.docId)
                          ? Colors.red
                          : Colors.white,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _currentPosition.inSeconds.toDouble(),
                min: 0,
                max: _totalDuration.inSeconds.toDouble(),
                onChanged: (double value) {
                  setState(() {
                    assetsAudioPlayer.seek(Duration(seconds: value.toInt()));
                    _currentPosition = Duration(seconds: value.toInt());
                  });
                },
                activeColor: Colors.green,
                inactiveColor: Colors.grey[600],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28, right: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_currentPosition),
                      style: const TextStyle(
                          fontWeight: FontWeight.w300, color: Colors.white70),
                    ),
                    Text(
                      _formatDuration(_totalDuration),
                      style: const TextStyle(
                          fontWeight: FontWeight.w300, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Icon(
                      color: Colors.white,
                      size: 30,
                      Icons.skip_previous_rounded,
                    ),
                    IconButton(
                      onPressed: () {
                        // Seek backward by 10 seconds
                        assetsAudioPlayer.seekBy(const Duration(seconds: -10));
                      },
                      icon: const Icon(
                        Icons.replay_10,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _play ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 35,
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
                    IconButton(
                      onPressed: () {
                        // Seek forward by 10 seconds
                        assetsAudioPlayer.seekBy(const Duration(seconds: 10));
                      },
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const Icon(
                      Icons.skip_next_rounded,
                      size: 30,
                      color: Color(0xFFFFFFFF),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
