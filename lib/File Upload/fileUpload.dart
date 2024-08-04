import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:musicapp_/search%20Page/search.dart';
import 'package:musicapp_/signingpage.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class FileUploadPage extends StatefulWidget {
  final String userEmail;

  const FileUploadPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  List<Widget> textFields = [];
  TextEditingController nameOfColorController = TextEditingController();
  List<String> uploadedMusicNames = [];
  int index = 1;

  void addTextField() {
    bool isTickMarkIcon = index > 1 && _uploadComplete != null;

    textFields.add(
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (!isTickMarkIcon) {
                        pickFile();
                      }
                    },
                    onLongPress: () {
                      if (!isTickMarkIcon) {
                        pickFile();
                      }
                    },
                    child: isTickMarkIcon
                        ? Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 70,
                          )
                        : Row(
                            children: [
                              Lottie.asset(
                                'assets/addfile.json',
                                width: 70,
                                height: 70,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text('Pick Your Music Now!!',
                                  style: GoogleFonts.aBeeZee(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600))
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Expanded(
                      child: FutureBuilder<String?>(
                        future: _uploadComplete,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.data != null) {
                            // Add the uploaded music name to the list
                            uploadedMusicNames.add(snapshot.data!);

                            return Container(
                              width: 300, // Adjust the width as needed
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${snapshot.data}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    index++;
  }

  bool showTextField = false;
  List<ColorData> colorData = [];
  TextEditingController colorCodeController = TextEditingController();
  TextEditingController musicNameController = TextEditingController();
  TextEditingController nameOfMusicController = TextEditingController();
  bool isUploading = false;
  double uploadProgress = 0.0; // Track the upload progress

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Add boolean flag and uploaded music name
  bool isUploadComplete = false;
  String uploadedMusicName = '';
  Future<String?> _uploadComplete = Future.value(null);

  @override
  void initState() {
    super.initState();
    loadColorData();
    addTextField(); // Initially add one text field
  }

  Future<void> loadColorData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/colors.json');
      final jsonData = json.decode(jsonString);

      List<ColorData> colors = [];
      for (var item in jsonData) {
        colors.add(ColorData(name: item['name'], hex: item['hex']));
      }

      setState(() {
        colorData = colors;
      });
    } catch (e) {
      print('Error loading color data: $e');
    }
  }

  String _currentFolderId = '';

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File selectedFile = File(result.files.single.path!);

        setState(() {
          isUploading = true;
          uploadProgress = 0.0;
        });

        String fileName = DateTime.now().millisecondsSinceEpoch.toString();

        final firebase_storage.Reference reference =
            firebase_storage.FirebaseStorage.instance.ref('uploads/$fileName');

        final firebase_storage.UploadTask uploadTask =
            reference.putFile(selectedFile);

        final StreamSubscription<firebase_storage.TaskSnapshot>
            streamSubscription = uploadTask.snapshotEvents.listen((event) {
          setState(() {
            uploadProgress = event.bytesTransferred / event.totalBytes;
          });
        });

        await uploadTask;

        streamSubscription.cancel();

        String downloadUrl = await reference.getDownloadURL();
        String musicName = musicNameController.text;
        String color = colorCodeController.text;
        String audioName = nameOfMusicController.text;
        String audioFile = downloadUrl;
        String fileNameWithoutExtension =
            path.basenameWithoutExtension(selectedFile.path ?? '');

        DocumentReference musicDocumentReference =
            await firestore.collection('Music').add({
          'name': fileNameWithoutExtension,
          'file': audioFile,
        });

        String musicDocumentId = musicDocumentReference.id;

        if (_currentFolderId == null || _currentFolderId!.isEmpty) {
          // If no current folder ID, create a new folder under the user's email
          DocumentReference folderDocumentReference = await firestore
              .collection('users') // Use a collection named 'users'
              .doc(widget.userEmail) // Use the user's email as the document ID
              .collection('musicFolderCollection')
              .add({
            'name': musicName,
            'color': color,
            'listOfMusic': [musicDocumentId],
          });

          // Set the current folder ID to the newly created folder
          _currentFolderId = folderDocumentReference.id;
        } else {
          // If there is a current folder ID, update the existing folder
          DocumentReference folderDocumentReference = firestore
              .collection('users') // Use a collection named 'users'
              .doc(widget.userEmail) // Use the user's email as the document ID
              .collection('musicFolderCollection')
              .doc(_currentFolderId!);

          // Update the existing folder with the new music details
          await folderDocumentReference.update({
            'listOfMusic': FieldValue.arrayUnion([musicDocumentId]),
          });

          print('Document updated successfully!');
        }
        // Set the uploaded music name and mark upload as complete
        setState(() {
          uploadedMusicName = fileNameWithoutExtension;
          _uploadComplete = Future.value(uploadedMusicName);
        });

        // Show success message
        showSuccessMessage();

        // Add a new text field for the next song
        addTextField();

        // Reset the flags inside the setState callback
        setState(() {
          isUploading = false;
          uploadProgress = 0.0;
        });
      } else {
        // User canceled the file picker
      }
    } catch (e) {
      print('Error picking file: $e');
      // Handle the error as needed
    }
  }

  void showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Your Music is successfully Added To Your Collection!',
          style: GoogleFonts.kanit(
              fontWeight: FontWeight.bold,
              color: Color(0xFF27bc5c),
              fontSize: 15),
        ),
      ),
    );
  }

  Color _selectedColor = Color(0xFF27bc5c);

  void pickColor() async {
    Color currentColor = _selectedColor; // Use the stored color

    Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                setState(() {
                  currentColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(currentColor);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        _selectedColor = pickedColor; // Update the stored color
        colorCodeController.text = colorToHex(pickedColor);
      });
    }
  }

  String colorToHex(Color color) {
    try {
      String hex = color.value.toRadixString(16).padLeft(8, '0');
      hex = hex.substring(2);
      hex = '0xFF' + hex;
      return hex;
    } catch (e) {
      print('Error converting color to hex: $e');
      return '0xFF000000';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        color: const Color(0xFF0c091c),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 40,
                ),
                const Row(
                  children: [
                    Icon(
                      size: 38,
                      Icons.grid_view_rounded,
                      color: Color(0xFF27bc5c),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make Your Own Collection',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFFFFF),
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Add your music in collection',
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
                const SizedBox(height: 40),
                const Text(
                  'Name Of Folder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: musicNameController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Enter Your Collection Name',
                    labelStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 15,
                      fontWeight: FontWeight.w200,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Name Of Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Autocomplete<ColorData>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return [];
                    }
                    return colorData.where((color) => color.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (ColorData selectedColor) {
                    setState(() {
                      colorCodeController.text = selectedColor.hex;
                    });
                  },
                  fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    return InkWell(
                      onTap: pickColor,
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: colorCodeController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'Enter Your Collection Color',
                            labelStyle: const TextStyle(
                              color: Colors.white54,
                              fontSize: 15,
                              fontWeight: FontWeight.w200,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  optionsViewBuilder: (
                    BuildContext context,
                    AutocompleteOnSelected<ColorData> onSelected,
                    Iterable<ColorData> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: SizedBox(
                          height: 200.0,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final color = options.elementAt(index);
                              return ListTile(
                                title: Text(color.name),
                                onTap: () {
                                  onSelected(color);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(height: 20),
                const Text(
                  'List Of Music',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 30,
                ),
                ...textFields,
                Row(
                  children: [
                    Text(
                      '${(uploadProgress * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: Color(0xFF2986dd),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isUploading)
                      Lottie.asset('assets/uploading.json', height: 50),
                  ],
                ),
                const SizedBox(
                  width: 30,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Clear FavoriteModel data when user signs out
                        Provider.of<FavoriteModel>(context, listen: false)
                            .clearData();

                        // Perform logout
                        await FirebaseAuth.instance.signOut();

                        // Navigate to the login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AuthGate()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          // colo: Colors.red, // Set the button color
                          // onPrimary: Colors.white, // Set the text color
                          ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ColorData {
  final String name;
  final String hex;

  ColorData({required this.name, required this.hex});
}
