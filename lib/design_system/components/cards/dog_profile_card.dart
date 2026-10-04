import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_radius.dart';
import '../../animations/transitions.dart';
import '../feedback/skeleton_loader.dart';
import '../feedback/skeleton_dog_card.dart';
import '../feedback/loading_wrapper.dart';




class DogProfileCard extends StatelessWidget {
  final String dogId;
  final String dogName;
  final String breed;
  final int ageInMonths;
  final String imageUrl;
  final List<Widget>? statChips;
  final VoidCallback? onLike;
  final VoidCallback? onMessage;
  final VoidCallback? onViewDetails;
  final bool enableHero;
  final bool isLoading; 
  
  const DogProfileCard({
    super.key,
    required this.dogId,
    required this.dogName,
    required this.breed,
    required this.ageInMonths,
    required this.imageUrl,
    this.statChips,
    this.onLike,
    this.onMessage,
    this.onViewDetails,
    this.enableHero = true,
    this.isLoading = false, 
  });
  
  String get ageDisplay {
    if (ageInMonths < 12) {
      return '$ageInMonths months';
    }
    final years = ageInMonths ~/ 12;
    final months = ageInMonths % 12;
    if (months == 0) {
      return '$years ${years == 1 ? "year" : "years"}';
    }
    return '$years ${years == 1 ? "year" : "years"}, $months ${months == 1 ? "month" : "months"}';
  }
  
  @override
  Widget build(BuildContext context) {
    
    return LoadingWrapper(
      isLoading: isLoading,
      skeleton: const SkeletonDogCard(),
      child: _buildCard(),
    );
  }
  
  Widget _buildCard() {
    return Card(
      margin: const EdgeInsets.all(PawSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(),
          if (statChips != null && statChips!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(PawSpacing.sm),
              child: Wrap(
                spacing: PawSpacing.xs,
                runSpacing: PawSpacing.xs,
                children: statChips!,
              ),
            ),
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildHeroImage() {
    final imageWidget = _buildProgressiveImage();
    
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          enableHero
              ? PawHero(
                  tag: 'dog-$dogId',
                  child: imageWidget,
                )
              : imageWidget,
          _buildGradientOverlay(),
          _buildImageContent(),
        ],
      ),
    );
  }
  
  Widget _buildProgressiveImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const SkeletonBox(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 0,
      ),
      errorWidget: (context, url, error) => Container(
        color: PawColors.cardBackground,
        child: const Center(
          child: Icon(
            Icons.pets,
            size: 64,
            color: PawColors.textSecondary,
          ),
        ),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
  
  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImageContent() {
    return Positioned(
      bottom: PawSpacing.md,
      left: PawSpacing.md,
      right: PawSpacing.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dogName,
            style: PawTypography.h2.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$breed • $ageDisplay',
            style: PawTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(PawSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (onLike != null)
            _ActionButton(
              icon: Icons.favorite_border,
              label: 'Like',
              onTap: onLike!,
            ),
          if (onMessage != null)
            _ActionButton(
              icon: Icons.message_outlined,
              label: 'Message',
              onTap: onMessage!,
            ),
          if (onViewDetails != null)
            _ActionButton(
              icon: Icons.info_outline,
              label: 'Details',
              onTap: onViewDetails!,
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PawRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PawSpacing.md,
          vertical: PawSpacing.sm,
        ),
        child: Column(
          children: [
            Icon(icon, color: PawColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: PawTypography.labelSmall.copyWith(
                color: PawColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
