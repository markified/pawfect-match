import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/dog_profile.dart';
import '../../models/match_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';
import '../../services/compatibility_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../dogs/dog_detail_screen.dart';

class CompatibilityResultsScreen extends StatefulWidget {
  final DogProfile selectedDog;
  final DogProfile targetDog;

  const CompatibilityResultsScreen({
    super.key,
    required this.selectedDog,
    required this.targetDog,
  });

  @override
  State<CompatibilityResultsScreen> createState() =>
      _CompatibilityResultsScreenState();
}

class _CompatibilityResultsScreenState
    extends State<CompatibilityResultsScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMatchRequest() async {
    final authProvider = context.read<AuthProvider>();
    final matchProvider = context.read<MatchProvider>();

    final overallScore = CompatibilityService.calculateCompatibilityScore(
      widget.selectedDog,
      widget.targetDog,
    );

    final matchRequest = MatchRequest(
      id: '${authProvider.currentUser!.uid}_${widget.targetDog.ownerId}_${DateTime.now().millisecondsSinceEpoch}',
      requesterId: authProvider.currentUser!.uid,
      requesterDogId: widget.selectedDog.id,
      targetOwnerId: widget.targetDog.ownerId,
      targetDogId: widget.targetDog.id,
      status: MatchStatus.pending,
      compatibilityScore: overallScore,
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await matchProvider.sendMatchRequest(matchRequest);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request Sent'),
          content: const Text(
            'Your breeding match request has been sent successfully!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to matcher
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            matchProvider.errorMessage ?? 'Failed to send request',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallScore = CompatibilityService.calculateCompatibilityScore(
      widget.selectedDog,
      widget.targetDog,
    );
    final breakdown = CompatibilityService.getCompatibilityBreakdown(
      widget.selectedDog,
      widget.targetDog,
    );
    final rating = CompatibilityService.getCompatibilityRating(overallScore);
    final percentage = CompatibilityService.getCompatibilityPercentage(overallScore);

    Color ratingColor;
    if (overallScore >= 0.8) {
      ratingColor = AppColors.success;
    } else if (overallScore >= 0.65) {
      ratingColor = AppColors.primary;
    } else if (overallScore >= 0.5) {
      ratingColor = AppColors.accent;
    } else {
      ratingColor = AppColors.error;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compatibility Results'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Overall score section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ratingColor, ratingColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
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
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.selectedDog.name} & ${widget.targetDog.name}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Compatibility breakdown
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compatibility Breakdown', style: AppTextStyles.heading3),
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
                  // Dog comparison
                  Text('Dogs Comparison', style: AppTextStyles.heading3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DogCard(
                          dog: widget.selectedDog,
                          label: 'Your Dog',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DogCard(
                          dog: widget.targetDog,
                          label: 'Match',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Message section
                  Text('Send a Message (Optional)', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Introduce yourself and your dog...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Send request button
                  Consumer<MatchProvider>(
                    builder: (context, matchProvider, child) {
                      return CustomButton(
                        text: 'Send Match Request',
                        onPressed: _sendMatchRequest,
                        isLoading: matchProvider.isLoading,
                        icon: Icons.send,
                        width: double.infinity,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
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
              color: Colors.black.withOpacity(0.05),
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
                      color: AppColors.textSecondary,
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
