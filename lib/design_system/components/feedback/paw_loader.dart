import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_spacing.dart';



class PawLoader extends StatelessWidget {
  final PawLoaderSize size;
  final String? label;
  final Color? color;
  
  const PawLoader({
    super.key,
    this.size = PawLoaderSize.medium,
    this.label,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size.dimension,
          height: size.dimension,
          child: CircularProgressIndicator(
            strokeWidth: size.strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? PawColors.primary,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: PawSpacing.sm),
          Text(
            label!,
            style: PawTypography.bodyMedium.copyWith(
              color: PawColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

enum PawLoaderSize {
  small(20.0, 2.0),
  medium(40.0, 3.0),
  large(60.0, 4.0);
  
  final double dimension;
  final double strokeWidth;
  
  const PawLoaderSize(this.dimension, this.strokeWidth);
}


class PawLoaderOverlay extends StatelessWidget {
  final String? label;
  
  const PawLoaderOverlay({
    super.key,
    this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PawColors.overlay,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(PawSpacing.lg),
            child: PawLoader(
              size: PawLoaderSize.large,
              label: label,
            ),
          ),
        ),
      ),
    );
  }
}
