import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_radius.dart';
import '../../tokens/paw_durations.dart';



class PawSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = PawDurations.snackbar,
  }) {
    final color = _getColorForType(type);
    final icon = _getIconForType(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: PawSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: PawTypography.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PawRadius.sm),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
  
  static void success(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  static void error(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  static void warning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  static void info(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
  
  static Color _getColorForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return PawColors.success;
      case SnackbarType.error:
        return PawColors.error;
      case SnackbarType.warning:
        return PawColors.warning;
      case SnackbarType.info:
        return PawColors.info;
    }
  }
  
  static IconData _getIconForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
    }
  }
}

enum SnackbarType {
  success,
  error,
  warning,
  info,
}


class SnackbarQueue {
  static final SnackbarQueue _instance = SnackbarQueue._internal();
  factory SnackbarQueue() => _instance;
  SnackbarQueue._internal();
  
  final List<_QueuedSnackbar> _queue = [];
  bool _isShowing = false;
  
  void add(BuildContext context, _QueuedSnackbar snackbar) {
    _queue.add(snackbar);
    if (!_isShowing) {
      _showNext(context);
    }
  }
  
  Future<void> _showNext(BuildContext context) async {
    if (_queue.isEmpty) {
      _isShowing = false;
      return;
    }
    
    _isShowing = true;
    final snackbar = _queue.removeAt(0);
    
    PawSnackbar.show(
      context,
      message: snackbar.message,
      type: snackbar.type,
      actionLabel: snackbar.actionLabel,
      onAction: snackbar.onAction,
      duration: snackbar.duration,
    );
    
    await Future.delayed(snackbar.duration + const Duration(milliseconds: 500));
    _showNext(context);
  }
}

class _QueuedSnackbar {
  final String message;
  final SnackbarType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  
  _QueuedSnackbar({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    required this.duration,
  });
}
