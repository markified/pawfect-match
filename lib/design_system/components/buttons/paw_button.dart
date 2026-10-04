import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_durations.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_radius.dart';
import '../../tokens/paw_elevation.dart';



enum PawButtonType {
  
  primary,

  
  secondary,

  
  outlined,

  
  text,
}



enum PawButtonSize {
  
  small,

  
  medium,

  
  large,
}








class PawButton extends StatefulWidget {
  
  final String? text;

  
  final VoidCallback? onPressed;

  
  final PawButtonType type;

  
  final PawButtonSize size;

  
  final IconData? icon;

  
  final bool isLoading;

  
  final bool isFullWidth;

  
  final Color? customColor;

  const PawButton({
    super.key,
    this.text,
    this.onPressed,
    this.type = PawButtonType.primary,
    this.size = PawButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
  });

  @override
  State<PawButton> createState() => _PawButtonState();
}

class _PawButtonState extends State<PawButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    
    _controller = AnimationController(
      duration: PawDurations.microInteraction,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  
  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  
  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  
  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    
    
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : _handleTapDown,
      onTapUp: isDisabled ? null : _handleTapUp,
      onTapCancel: isDisabled ? null : _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildButton(context, isDisabled),
      ),
    );
  }

  Widget _buildButton(BuildContext context, bool isDisabled) {
    final buttonHeight = _getButtonHeight();
    final buttonColor = widget.customColor ?? _getButtonColor();
    final textColor = _getTextColor();

    
    final buttonContent = widget.isLoading
        ? _buildLoadingIndicator(textColor)
        : _buildButtonContent(textColor);

    final buttonWidget = _buildButtonByType(
      context: context,
      height: buttonHeight,
      color: buttonColor,
      textColor: textColor,
      content: buttonContent,
      isDisabled: isDisabled,
    );

    
    return widget.isFullWidth
        ? SizedBox(width: double.infinity, child: buttonWidget)
        : buttonWidget;
  }

  
  
  double _getButtonHeight() {
    switch (widget.size) {
      case PawButtonSize.small:
        return 36.0;
      case PawButtonSize.medium:
        return 48.0;
      case PawButtonSize.large:
        return 56.0;
    }
  }

  
  Color _getButtonColor() {
    switch (widget.type) {
      case PawButtonType.primary:
        return PawColors.primary;
      case PawButtonType.secondary:
        return PawColors.secondary;
      case PawButtonType.outlined:
      case PawButtonType.text:
        return Colors.transparent;
    }
  }

  
  Color _getTextColor() {
    switch (widget.type) {
      case PawButtonType.primary:
      case PawButtonType.secondary:
        return Colors.white;
      case PawButtonType.outlined:
      case PawButtonType.text:
        return widget.customColor ?? PawColors.primary;
    }
  }

  
  
  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  
  
  Widget _buildButtonContent(Color textColor) {
    if (widget.icon != null && widget.text != null) {
      
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: textColor),
          const SizedBox(width: PawSpacing.sm),
          Text(
            widget.text!,
            style: _getTextStyle().copyWith(color: textColor),
          ),
        ],
      );
    } else if (widget.icon != null) {
      
      return Icon(widget.icon, size: 20, color: textColor);
    } else {
      
      return Text(
        widget.text ?? '',
        style: _getTextStyle().copyWith(color: textColor),
      );
    }
  }

  
  TextStyle _getTextStyle() {
    switch (widget.size) {
      case PawButtonSize.small:
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: 0.1,
        );
      case PawButtonSize.medium:
      case PawButtonSize.large:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: 0.1,
        );
    }
  }

  
  
  Widget _buildButtonByType({
    required BuildContext context,
    required double height,
    required Color color,
    required Color textColor,
    required Widget content,
    required bool isDisabled,
  }) {
    switch (widget.type) {
      case PawButtonType.primary:
      case PawButtonType.secondary:
        return ElevatedButton(
          onPressed: isDisabled ? null : widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            
            disabledBackgroundColor: color.withValues(alpha: 0.5),
            elevation: PawElevation.low,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawRadius.button),
            ),
            minimumSize: Size(0, height),
            padding: const EdgeInsets.symmetric(horizontal: PawSpacing.md),
          ),
          child: content,
        );

      case PawButtonType.outlined:
        return OutlinedButton(
          onPressed: isDisabled ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor,
            disabledForegroundColor: textColor.withValues(alpha: 0.5),
            side: BorderSide(
              color: isDisabled ? textColor.withValues(alpha: 0.5) : textColor,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawRadius.button),
            ),
            minimumSize: Size(0, height),
            padding: const EdgeInsets.symmetric(horizontal: PawSpacing.md),
          ),
          child: content,
        );

      case PawButtonType.text:
        return TextButton(
          onPressed: isDisabled ? null : widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor,
            disabledForegroundColor: textColor.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawRadius.button),
            ),
            minimumSize: Size(0, height),
            padding: const EdgeInsets.symmetric(horizontal: PawSpacing.md),
          ),
          child: content,
        );
    }
  }
}
