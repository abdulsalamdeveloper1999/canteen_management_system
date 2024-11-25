import 'dart:typed_data';
import 'package:cloudinary/cloudinary.dart';

class CloudinaryService {
  final Cloudinary cloudinary = Cloudinary.signedConfig(
    apiKey: "547413896474848",
    apiSecret: "_2u7kTvbnTTxOixZ0C_S4BN0SAs",
    cloudName: "dpqpnvn8u",
  );

  // Upload image to Cloudinary using the upload method
  Future<String?> uploadImage({
    required Uint8List fileBytes, // The byte array of the image
   
  }) async {
    try {
      final CloudinaryResponse response = await cloudinary.upload(
        fileBytes: fileBytes,
       
      );

      // Check if the upload was successful and return the secure URL
      if (response.isSuccessful) {
        return response.secureUrl; // Get the URL of the uploaded image
      } else {
        print("Upload failed: ${response.error?.toString()}");
        return null;
      }
    } catch (e) {
      print("Error uploading image to Cloudinary: $e");
      return null;
    }
  }
}
