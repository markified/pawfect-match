import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_elevation.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_durations.dart';

class PawFAB extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isExtended;
  final bool mini;
  
  const PawFAB({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.isExtended = false,
    this.mini = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: PawColors.primary,
        foregroundColor: Colors.white,
        elevation: PawElevation.fab,
      );
    }
    
    if (mini) {
      return FloatingActionButton.small(
        onPressed: onPressed,
        backgroundColor: PawColors.primary,
        foregroundColor: Colors.white,
        elevation: PawElevation.fab,
        child: Icon(icon),
      );
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: PawColors.primary,
      foregroundColor: Colors.white,
      elevation: PawElevation.fab,
      child: Icon(icon),
    );
  }
}


class PawSpeedDialFAB extends StatefulWidget {
  final IconData icon;
  final List<SpeedDialAction> actions;
  
  const PawSpeedDialFAB({
    super.key,
    required this.icon,
    required this.actions,
  });
  
  @override
  State<PawSpeedDialFAB> createState() => _PawSpeedDialFABState();
}

class _PawSpeedDialFABState extends State<PawSpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PawDurations.medium,
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              color: PawColors.overlay,
            ),
          ),
        
        
        ...List.generate(widget.actions.length, (index) {
          final action = widget.actions[index];
          final delay = index * 50;
          
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  delay / (widget.actions.length * 50),
                  1.0,
                  curve: Curves.easeOut,
                ),
              ));
              
              return Transform.translate(
                offset: Offset(0, -70.0 * (index + 1) * animation.value),
                child: Opacity(
                  opacity: animation.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (action.label != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PawSpacing.sm,
                          vertical: PawSpacing.xs,
                        ),
                        child: Text(
                          action.label!,
                          style: PawTypography.labelMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: PawSpacing.sm),
                  ],
                  FloatingActionButton.small(
                    onPressed: () {
                      _toggle();
                      action.onTap();
                    },
                    backgroundColor: action.backgroundColor ?? PawColors.primary,
                    foregroundColor: Colors.white,
                    heroTag: 'speed_dial_$index',
                    child: Icon(action.icon),
                  ),
                ],
              ),
            ),
          );
        }),
        
        
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: PawColors.primary,
          foregroundColor: Colors.white,
          elevation: PawElevation.fab,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: PawDurations.medium,
            child: Icon(widget.icon),
          ),
        ),
      ],
    );
  }
}


class SpeedDialAction {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  
  const SpeedDialAction({
    required this.icon,
    this.label,
    required this.onTap,
    this.backgroundColor,
  });
}
