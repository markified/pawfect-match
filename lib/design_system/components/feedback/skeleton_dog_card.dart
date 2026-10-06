import 'package:flutter/material.dart';
import '../../tokens/paw_spacing.dart';
import 'skeleton_loader.dart';

class SkeletonDogCard extends StatelessWidget {
  const SkeletonDogCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(PawSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SkeletonBox(
            width: double.infinity,
            height: 280,
            borderRadius: 0,
          ),
          
          
          Padding(
            padding: const EdgeInsets.all(PawSpacing.sm),
            child: Row(
              children: [
                SkeletonBox(width: 80, height: 24, borderRadius: 16),
                const SizedBox(width: PawSpacing.xs),
                SkeletonBox(width: 60, height: 24, borderRadius: 16),
                const SizedBox(width: PawSpacing.xs),
                SkeletonBox(width: 70, height: 24, borderRadius: 16),
              ],
            ),
          ),
          
          
          Padding(
            padding: const EdgeInsets.all(PawSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSkeletonButton(),
                _buildSkeletonButton(),
                _buildSkeletonButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSkeletonButton() {
    return Column(
      children: const [
        SkeletonCircle(size: 24),
        SizedBox(height: 4),
        SkeletonBox(width: 40, height: 12, borderRadius: 4),
      ],
    );
  }
}
