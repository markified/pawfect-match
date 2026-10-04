import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/dog_profile.dart';
import '../../models/match_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dog_provider.dart';
import '../../providers/match_provider.dart';
import '../../utils/constants.dart';
import 'submit_review_screen.dart';

class CompletedMatchesScreen extends StatelessWidget {
  const CompletedMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    final authProvider = context.watch<AuthProvider>();

    
    final completedMatches = [
      ...matchProvider.sentRequests,
      ...matchProvider.receivedRequests,
    ].where((request) => request.status == MatchStatus.completed).toList();

    
    completedMatches.sort((a, b) {
      final aDate = a.completedAt ?? a.createdAt;
      final bDate = b.completedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Completed Matches'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: completedMatches.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              itemCount: completedMatches.length,
              itemBuilder: (context, index) {
                final match = completedMatches[index];
                final isReceived =
                    match.targetOwnerId == authProvider.currentUser?.uid;
                return _CompletedMatchCard(
                  matchRequest: match,
                  isReceived: isReceived,
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
              Icons.check_circle_outline,
              size: 100,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text('No Completed Matches', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              'Completed breeding matches will appear here',
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

class _CompletedMatchCard extends StatelessWidget {
  final MatchRequest matchRequest;
  final bool isReceived;

  const _CompletedMatchCard({
    required this.matchRequest,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final dogProvider = context.watch<DogProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy');

    
    final dogId = isReceived
        ? matchRequest.requesterDogId
        : matchRequest.targetDogId;
    final dog = dogProvider.allDogs.firstWhere(
      (d) => d.id == dogId,
      orElse: () => _getPlaceholderDog(dogId),
    );

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
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  child: dog.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: dog.imageUrls.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.pets, size: 40),
                        ),
                ),
                const SizedBox(width: 16),
                
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dog.breed,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed: ${dateFormat.format(matchRequest.completedAt ?? matchRequest.createdAt)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubmitReviewScreen(
                        matchRequest: matchRequest,
                        targetDog: dog,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review),
                label: const Text('Leave a Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DogProfile _getPlaceholderDog(String dogId) {
    return DogProfile(
      id: dogId,
      ownerId: '',
      name: 'Unknown',
      breed: 'Unknown',
      ageInMonths: 0,
      sex: Sex.male,
      size: 'Unknown',
      color: 'Unknown',
      temperaments: [],
      createdAt: DateTime.now(),
    );
  }
}
