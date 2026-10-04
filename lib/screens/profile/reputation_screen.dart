import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../models/review.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class ReputationScreen extends StatefulWidget {
  final String userId;

  const ReputationScreen({super.key, required this.userId});

  @override
  State<ReputationScreen> createState() => _ReputationScreenState();
}

class _ReputationScreenState extends State<ReputationScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reputation & Reviews'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Review>>(
        stream: _firestoreService.getOwnerReviews(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final reviews = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              children: [
                
                _buildOverallStats(reviews),
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reviews (${reviews.length})',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 16),
                      if (reviews.isEmpty)
                        _buildEmptyState()
                      else
                        ...reviews.map((review) => _ReviewCard(review: review)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallStats(List<Review> reviews) {
    double averageRating = 0.0;
    if (reviews.isNotEmpty) {
      double totalRating = 0;
      for (var review in reviews) {
        totalRating += review.rating;
      }
      averageRating = totalRating / reviews.length;
    }

    
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      distribution[review.rating.round()] =
          (distribution[review.rating.round()] ?? 0) + 1;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            averageRating.toStringAsFixed(1),
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          RatingBarIndicator(
            rating: averageRating,
            itemBuilder: (context, index) => const Icon(
              Icons.star,
              color: Colors.white,
            ),
            itemCount: 5,
            itemSize: 24,
          ),
          const SizedBox(height: 8),
          Text(
            '${reviews.length} ${reviews.length == 1 ? 'Review' : 'Reviews'}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          
          if (reviews.isNotEmpty)
            Column(
              children: [5, 4, 3, 2, 1].map((stars) {
                final count = distribution[stars] ?? 0;
                final percentage =
                    reviews.isEmpty ? 0.0 : count / reviews.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          '$stars ⭐',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$count',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Reviews Yet',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Reviews from completed matches will appear here',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
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
      ),
    );
  }
}
