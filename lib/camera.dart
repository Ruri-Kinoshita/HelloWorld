import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SimpleImagePicker extends StatefulWidget {
  const SimpleImagePicker({Key? key}) : super(key: key);

  @override
  State<SimpleImagePicker> createState() => _SimpleImagePickerState();
}

class _SimpleImagePickerState extends State<SimpleImagePicker> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("画像の選択 or 撮影")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_image != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.file(
                _image!,
                width: 300,
                height: 400,
                fit: BoxFit.cover,
              ),
            )
          else
            const Text("画像がまだ選択されていません"),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text("ギャラリーから"),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("カメラで撮影"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
