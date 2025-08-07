// services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload product image
  static Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      String fileName = 'products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  // Upload user profile image
  static Future<String> uploadUserImage(File imageFile, String userId) async {
    try {
      String fileName = 'users/$userId/profile.jpg';
      Reference ref = _storage.ref().child(fileName);

      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading profile image: $e');
    }
  }

  // Delete image
  static Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error deleting image: $e');
    }
  }

  // Get download URL from path
  static Future<String> getDownloadUrl(String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error getting download URL: $e');
    }
  }

  // Upload multiple images
  static Future<List<String>> uploadMultipleImages(List<File> imageFiles, String folder) async {
    try {
      List<String> downloadUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        String fileName = '$folder/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref = _storage.ref().child(fileName);

        UploadTask uploadTask = ref.putFile(imageFiles[i]);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('Error uploading multiple images: $e');
    }
  }
}