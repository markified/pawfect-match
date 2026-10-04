import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_durations.dart';



class PawRefreshIndicator extends StatelessWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final Color? color;
  
  const PawRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? PawColors.primary,
      backgroundColor: PawColors.cardBackground,
      strokeWidth: 3.0,
      child: child,
    );
  }
}


class PawRefreshIndicatorCustom extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  
  const PawRefreshIndicatorCustom({
    super.key,
    required this.child,
    required this.onRefresh,
  });
  
  @override
  State<PawRefreshIndicatorCustom> createState() => _PawRefreshIndicatorCustomState();
}

class _PawRefreshIndicatorCustomState extends State<PawRefreshIndicatorCustom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
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
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _controller.repeat();
        await widget.onRefresh();
        _controller.stop();
        _controller.reset();
      },
      color: PawColors.primary,
      backgroundColor: PawColors.cardBackground,
      child: widget.child,
    );
  }
}
