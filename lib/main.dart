import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:musicapp_/AppState.dart';
import 'package:musicapp_/Favorite/favorite_page.dart';
import 'package:musicapp_/File%20Upload/ArtistFileUpload.dart';
import 'package:musicapp_/File%20Upload/fileUpload.dart';
import 'package:musicapp_/Home%20Pages/MusicGridPage.dart';
import 'package:musicapp_/search%20Page/search.dart';
import 'package:musicapp_/signingpage.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? user = FirebaseAuth.instance.currentUser;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppState(AssetsAudioPlayer()),
        ),
        if (user != null)
          ChangeNotifierProvider(
            create: (context) => FavoriteModel(user.email!),
          ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String userEmail;

  const MyApp({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: FutureBuilder(
        // Use Firebase Auth to check the sign-in state
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the connection is still in progress, display a loading screen
            return SplashScreen();
          } else if (snapshot.hasError) {
            // If there's an error, handle it accordingly
            return AuthGate();
          } else if (snapshot.hasData) {
            // If a user is signed in, load the favorite data
            User? user = snapshot.data as User?;
            if (user != null) {
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) => AppState(AssetsAudioPlayer()),
                  ),
                  ChangeNotifierProvider(
                    create: (context) => FavoriteModel(user.email!),
                  ),
                ],
                child: MusicApp(userEmail: user.email!),
              );
            } else {
              // If the user is not signed in, go to AuthGate
              return AuthGate();
            }
          } else {
            // If no user is signed in, go to AuthGate
            return AuthGate();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    navigateToHome();
  }

  Future<void> navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));

    if (_controller.isAnimating) {
      _controller.stop();
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          // Get the current user after the delay
          User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            return MyApp(userEmail: user.email!);
          } else {
            // If the user is not signed in, go to AuthGate
            return AuthGate();
          }
        }),
      );
    }
  }

  @override
  void dispose() {
    // Dispose the animation controller to avoid memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1b1f),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 400, width: 400),
            const SizedBox(height: 20),
            ColorizeAnimatedTextKit(
              onTap: () {
                print("Tap Event");
              },
              text: ["BeatEmoji"],
              textStyle: GoogleFonts.ubuntu(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ).copyWith(fontSize: 30),
              colors: [
                Colors.purple,
                Colors.blue,
                Colors.yellow,
                Colors.red,
              ],
              speed: const Duration(
                  milliseconds: 100), // Use 'speed' instead of 'duration'
              totalRepeatCount: 10,
              pause: const Duration(milliseconds: 1),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
          ],
        ),
      ),
    );
  }
}

class MusicApp extends StatefulWidget {
  final String userEmail;

  const MusicApp({Key? key, required this.userEmail}) : super(key: key);

  @override
  _MusicAppState createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  int _currentPageIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MusicGridPage(userEmail: widget.userEmail),
      SearchPage(userEmail: widget.userEmail),
      FavoritePage(userEmail: widget.userEmail),
      FileUploadPage(userEmail: widget.userEmail),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _pages[_currentPageIndex],
        bottomNavigationBar: SalomonBottomBar(
          backgroundColor: Color(0xFF1f1a1b),
          unselectedItemColor: Color(0xFFFFFFFF),
          currentIndex: _currentPageIndex,
          onTap: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home),
              title: const Text('Home'),
              selectedColor: Color(0xFFD3D3D3),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.music_note),
              title: const Text('Search Emoji'),
              selectedColor: Color(0xFFADD8E6),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              selectedColor: Color(0xFFFFB6C1),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.playlist_play),
              title: const Text('Create Collection'),
              selectedColor: Color(0xFFFFA07A),
            ),
          ],
        ),
      ),
    );
  }
}
