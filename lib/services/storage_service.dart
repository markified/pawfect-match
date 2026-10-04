import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../config/cloudinary_config.dart';

class StorageService {
  
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  
  Future<String> uploadDogImage(File imageFile, String dogId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'dog_${dogId}_$timestamp';
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'pawfect/dog_images',
          publicId: fileName,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload dog image: $e');
    }
  }

  
  Future<String> uploadUserProfileImage(File imageFile, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'user_${userId}_$timestamp';
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'pawfect/profile_images',
          publicId: fileName,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  
  Future<void> deleteImage(String imageUrl) async {
    try {
      
      
      
      
      
      
      
      
      
      
      
      
      
    } catch (e) {
      
    }
  }

  
  Future<List<String>> uploadMultipleDogImages(
    List<File> imageFiles,
    String dogId,
  ) async {
    try {
      final List<String> downloadUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'dog_${dogId}_${i}_$timestamp';
        
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFiles[i].path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'pawfect/dog_images',
            publicId: fileName,
          ),
        );
        
        downloadUrls.add(response.secureUrl);
      }
      
      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  
  Future<String?> uploadPostImage(File imageFile, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_${userId}_$timestamp';
      
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'pawfect/post_images',
          publicId: fileName,
        ),
      );

      return response.secureUrl;
    } catch (e) {
      
      return null;
    }
  }

  
  String getOptimizedImageUrl(
    String imageUrl, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
  }) {
    try {
      final uri = Uri.parse(imageUrl);
      if (!uri.host.contains('cloudinary.com')) {
        return imageUrl; 
      }

      
      final transformations = <String>[];
      if (width != null) transformations.add('w_$width');
      if (height != null) transformations.add('h_$height');
      transformations.add('q_$quality');
      transformations.add('f_$format');
      
      final transformStr = transformations.join(',');
      
      
      final path = uri.path;
      final uploadIndex = path.indexOf('/upload/');
      if (uploadIndex != -1) {
        final beforeUpload = path.substring(0, uploadIndex + 8);
        final afterUpload = path.substring(uploadIndex + 8);
        final newPath = '$beforeUpload$transformStr/$afterUpload';
        
        return uri.replace(path: newPath).toString();
      }
      
      return imageUrl;
    } catch (e) {
      return imageUrl;
    }
  }

  
  String getThumbnailUrl(String imageUrl, {int size = 150}) {
    return getOptimizedImageUrl(
      imageUrl,
      width: size,
      height: size,
      quality: 'auto:low',
    );
  }
}
