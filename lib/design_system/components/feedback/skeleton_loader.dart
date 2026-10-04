import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_durations.dart';



class SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });
  
  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PawDurations.shimmerCycle,
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - _controller.value * 2, 0.0),
              end: Alignment(1.0 - _controller.value * 2, 0.0),
              colors: const [
                Color(0xFF2A2C32),
                Color(0xFF353842),
                Color(0xFF2A2C32),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}


class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;
  
  const SkeletonText({
    super.key,
    this.width,
    this.height = 16.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: 4.0,
    );
  }
}


class SkeletonCircle extends StatelessWidget {
  final double size;
  
  const SkeletonCircle({
    super.key,
    this.size = 40.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }
}
