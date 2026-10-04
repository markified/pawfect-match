import 'package:flutter/material.dart';
import 'paw_card.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_typography.dart';


class PawCardExampleScreen extends StatelessWidget {
  const PawCardExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PawColors.background,
      appBar: AppBar(
        title: const Text('PawCard Examples'),
        backgroundColor: PawColors.cardBackground,
      ),
      body: ListView(
        padding: PawSpacing.screenInsets,
        children: [
          
          const Text(
            'Non-Interactive Card',
            style: PawTypography.h3,
          ),
          PawSpacing.verticalMD,
          const PawCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basic Card',
                  style: PawTypography.h3,
                ),
                SizedBox(height: 8),
                Text(
                  'This is a non-interactive card with default styling.',
                  style: PawTypography.bodyMedium,
                ),
              ],
            ),
          ),

          PawSpacing.verticalLG,

          
          const Text(
            'Interactive Card (Tap to see elevation change)',
            style: PawTypography.h3,
          ),
          PawSpacing.verticalMD,
          PawCard(
            onTap: () {
              debugPrint('Card tapped!');
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interactive Card',
                  style: PawTypography.h3,
                ),
                SizedBox(height: 8),
                Text(
                  'Tap this card to see the elevation animation (2dp → 4dp) and ripple effect.',
                  style: PawTypography.bodyMedium,
                ),
              ],
            ),
          ),

          PawSpacing.verticalLG,

          
          const Text(
            'Custom Styled Card',
            style: PawTypography.h3,
          ),
          PawSpacing.verticalMD,
          PawCard(
            backgroundColor: PawColors.primary,
            borderRadius: 20,
            padding: const EdgeInsets.all(24),
            onTap: () {
              debugPrint('Custom card tapped!');
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Colors & Radius',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This card uses custom background color, border radius, and padding.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          PawSpacing.verticalLG,

          
          const Text(
            'Card with Border',
            style: PawTypography.h3,
          ),
          PawSpacing.verticalMD,
          PawCard(
            showBorder: true,
            borderColor: PawColors.primary,
            borderWidth: 2,
            onTap: () {
              debugPrint('Bordered card tapped!');
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bordered Card',
                  style: PawTypography.h3,
                ),
                SizedBox(height: 8),
                Text(
                  'This card has a visible border with custom color and width.',
                  style: PawTypography.bodyMedium,
                ),
              ],
            ),
          ),

          PawSpacing.verticalLG,

          
          const Text(
            'Card Grid',
            style: PawTypography.h3,
          ),
          PawSpacing.verticalMD,
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: PawSpacing.md,
            mainAxisSpacing: PawSpacing.md,
            childAspectRatio: 1.2,
            children: [
              PawCard(
                onTap: () => debugPrint('Card 1 tapped'),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets, size: 48, color: PawColors.primary),
                      SizedBox(height: 8),
                      Text('Card 1', style: PawTypography.labelMedium),
                    ],
                  ),
                ),
              ),
              PawCard(
                onTap: () => debugPrint('Card 2 tapped'),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, size: 48, color: PawColors.secondary),
                      SizedBox(height: 8),
                      Text('Card 2', style: PawTypography.labelMedium),
                    ],
                  ),
                ),
              ),
              PawCard(
                onTap: () => debugPrint('Card 3 tapped'),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 48, color: PawColors.warning),
                      SizedBox(height: 8),
                      Text('Card 3', style: PawTypography.labelMedium),
                    ],
                  ),
                ),
              ),
              PawCard(
                onTap: () => debugPrint('Card 4 tapped'),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events, size: 48, color: PawColors.success),
                      SizedBox(height: 8),
                      Text('Card 4', style: PawTypography.labelMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),

          PawSpacing.verticalXL,
        ],
      ),
    );
  }
}
