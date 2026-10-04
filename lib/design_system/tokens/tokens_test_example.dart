



library;

import 'package:flutter/material.dart';
import 'tokens.dart';

class TokensExampleWidget extends StatelessWidget {
  const TokensExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Container(
      color: PawColors.background,
      padding: PawSpacing.contentInsets,
      child: Column(
        children: [
          
          Text(
            'Welcome to Pawfect',
            style: PawTypography.h1,
          ),
          PawSpacing.verticalMD,
          Text(
            'Find your perfect breeding match',
            style: PawTypography.bodyLarge.copyWith(
              color: PawColors.textSecondary,
            ),
          ),
          PawSpacing.verticalLG,
          
          Card(
            elevation: PawElevation.medium,
            color: PawColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawRadius.card),
            ),
            child: Padding(
              padding: PawSpacing.cardInsets,
              child: Text(
                'This is a card with design tokens',
                style: PawTypography.bodyMedium,
              ),
            ),
          ),
          PawSpacing.verticalMD,
          
          AnimatedContainer(
            duration: PawDurations.transition,
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: PawSpacing.md,
              vertical: PawSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: PawColors.primary,
              borderRadius: BorderRadius.circular(PawRadius.button),
            ),
            child: Text(
              'Get Started',
              style: PawTypography.labelLarge.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
