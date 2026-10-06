import 'package:flutter/material.dart';
import '../../animations/paw_animations.dart';

class LoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget skeleton;
  final Widget child;
  final Duration duration;
  
  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
    this.duration = PawAnimations.medium,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: PawAnimations.fadeIn,
      switchOutCurve: PawAnimations.fadeOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: isLoading
          ? KeyedSubtree(
              key: const ValueKey('skeleton'),
              child: skeleton,
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: child,
            ),
    );
  }
}



class LoadingListWrapper extends StatelessWidget {
  final bool isLoading;
  final int skeletonCount;
  final Widget Function(int index) skeletonBuilder;
  final List<Widget> children;
  final Duration duration;
  final bool enableStagger;
  
  const LoadingListWrapper({
    super.key,
    required this.isLoading,
    required this.skeletonCount,
    required this.skeletonBuilder,
    required this.children,
    this.duration = PawAnimations.medium,
    this.enableStagger = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        children: List.generate(
          skeletonCount,
          (index) => enableStagger
              ? _StaggeredFadeIn(
                  delay: PawAnimations.staggerDelay(index),
                  child: skeletonBuilder(index),
                )
              : skeletonBuilder(index),
        ),
      );
    }
    
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: PawAnimations.fadeIn,
      switchOutCurve: PawAnimations.fadeOut,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      child: KeyedSubtree(
        key: ValueKey(isLoading),
        child: Column(children: children),
      ),
    );
  }
}


class _StaggeredFadeIn extends StatefulWidget {
  final Duration delay;
  final Widget child;
  
  const _StaggeredFadeIn({
    required this.delay,
    required this.child,
  });
  
  @override
  State<_StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<_StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PawAnimations.medium,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: PawAnimations.fadeIn,
    );
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
