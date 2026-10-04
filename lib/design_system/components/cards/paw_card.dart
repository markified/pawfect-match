import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_elevation.dart';
import '../../tokens/paw_radius.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_durations.dart';














class PawCard extends StatefulWidget {
  
  final Widget child;

  
  final VoidCallback? onTap;

  
  final EdgeInsetsGeometry? padding;

  
  final double? borderRadius;

  
  final Color? backgroundColor;

  
  final EdgeInsetsGeometry? margin;

  
  final bool showBorder;

  
  final Color? borderColor;

  
  final double borderWidth;

  
  final double? elevation;

  
  final double? pressedElevation;

  
  final double? width;

  
  final double? height;

  
  final Clip clipBehavior;

  const PawCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.margin,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 1.0,
    this.elevation,
    this.pressedElevation,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  State<PawCard> createState() => _PawCardState();
}

class _PawCardState extends State<PawCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = widget.padding ?? PawSpacing.cardInsets;
    final effectiveBorderRadius = widget.borderRadius ?? PawRadius.card;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? theme.cardColor;
    final normalElevation = widget.elevation ?? PawElevation.low;
    final pressedElevationValue = widget.pressedElevation ?? PawElevation.medium;
    final currentElevation = _isPressed ? pressedElevationValue : normalElevation;

    final cardContent = Container(
      width: widget.width,
      height: widget.height,
      padding: effectivePadding,
      child: widget.child,
    );

    
    if (widget.onTap != null) {
      return Container(
        margin: widget.margin,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedContainer(
            duration: PawDurations.microInteraction,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: currentElevation * 2,
                  offset: Offset(0, currentElevation / 2),
                ),
              ],
            ),
            child: Material(
              color: effectiveBackgroundColor,
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
              clipBehavior: widget.clipBehavior,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(effectiveBorderRadius),
                splashColor: PawColors.ripple,
                highlightColor: PawColors.hover,
                child: widget.showBorder
                    ? _buildBorderedContent(cardContent, effectiveBorderRadius)
                    : cardContent,
              ),
            ),
          ),
        ),
      );
    }

    
    return Container(
      margin: widget.margin,
      child: AnimatedContainer(
        duration: PawDurations.microInteraction,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          border: widget.showBorder
              ? Border.all(
                  color: widget.borderColor ?? theme.colorScheme.primary,
                  width: widget.borderWidth,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: currentElevation * 2,
              offset: Offset(0, currentElevation / 2),
            ),
          ],
        ),
        clipBehavior: widget.clipBehavior,
        child: cardContent,
      ),
    );
  }

  Widget _buildBorderedContent(Widget content, double borderRadius) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.borderColor ?? Theme.of(context).colorScheme.primary,
          width: widget.borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: content,
    );
  }
}
