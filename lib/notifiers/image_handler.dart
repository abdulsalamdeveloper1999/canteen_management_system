import 'dart:typed_data';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'cloundindary_service.dart'; // Import the Cloudinary service

class ImagePickerProvider extends ChangeNotifier {
  FilePickerResult? _pickedImage;
  Uint8List? _imageBytes;

  FilePickerResult? get pickedImage => _pickedImage;
  Uint8List? get imageBytes => _imageBytes;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Pick image
  Future<void> pickImage() async {
    try {
      final picked = await FilePicker.platform.pickFiles();
      if (picked != null) {
        _pickedImage = picked;
        _imageBytes = picked.files.first.bytes; // Store the image bytes
        notifyListeners();
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  // Remove image
  void removeImage() {
    _pickedImage = null;
    _imageBytes = null;
    notifyListeners();
  }

  

}
