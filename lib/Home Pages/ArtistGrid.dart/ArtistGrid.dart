// import 'package:flutter/material.dart';

// class ArtistGridPage extends StatefulWidget {
//   const ArtistGridPage({super.key});

//   @override
//   State<ArtistGridPage> createState() => _ArtistGridPageState();
// }

// class _ArtistGridPageState extends State<ArtistGridPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
// appBar: AppBar(
//   backgroundColor: const Color(0xFF0c091c),
//   elevation: 0,
//   leading: IconButton(
//     icon: Icon(
//       Icons.arrow_back,
//       size: 28,
//       color: Color(0xFF27bc5c), // Set the color for the back button
//     ),
//     onPressed: () {
//       Navigator.pop(context);
//     },
//   ),
//   title: Row(
//     children: [
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Famous Artist Playlist🎧',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Color(0xFFFFFFFF),
//               fontSize: 20,
//             ),
//           ),
//           SizedBox(height: 2),
//           Text(
//             'Let\'s listen to Famous Artist Playlist🎧',
//             style: TextStyle(
//               fontWeight: FontWeight.w200,
//               color: Colors.white54,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       )
//     ],
//   ),
// ),
//       body: Container(
// width: double.infinity,
// color: Color(0xFF0c091c),
//         child: Column(
//           children: [
//             Text(
//               'Hello, I Am Yash Trivedi',
//               style: TextStyle(fontSize: 28, color: Colors.white),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musicapp_/Home%20Pages/ArtistCard.dart';
import 'package:musicapp_/PlayIng%20Pages/music_play_page.dart';
import 'package:shimmer/shimmer.dart';

class ArtistGridPage extends StatefulWidget {
  @override
  _ArtistGridPageState createState() => _ArtistGridPageState();
}

class _ArtistGridPageState extends State<ArtistGridPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0c091c),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 28,
            color: Color(0xFF27bc5c), // Set the color for the back button
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Famous Artist Playlist🎧',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF),
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Let\'s listen to Famous Artist Playlist🎧',
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
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('ArtistList').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Use shimmer effect while data is loading
            return EnhancedShimmerArtistList();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return buildArtistGrid(snapshot.data!.docs);
          }
        },
      ),
    );
  }

  Widget buildArtistGrid(List<QueryDocumentSnapshot> documents) {
    return Container(
      width: double.infinity,
      color: Color(0xFF0c091c),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Set the number of columns in the grid
          crossAxisSpacing: 8.0, // Set the horizontal spacing between columns
          mainAxisSpacing: 8.0, // Set the vertical spacing between rows
        ),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> artistData =
              documents[index].data() as Map<String, dynamic>;

          // Check if required fields exist in the document
          String artistName =
              artistData.containsKey('name') ? artistData['name'] : '';
          String artistImage =
              artistData.containsKey('Image') ? artistData['Image'] : '';
          List<String> musicIds = artistData.containsKey('listOfMusic')
              ? List<String>.from(artistData['listOfMusic'])
              : [];

          return buildArtistCard(context, artistName, artistImage, musicIds);
        },
      ),
    );
  }

  Widget buildArtistCard(BuildContext context, String artistName,
      String artistImage, List<String> musicIds) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return FractionallySizedBox(
              heightFactor: 1.0,
              child: MusicDetailsPage(
                artistName: artistName,
                artistImage: artistImage,
                musicIds: musicIds,
              ),
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 5.0,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8.0)),
                  image: DecorationImage(
                    image: NetworkImage(artistImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                artistName,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Rest of the code remains the same...
