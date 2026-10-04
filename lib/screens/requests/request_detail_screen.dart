import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/dog_profile.dart';
import '../../models/match_request.dart';
import '../../providers/dog_provider.dart';
import '../../providers/match_provider.dart';
import '../../services/compatibility_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../dogs/dog_detail_screen.dart';
import '../reviews/submit_review_screen.dart';

class RequestDetailScreen extends StatelessWidget {
  final MatchRequest request;
  final bool isReceived;

  const RequestDetailScreen({
    super.key,
    required this.request,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final dogProvider = context.watch<DogProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy · HH:mm');

    
    final myDog = dogProvider.allDogs.firstWhere(
      (d) => d.id == (isReceived ? request.targetDogId : request.requesterDogId),
      orElse: () => _getPlaceholderDog(
        isReceived ? request.targetDogId : request.requesterDogId,
      ),
    );

    final otherDog = dogProvider.allDogs.firstWhere(
      (d) => d.id == (isReceived ? request.requesterDogId : request.targetDogId),
      orElse: () => _getPlaceholderDog(
        isReceived ? request.requesterDogId : request.targetDogId,
      ),
    );

    final breakdown = CompatibilityService.getCompatibilityBreakdown(
      myDog,
      otherDog,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildStatusHeader(dateFormat),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compatibility Score', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  _buildCompatibilityScore(),
                  const SizedBox(height: 16),
                  _CompatibilityBar(
                    label: 'Breed',
                    score: breakdown['breed']!,
                    weight: '35%',
                  ),
                  const SizedBox(height: 12),
                  _CompatibilityBar(
                    label: 'Age',
                    score: breakdown['age']!,
                    weight: '25%',
                  ),
                  const SizedBox(height: 12),
                  _CompatibilityBar(
                    label: 'Sex',
                    score: breakdown['sex']!,
                    weight: '15%',
                  ),
                  const SizedBox(height: 12),
                  _CompatibilityBar(
                    label: 'Temperament',
                    score: breakdown['temperament']!,
                    weight: '25%',
                  ),
                  const SizedBox(height: 24),
                  
                  Text('Dogs', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DogCard(
                          dog: myDog,
                          label: 'Your Dog',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DogCard(
                          dog: otherDog,
                          label: isReceived ? 'Their Dog' : 'Match',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  if (request.message != null &&
                      request.message!.isNotEmpty) ...[
                    Text('Message', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
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
                      child: Text(
                        request.message!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  if (isReceived && request.status == MatchStatus.pending)
                    _buildActionButtons(context),
                  if (request.status == MatchStatus.accepted)
                    _buildCompletedButton(context),
                  if (request.status == MatchStatus.completed)
                    _buildReviewButton(context, otherDog),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(DateFormat dateFormat) {
    Color statusColor;
    String statusText;

    switch (request.status) {
      case MatchStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case MatchStatus.accepted:
        statusColor = AppColors.success;
        statusText = 'Accepted';
        break;
      case MatchStatus.rejected:
        statusColor = AppColors.error;
        statusText = 'Rejected';
        break;
      case MatchStatus.completed:
        statusColor = AppColors.success;
        statusText = 'Completed';
        break;
      case MatchStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(request.status),
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Request sent on ${dateFormat.format(request.createdAt)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (request.respondedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Responded on ${dateFormat.format(request.respondedAt!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompatibilityScore() {
    final percentage =
        CompatibilityService.getCompatibilityPercentage(request.compatibilityScore);
    final rating =
        CompatibilityService.getCompatibilityRating(request.compatibilityScore);

    Color ratingColor;
    if (request.compatibilityScore >= 0.8) {
      ratingColor = AppColors.success;
    } else if (request.compatibilityScore >= 0.65) {
      ratingColor = AppColors.primary;
    } else if (request.compatibilityScore >= 0.5) {
      ratingColor = AppColors.accent;
    } else {
      ratingColor = AppColors.error;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ratingColor, ratingColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: Column(
        children: [
          Text(
            percentage,
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$rating Match',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Accept Request',
          onPressed: () => _handleAccept(context),
          icon: Icons.check,
          width: double.infinity,
          backgroundColor: AppColors.success,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _handleReject(context),
          icon: const Icon(Icons.close),
          label: const Text('Reject Request'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedButton(BuildContext context) {
    return CustomButton(
      text: 'Mark as Completed',
      onPressed: () => _handleComplete(context),
      icon: Icons.check_circle,
      width: double.infinity,
    );
  }

  Widget _buildReviewButton(BuildContext context, DogProfile targetDog) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This match has been completed!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Leave a Review',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubmitReviewScreen(
                  matchRequest: request,
                  targetDog: targetDog,
                ),
              ),
            );
          },
          icon: Icons.rate_review,
          width: double.infinity,
          backgroundColor: AppColors.accent,
        ),
      ],
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    final matchProvider = context.read<MatchProvider>();

    final success = await matchProvider.updateMatchRequestStatus(
      request,
      MatchStatus.accepted,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match request accepted!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    final matchProvider = context.read<MatchProvider>();

    final success = await matchProvider.updateMatchRequestStatus(
      request,
      MatchStatus.rejected,
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match request rejected')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _handleComplete(BuildContext context) async {
    final matchProvider = context.read<MatchProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text(
          'Mark this breeding match as completed? You can then leave a review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await matchProvider.updateMatchRequestStatus(
        request,
        MatchStatus.completed,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match marked as completed!')),
        );
        Navigator.pop(context);
      }
    }
  }

  IconData _getStatusIcon(MatchStatus status) {
    switch (status) {
      case MatchStatus.pending:
        return Icons.pending;
      case MatchStatus.accepted:
        return Icons.check_circle;
      case MatchStatus.rejected:
        return Icons.cancel;
      case MatchStatus.completed:
        return Icons.verified;
      case MatchStatus.cancelled:
        return Icons.block;
    }
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

class _CompatibilityBar extends StatelessWidget {
  final String label;
  final double score;
  final String weight;

  const _CompatibilityBar({
    required this.label,
    required this.score,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (score >= 0.8) {
      barColor = AppColors.success;
    } else if (score >= 0.5) {
      barColor = AppColors.accent;
    } else {
      barColor = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label (Weight: $weight)',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              '${(score * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: score,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _DogCard extends StatelessWidget {
  final DogProfile dog;
  final String label;

  const _DogCard({
    required this.dog,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DogDetailScreen(dogId: dog.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.borderRadius),
              ),
              child: dog.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: dog.imageUrls.first,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    dog.name,
                    style: AppTextStyles.heading3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dog.breed,
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    dog.ageDisplay,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
