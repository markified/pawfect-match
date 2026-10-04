import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_spacing.dart';
import '../buttons/paw_button.dart';



class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PawSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(PawSpacing.lg),
              decoration: BoxDecoration(
                color: PawColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: PawColors.primary,
              ),
            ),
            const SizedBox(height: PawSpacing.lg),
            Text(
              title,
              style: PawTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PawSpacing.sm),
            Text(
              message,
              style: PawTypography.bodyMedium.copyWith(
                color: PawColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: PawSpacing.lg),
              PawButton(
                text: actionLabel,
                type: PawButtonType.primary,
                onPressed: onAction,
              ),
            ],
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: PawSpacing.sm),
              PawButton(
                text: secondaryActionLabel,
                type: PawButtonType.text,
                onPressed: onSecondaryAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}



class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final ErrorType type;
  
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.type = ErrorType.general,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PawSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(PawSpacing.lg),
              decoration: BoxDecoration(
                color: PawColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                size: 80,
                color: PawColors.error,
              ),
            ),
            const SizedBox(height: PawSpacing.lg),
            Text(
              title,
              style: PawTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PawSpacing.sm),
            Text(
              message,
              style: PawTypography.bodyMedium.copyWith(
                color: PawColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: PawSpacing.lg),
              PawButton(
                text: 'Retry',
                type: PawButtonType.primary,
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  IconData _getIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.permission:
        return Icons.lock_outline;
      case ErrorType.general:
        return Icons.error_outline;
    }
  }
}

enum ErrorType {
  network,
  server,
  permission,
  general,
}
