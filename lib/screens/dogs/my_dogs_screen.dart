import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/dog_profile.dart';
import '../../providers/dog_provider.dart';
import '../../utils/constants.dart';
import 'add_dog_screen.dart';
import 'dog_detail_screen.dart';

class MyDogsScreen extends StatelessWidget {
  const MyDogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Dogs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDogScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<DogProvider>(
        builder: (context, dogProvider, child) {
          if (dogProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dogProvider.userDogs.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            itemCount: dogProvider.userDogs.length,
            itemBuilder: (context, index) {
              final dog = dogProvider.userDogs[index];
              return _DogCard(dog: dog);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 100,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Dogs Yet',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first dog to start matching',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDogScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Dog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DogCard extends StatelessWidget {
  final DogProfile dog;

  const _DogCard({required this.dog});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DogDetailScreen(dogId: dog.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              // Dog image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                child: dog.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: dog.imageUrls.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.pets, size: 40),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets, size: 40),
                      ),
              ),
              const SizedBox(width: 16),
              // Dog info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dog.name,
                            style: AppTextStyles.heading3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          dog.sex == Sex.male ? Icons.male : Icons.female,
                          color: dog.sex == Sex.male
                              ? Colors.blue
                              : Colors.pink,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dog.breed,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dog.ageDisplay} • ${dog.size}',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (dog.rating > 0) ...[
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dog.rating.toStringAsFixed(1)} (${dog.ratingCount})',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(width: 12),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: dog.isAvailableForBreeding
                                ? AppColors.success.withOpacity(0.1)
                                : AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dog.isAvailableForBreeding
                                ? 'Available'
                                : 'Unavailable',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: dog.isAvailableForBreeding
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
