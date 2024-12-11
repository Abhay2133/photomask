import 'package:flutter/services.dart';
import 'package:photomask/util.dart';
import 'package:photomask/widgets/mask_dialog.dart';

import 'package:pro_image_editor/pro_image_editor.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image; // To store picked image
  Uint8List? selectedImage;
  Uint8List? outputImageBytes;
  bool openDialog = false;
  late final List<List<dynamic>> masks;

  late final List<List<dynamic>> imagePaths;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMasks();
  }

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      image = File(pickedFile.path); // Store the picked image
      selectedImage = null;
      outputImageBytes = null;
    });
    _openEditor();
    // if (imageBytes != null) _openDialog();
  }

  void _openEditor() async {
    if (image == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.file(
          image!,
          callbacks: ProImageEditorCallbacks(
            // onCloseEditor: () {
            //   Navigator.pop(context);
            // },
            onImageEditingComplete: (Uint8List bytes) async {
              setState(() {
                selectedImage = bytes;
                // openDialog = true;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
    if (selectedImage != null) _openDialog();
  }

  void _loadMasks() async {
    final image1 = await readAssetFile('assets/user_image_frame_1.png');
    final image2 = await readAssetFile('assets/user_image_frame_2.png');
    final image3 = await readAssetFile('assets/user_image_frame_3.png');
    final image4 = await readAssetFile('assets/user_image_frame_4.png');
    setState(() {
      masks = [
        [0, 'assets/user_image_frame_1.png', image1],
        [1, 'assets/user_image_frame_2.png', image2],
        [2, 'assets/user_image_frame_3.png', image3],
        [3, 'assets/user_image_frame_4.png', image4],
      ];
    });
  }

  void _openDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MaskDialog(
          image: selectedImage!,
          onSelect: (Uint8List image) {
            setState(() {
              outputImageBytes = image;
            });
          },
          masks: masks,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Image / Icon',
          style: TextStyle(color: Colors.black), // Black text for contrast
        ),
        backgroundColor: Colors.white, // White background for AppBar
        elevation: 4.0, // Adds shadow beneath the AppBar
        shadowColor: const Color.fromARGB(
            255, 255, 255, 255), // Optional: Customize shadow color
        centerTitle: true, // Optional: Center-align the title
        iconTheme: const IconThemeData(color: Colors.black), // Icons in black
        leading: IconButton(
            onPressed: () {
              exit(0);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Column(
        children: [
          ChooseImageView(onChoose: _pickImageFromGallery),
          outputImageBytes == null
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.memory(
                    outputImageBytes!,
                    width: double.infinity,
                    // height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
        ],
      ),
    );
  }
}

class ChooseImageView extends StatelessWidget {
  final VoidCallback onChoose;
  const ChooseImageView({
    super.key,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 2.0),
          borderRadius: BorderRadius.circular(10.0)),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const Center(
            child: Text(
              'Upload Image',
              style: TextStyle(
                  fontSize: 20.0, color: Color.fromRGBO(0, 0, 0, 0.7)),
            ),
          ),
          const SizedBox(height: 10.0),
          Center(
              child: ElevatedButton(
                  onPressed: onChoose,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        const Color.fromARGB(255, 0, 105, 86), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0), // Border radius
                    ),
                  ),
                  child: const Text("Choose from device")))
        ],
      ),
    );
  }
}
