import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../models/dog_profile.dart';
import '../../models/review.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dog_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import 'add_dog_screen.dart';
import '../profile/reputation_screen.dart';

class DogDetailScreen extends StatefulWidget {
  final String dogId;

  const DogDetailScreen({super.key, required this.dogId});

  @override
  State<DogDetailScreen> createState() => _DogDetailScreenState();
}

class _DogDetailScreenState extends State<DogDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DogProfile? _dog;
  UserModel? _owner;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDogProfile();
  }

  Future<void> _loadDogProfile() async {
    try {
      final dogId = widget.dogId.trim();
      if (dogId.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final dog = await _firestoreService.getDogProfile(dogId);
      if (dog == null) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      final owner = dog.ownerId.trim().isEmpty
          ? null
          : await _firestoreService.getUserById(dog.ownerId);

      if (mounted) {
        setState(() {
          _dog = dog;
          _owner = owner;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load this dog profile.')),
        );
      }
    }
  }

  Future<void> _deleteDog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dog'),
        content: const Text(
          'Are you sure you want to delete this dog profile? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final dogProvider = context.read<DogProvider>();
      
      final success = await dogProvider.deleteDogProfile(
        widget.dogId,
        authProvider.currentUser!.uid,
      );

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_dog == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dog Profile'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Dog not found')),
      );
    }

    final isOwner = context.read<AuthProvider>().currentUser?.uid == _dog!.ownerId;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(),
            ),
            actions: isOwner
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: AppColors.primary,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddDogScreen(dogToEdit: _dog),
                          ),
                        );
                        if (result == true) {
                          _loadDogProfile();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: AppColors.primary,
                      onPressed: _deleteDog,
                    ),
                  ]
                : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(
                    children: [
                      Expanded(
                        child: Text(_dog!.name, style: AppTextStyles.heading1),
                      ),
                      Icon(
                        _dog!.sex == Sex.male ? Icons.male : Icons.female,
                        color: _dog!.sex == Sex.male ? Colors.blue : Colors.pink,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (_dog!.rating > 0)
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: _dog!.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: AppColors.accent,
                          ),
                          itemCount: 5,
                          itemSize: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_dog!.rating.toStringAsFixed(1)} (${_dog!.ratingCount} reviews)',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _dog!.isAvailableForBreeding
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _dog!.isAvailableForBreeding
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    child: Text(
                      _dog!.isAvailableForBreeding
                          ? '✓ Available for Breeding'
                          : '✗ Not Available for Breeding',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _dog!.isAvailableForBreeding
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildInfoSection('Basic Information', [
                    _InfoRow(label: 'Breed', value: _dog!.breed),
                    _InfoRow(label: 'Age', value: _dog!.ageDisplay),
                    _InfoRow(label: 'Size', value: _dog!.size),
                    _InfoRow(label: 'Color', value: _dog!.color),
                  ]),
                  const SizedBox(height: 24),
                  
                  _buildTemperamentSection(),
                  const SizedBox(height: 24),
                  
                  if (_dog!.healthInfo != null) ...[
                    _buildInfoSection('Health Information', [
                      _InfoRow(label: '', value: _dog!.healthInfo!),
                    ]),
                    const SizedBox(height: 24),
                  ],
                  
                  if (_owner != null && !isOwner) ...[
                    _buildOwnerSection(),
                    const SizedBox(height: 24),
                  ],
                  
                  _buildReviewsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_dog!.imageUrls.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.pets, size: 100, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: _dog!.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: _dog!.imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 50),
              ),
            );
          },
        ),
        if (_dog!.imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_dog!.imageUrls.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTemperamentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temperament', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dog!.temperaments.map((temp) {
            return Chip(
              label: Text(
                temp.name[0].toUpperCase() + temp.name.substring(1),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOwnerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Owner', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReputationScreen(userId: _owner!.uid),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: _owner!.profileImageUrl != null
                      ? CachedNetworkImageProvider(_owner!.profileImageUrl!)
                      : null,
                  child: _owner!.profileImageUrl == null
                      ? Text(
                          _owner!.name[0].toUpperCase(),
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _owner!.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_owner!.isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.verified,
                              size: 18,
                              color: AppColors.success,
                            ),
                          ],
                        ],
                      ),
                      if (_owner!.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _owner!.location!,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Reviews', style: AppTextStyles.heading3),
            if (_dog!.ratingCount > 0)
              TextButton(
                onPressed: () {
                  
                },
                child: const Text('See All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Review>>(
          stream: _firestoreService.getDogReviews(widget.dogId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'No reviews yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }

            final reviews = snapshot.data!.take(3).toList();

            return Column(
              children: reviews.map((review) {
                return _ReviewCard(review: review);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(value, style: AppTextStyles.bodyMedium),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  review.reviewerName[0].toUpperCase(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dateFormat.format(review.createdAt),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: AppColors.accent,
                ),
                itemCount: 5,
                itemSize: 18,
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
