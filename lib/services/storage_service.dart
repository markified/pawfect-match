import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload dog image
  Future<String> uploadDogImage(File imageFile, String dogId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'dog_${dogId}_$timestamp.jpg';
      final ref = _storage.ref().child('dog_images').child(fileName);

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload dog image: $e');
    }
  }

  // Upload user profile image
  Future<String> uploadUserProfileImage(File imageFile, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'user_${userId}_$timestamp.jpg';
      final ref = _storage.ref().child('profile_images').child(fileName);

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Delete image by URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Upload multiple dog images
  Future<List<String>> uploadMultipleDogImages(
    List<File> imageFiles,
    String dogId,
  ) async {
    try {
      final List<String> downloadUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final url = await uploadDogImage(imageFiles[i], '${dogId}_$i');
        downloadUrls.add(url);
      }
      
      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  // Upload community post image
  Future<String?> uploadPostImage(File imageFile, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_${userId}_$timestamp.jpg';
      final ref = _storage.ref().child('post_images').child(fileName);

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Log error silently or use a logging framework
      return null;
    }
  }
}
