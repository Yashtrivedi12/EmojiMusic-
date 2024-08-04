import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

class ArtistFileUploadPage extends StatefulWidget {
  const ArtistFileUploadPage({Key? key});

  @override
  State<ArtistFileUploadPage> createState() => _ArtistFileUploadPageState();
}

class _ArtistFileUploadPageState extends State<ArtistFileUploadPage> {
  List<Widget> textFields = [];
  int index = 1;

  void addTextField() {
    textFields.add(
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF27bc5c),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1a1b1f),
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const SizedBox(
                width: 10,
              ),
              CircleAvatar(
                backgroundColor: const Color(0xFF27bc5c),
                child: InkWell(
                  onTap: () {
                    pickFile();
                  },
                  child: const CircleAvatar(
                    maxRadius: 20,
                    backgroundImage: AssetImage('assets/selected.png'),
                  ),
                ),
              ),
            ],
          ),
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

        // Check if there is a current folder ID
        if (_currentFolderId == null || _currentFolderId!.isEmpty) {
          // If no current folder ID, create a new folder
          DocumentReference folderDocumentReference =
              await firestore.collection('DecadeSeries').add({
            'name': musicName,
            'color': color,
            'listOfMusic': [musicDocumentId],
          });

          // Set the current folder ID to the newly created folder
          _currentFolderId = folderDocumentReference.id;
        } else {
          // If there is a current folder ID, update the existing folder
          DocumentReference folderDocumentReference =
              firestore.collection('DecadeSeries').doc(_currentFolderId!);

          // Update the existing folder with the new music details
          await folderDocumentReference.update({
            'listOfMusic': FieldValue.arrayUnion([musicDocumentId]),
          });

          print('Document updated successfully!');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully!'),
          ),
        );

        setState(() {
          isUploading = false;
          uploadProgress = 0.0;
        });

        // Add a new text field for the next song
        addTextField();
      } else {
        // User canceled the file picker
      }
    } catch (e) {
      print('Error picking file: $e');
      // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        color: const Color(0xFF1a1b1f),
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
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onFieldSubmitted: (value) {
                        onFieldSubmitted();
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Enter Your Collection Color',
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
                Card(
                  color: const Color(0xFF1a1b1f),
                  elevation: 15,
                  child: TextField(
                    enabled: false,
                    controller: colorCodeController,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Collection Color Code',
                      labelStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 15,
                        fontWeight: FontWeight.w200,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
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
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF27bc5c), // Background color
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: isUploading
                        ? Column(
                            children: <Widget>[
                              LinearProgressIndicator(
                                value: uploadProgress,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white, // Change color as needed
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${(uploadProgress * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 110, 77, 77),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.cloud_upload,
                                color: Color(0xFF1a1b1f),
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Pick Your Music!! Fast Fast😉',
                                style: TextStyle(
                                  color: Color(
                                      0xFF1a1b1f), // Change color as needed
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(
                  width: 30,
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
