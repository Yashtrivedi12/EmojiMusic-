// import 'package:flutter/material.dart';
// import 'package:music_app/CustomBottomsheet.dart';
// import 'package:music_app/Pages/music_play_page.dart';

// import 'package:music_app/model/model.dart';

// class MusicFolderDetailPage extends StatelessWidget {
//   final MusicFolder musicFolder;

//   MusicFolderDetailPage({required this.musicFolder});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(musicFolder.color), // Start color
//               Color(0xFF1a1b1f)
//             ],
//             // stops: [0.1, 1.0],
//           ),
//         ),
//         child: ListView(
//           children: <Widget>[
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.05,
//             ),
//             Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 18),
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Icon(
//                       Icons.arrow_drop_down,
//                       color: Color(0xFFFFFFFF),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             // Display details of the music folder here, e.g., folder color, etc.
//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.2,
//               child: Container(
//                 child: Padding(
//                   padding: EdgeInsets.all(MediaQuery.of(context).size.height *
//                       0.04), // Adjust the percentage as needed
//                   child: Text(
//                     '${musicFolder.name}',
//                     style: TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFFFFFFFF)),
//                   ),
//                 ),
//               ),
//             ),
//             // Display the list of songs in the folder

//             // D

//             SizedBox(
//               height: MediaQuery.of(context).size.height * 0.8,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: musicFolder.listOfMusic.map((song) {
//                     return ListTile(
//                       tileColor: Colors.white,
//                       leading: CircleAvatar(
//                         backgroundColor: const Color(0xff764abc),
//                         child: Icon(Icons.music_note),
//                       ),
//                       title: Text(
//                         '${song.name}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFFFFFFFF),
//                         ),
//                       ),
//                       subtitle: Text(
//                         'Item description',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w300,
//                           color: Color(0xFFFFFFFF),
//                         ),
//                       ),
//                       trailing: IconButton(
//                           onPressed: () {
//                             showModalBottomSheet(
//                               context: context,
//                               isScrollControlled: true,
//                               backgroundColor: Colors.transparent,
//                               builder: (context) => CustomBottomSheet(),
//                             );
//                           },
//                           icon: Icon(
//                             Icons.more_vert,
//                             color: Color(0xFFFFFFFF),
//                           )),
//                       onTap: () {
//                         showModalBottomSheet(
//                           isScrollControlled: true,
//                           context: context,
//                           builder: (BuildContext context) {
//                             return FractionallySizedBox(
//                               heightFactor: 1.0,
//                               child: MusicPlayPage(
//                                 musicName: song.name,
//                                 code: '',
//                                 downloadUrl: song.file,
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
