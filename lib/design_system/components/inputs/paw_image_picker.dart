import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_radius.dart';
import '../../tokens/paw_typography.dart';



class PawImagePicker extends StatelessWidget {
  final List<File> images;
  final ValueChanged<List<File>> onImagesChanged;
  final int maxImages;
  final double aspectRatio;
  
  const PawImagePicker({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.maxImages = 10,
    this.aspectRatio = 16 / 9,
  });
  
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      final newImages = pickedFiles.map((xFile) => File(xFile.path)).toList();
      final totalImages = images.length + newImages.length;
      
      if (totalImages <= maxImages) {
        onImagesChanged([...images, ...newImages]);
      } else {
        
        final available = maxImages - images.length;
        onImagesChanged([...images, ...newImages.take(available)]);
      }
    }
  }
  
  void _removeImage(int index) {
    final newImages = List<File>.from(images);
    newImages.removeAt(index);
    onImagesChanged(newImages);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (${images.length}/$maxImages)',
          style: PawTypography.h3,
        ),
        const SizedBox(height: PawSpacing.sm),
        if (images.isEmpty)
          _buildEmptyState(context)
        else
          _buildImageGrid(),
      ],
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(PawRadius.md),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: PawSpacing.sm),
              Text(
                'Tap to add photos',
                style: PawTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImageGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: PawSpacing.sm,
            mainAxisSpacing: PawSpacing.sm,
            childAspectRatio: 1,
          ),
          itemCount: images.length + (images.length < maxImages ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < images.length) {
              return _buildImageItem(images[index], index, context);
            } else {
              return _buildAddButton(context);
            }
          },
        ),
      ],
    );
  }
  
  Widget _buildImageItem(File image, int index, BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(PawRadius.md),
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(PawRadius.md),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Icon(
          Icons.add,
          size: 40,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
