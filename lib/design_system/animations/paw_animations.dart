import 'package:flutter/material.dart';



class PawAnimations {
  
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve spring = Curves.elasticOut;
  
  
  static const Curve buttonPress = Curves.easeInOut;
  static const Curve cardSlide = Curves.easeOutQuart;
  static const Curve fadeIn = Curves.easeIn;
  static const Curve fadeOut = Curves.easeOut;
  
  
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 400);
  static const Duration xlong = Duration(milliseconds: 500);
  
  
  static const Duration microInteraction = fast;
  static const Duration transition = medium;
  static const Duration pageTransition = long;
  static const Duration modalTransition = medium;
  
  
  
  
  static Duration staggerDelay(int index, {int maxItems = 5}) {
    final clampedIndex = index.clamp(0, maxItems - 1);
    return Duration(milliseconds: clampedIndex * 50);
  }
  
  
  
  
  
  
  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    double begin = 0.8,
    double end = 1.0,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  
  
  
  
  
  static Animation<Offset> createSlideAnimation({
    required AnimationController controller,
    Offset begin = const Offset(0, 0.1),
    Offset end = Offset.zero,
    Curve curve = Curves.easeOut,
  }) {
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
  
  
  
  
  
  
  static Animation<double> createFadeAnimation({
    required AnimationController controller,
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeIn,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: curve),
    );
  }
}



class AnimatedPawWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool animate;
  
  const AnimatedPawWidget({
    super.key,
    required this.child,
    this.duration = PawAnimations.medium,
    this.curve = PawAnimations.standard,
    this.animate = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: child,
    );
  }
}
