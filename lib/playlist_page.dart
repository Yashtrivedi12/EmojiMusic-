// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ListPage extends StatefulWidget {
//   const ListPage({Key? key}) : super(key: key);

//   @override
//   _ListPageState createState() => _ListPageState();
// }

// class _ListPageState extends State<ListPage> {
//   final TextEditingController musicNameController = TextEditingController();
//   final TextEditingController subtitleController = TextEditingController();
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   void _submitData() async {
//     String musicName = musicNameController.text;
//     String subtitle = subtitleController.text;

//     await firestore.collection('Music').add({
//       'name': musicName,
//       'subtitle': subtitle,
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Data uploaded successfully!'),
//       ),
//     );

//     musicNameController.clear();
//     subtitleController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: <Widget>[
//             const SizedBox(height: 60),
//             const Text('Name Of Music'),
//             TextField(
//               controller: musicNameController,
//               decoration: const InputDecoration(labelText: 'Music Name'),
//             ),
//             const SizedBox(height: 20),
//             const Text('Subtitle'),
//             TextField(
//               controller: subtitleController,
//               decoration: const InputDecoration(labelText: 'Subtitle'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _submitData,
//               child: const Text('Submit Data to Firebase'),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ListPage extends StatefulWidget {
  const ListPage({super.key});
  @override
  State<ListPage> createState() => _HomePageState();
}

class _HomePageState extends State<ListPage> {
  final TextEditingController musicNameController = TextEditingController();
  final TextEditingController subtitle1 = TextEditingController();
  final TextEditingController nameOfMusicController = TextEditingController();
  bool isUploading = false;
  double uploadProgress = 0.0; // Track the upload progress
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
      });
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // Create a reference to the location you want to upload to in Firebase Storage
      final firebase_storage.Reference reference =
          firebase_storage.FirebaseStorage.instance.ref('uploads/$fileName');
      // Create a Task to upload the file
      final firebase_storage.UploadTask uploadTask = reference.putFile(
        file,
        firebase_storage.SettableMetadata(
          customMetadata: <String, String>{'file': 'audio'},
        ),
      );
      // Listen for state changes, errors, and completion of the upload.
      final StreamSubscription<firebase_storage.TaskSnapshot>
          streamSubscription = uploadTask.snapshotEvents.listen((event) {
        setState(() {
          uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      });
      // Wait until the upload is complete
      await uploadTask;
      // Cancel the subscription to the stream when the upload is complete
      streamSubscription.cancel();
      String downloadUrl = await reference.getDownloadURL();
      String musicName = musicNameController.text;
      String subtitle = subtitle1.text;
      String audioName = nameOfMusicController.text;
      String audioFile = downloadUrl;
      DocumentReference documentReference =
          await firestore.collection('Music').add({
        'name': musicName,
        'subtitle': subtitle,
        'file': audioFile,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully!'),
        ),
      );
      musicNameController.clear();
      subtitle1.clear();
      nameOfMusicController.clear();
      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
      });
    } else {
      // User canceled the file picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 60),
            const Text('Name Of Music'),
            TextField(
              controller: musicNameController,
              decoration: const InputDecoration(labelText: 'Music Name'),
            ),
            const SizedBox(height: 20),
            const Text('Subtitle'),
            TextField(
              controller: subtitle1,
              decoration: const InputDecoration(labelText: 'Subtitle'),
            ),
            // const SizedBox(height: 20),
            // const Text('Name Of Music'),
            // TextField(
            //   controller: nameOfMusicController,
            //   decoration: const InputDecoration(labelText: 'Name Of Music'),
            // ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isUploading ? null : pickFile,
              child: isUploading
                  ? Column(
                      children: <Widget>[
                        LinearProgressIndicator(
                          value: uploadProgress,
                          backgroundColor: Colors.grey[300], // Background color
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blue), // Progress color
                        ),
                        const SizedBox(height: 10),
                        Text('${(uploadProgress * 100).toStringAsFixed(2)}%'),
                      ],
                    )
                  : const Text('Pick and Upload File to Firebase Storage'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
