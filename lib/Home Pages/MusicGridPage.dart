import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicapp_/Home%20Pages/ArtistCard.dart';
import 'package:musicapp_/CustomBottomsheet.dart';
import 'package:musicapp_/File%20Upload/fileUpload.dart';
import 'package:musicapp_/Home%20Pages/ArtistGrid.dart/ArtistGrid.dart';
import 'package:musicapp_/Home%20Pages/erasong.dart';
import 'package:musicapp_/PlayIng%20Pages/music_play_page.dart';
import 'package:musicapp_/Home%20Pages/sliderPage.dart';

//flutter - 3.16.5
//dart - 3.2.3

class MusicGridPage extends StatefulWidget {
  final String userEmail;

  const MusicGridPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _MusicGridPageState createState() => _MusicGridPageState();
}

class _MusicGridPageState extends State<MusicGridPage>
    with TickerProviderStateMixin {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  late Future<List<Map<String, dynamic>>> userMusicCollections;

  Future<void> showDeleteConfirmationDialog(String? docId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this collection?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await deleteCollection(docId);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userMusicCollections = getUserMusicCollections();
  }

  Future<List<Map<String, dynamic>>> getUserMusicCollections() async {
    try {
      // Fetch user's music collections from Firestore
      QuerySnapshot querySnapshot = await firestore
          .collection('users')
          .doc(widget.userEmail)
          .collection('musicFolderCollection')
          .get();

      // Convert the documents to a list of maps
      List<Map<String, dynamic>> collections = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();

      return collections;
    } catch (e) {
      print('Error fetching user music collections: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0c091c),
          elevation: 0,
          title: Row(
            children: [
              Icon(
                size: 38,
                Icons.music_note,
                color: Color(0xFF27bc5c),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Music Collections',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Let\'s listen to something cool today',
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
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
                  Tab(text: 'Trending Songs'),
                  Tab(text: 'Custom Collection'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF0c091c),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 24, top: 16),
                        child: Text(
                          "Enjoy The Trending Songs🔥",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Expanded(flex: 5, child: RowSliderWidget()),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.height * 0.06,
                        ),
                        child: Text(
                          "Famous Artist Playlist🎧🎶",
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(
                              color: Color(0xFFfcfcfc),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ArtistGridPage()),
                            );
                          },
                          child: Text(
                            "MORE >",
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                color: Color(0xFF2986dd),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(flex: 3, child: YourScreen()),
                  Expanded(flex: 4, child: EraRowSliderWidget()),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF1a1b1f),
              child: StreamBuilder(
                stream: fetchData(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Color(0xFFFFFFFF),
                    ));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Column(
                      children: [
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 24, top: 16),
                              child: Text(
                                "Custom Collection✍🏻📝",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        !snapshot.hasData || snapshot.data!.isEmpty
                            ? Expanded(
                                flex: 9,
                                child: Container(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            // primary: const Color(0xFF27bc5c),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FileUploadPage(
                                                        userEmail:
                                                            widget.userEmail),
                                              ),
                                            );
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.add,
                                                color: Color(0xFF1a1b1f),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                'Create Your Custom Collection',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF1a1b1f),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8.0,
                                      mainAxisSpacing: 8.0,
                                    ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          navigateToSecondPage(
                                              snapshot.data![index]);
                                        },
                                        child: Card(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(snapshot
                                                  .data![index]['color'])),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Stack(
                                              children: [
                                                const Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.music_note,
                                                      color: Colors.white,
                                                      size: 48,
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: PopupMenuButton(
                                                      onSelected: (value) {
                                                        // Handle the selected menu item
                                                        if (value == 'delete') {
                                                          // Show delete confirmation dialog
                                                          showDeleteConfirmationDialog(
                                                              snapshot.data![
                                                                          index]
                                                                      ['docId']
                                                                  as String?);
                                                        }
                                                      },
                                                      itemBuilder: (context) =>
                                                          [
                                                        PopupMenuItem(
                                                          value: 'delete',
                                                          child: const Text(
                                                              'Delete'),
                                                        ),
                                                      ],
                                                      icon: const Icon(
                                                        Icons.more_vert,
                                                        color: Colors.white,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            18.0),
                                                    child: Text(
                                                      snapshot.data![index]
                                                              ['name']
                                                          .toString(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteCollection(String? docId) async {
    try {
      if (docId != null) {
        print('Deleting collection with docId: $docId');
        await firestore
            .collection('users')
            .doc(widget.userEmail)
            .collection('musicFolderCollection')
            .doc(docId)
            .delete();
        print('Collection deleted successfully.');
      } else {
        print('Document ID is null.');
      }
    } catch (e) {
      print('Error deleting collection: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> fetchData() {
    try {
      return firestore
          .collection('users')
          .doc(widget.userEmail)
          .collection('musicFolderCollection')
          .snapshots()
          .map(
            (querySnapshot) => querySnapshot.docs
                .map(
                  (doc) => {
                    'docId': doc.id, // Add this line to include the document ID
                    ...doc.data() as Map<String, dynamic>,
                  },
                )
                .toList(),
          );
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<void> navigateToSecondPage(Map<String, dynamic> musicData) async {
    try {
      // Fetch detailed data for the selected music IDs from the Music collection
      List<Map<String, dynamic>> detailedDataList = await Future.wait(
        (musicData['listOfMusic'] as List<dynamic>).map(
          (musicId) async {
            DocumentSnapshot<Map<String, dynamic>> musicDoc =
                await firestore.collection('Music').doc(musicId).get();

            String docId = musicDoc.id; // Get the document ID

            return {'docId': docId, ...musicDoc.data() ?? {}};
          },
        ),
      );

      // Extract the color information
      Color containerColor =
          Color(int.parse(musicData['color'] ?? '0xFFFFFFFF'));

      // Navigate to the second page with the detailed data, list of music IDs, and color
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondPage(
            data: detailedDataList,
            listOfMusic: musicData['listOfMusic'],
            containerColor: containerColor,
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to the second page: $e');
    }
  }
}

class SecondPage extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<dynamic> listOfMusic;
  final Color containerColor;

  SecondPage({
    required this.data,
    required this.listOfMusic,
    required this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              containerColor, // Start color
              const Color(0xFF1a1b1f)
            ],
          ),
        ),
        child: ListView(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF1a1b1f),
                    ),
                  ),
                ),
              ],
            ),
            // Display details of the music folder here, e.g., folder color, etc.
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Container(
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.height *
                      0.04), // Adjust the percentage as needed
                  child: const Text(
                    'Music Details',
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            ),
            // Display the list of songs in the folder
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  children: data.map((music) {
                    return ListTile(
                      tileColor: Colors.white,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xff764abc),
                        child: Icon(Icons.music_note),
                      ),
                      title: Text(
                        '${music['name']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      subtitle: const Text(
                        'Item description',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF1a1b1f),
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => CustomBottomSheet(),
                          );
                        },
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF1a1b1f),
                        ),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return FractionallySizedBox(
                              heightFactor: 1.0,
                              child: MusicPlayPage(
                                musicName: music['name'],
                                code: '',
                                downloadUrl: music['file'],
                                documentId: music['docId'],
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


  /*
  */