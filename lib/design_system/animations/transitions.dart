import 'package:flutter/material.dart';
import 'paw_animations.dart';


enum PawTransitionType {
  slide,
  fade,
  scale,
  fadeThrough,
}



class PawPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final PawTransitionType transitionType;
  
  PawPageRoute({
    required this.page,
    this.transitionType = PawTransitionType.slide,
    super.settings,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _buildTransition(
        child: child,
        animation: animation,
        transitionType: transitionType,
      );
    },
    transitionDuration: PawAnimations.pageTransition,
  );
  
  static Widget _buildTransition({
    required Widget child,
    required Animation<double> animation,
    required PawTransitionType transitionType,
  }) {
    switch (transitionType) {
      case PawTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: PawAnimations.standard,
          )),
          child: child,
        );
      
      case PawTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      
      case PawTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: PawAnimations.standard),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      
      case PawTransitionType.fadeThrough:
        
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
          )),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
            )),
            child: child,
          ),
        );
    }
  }
}



class PawHero extends StatelessWidget {
  final String tag;
  final Widget child;
  
  const PawHero({
    super.key,
    required this.tag,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        
        final Hero toHero = toHeroContext.widget as Hero;
        
        return FadeTransition(
          opacity: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: PawAnimations.standard,
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: PawAnimations.decelerate,
              ),
            ),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(toHeroContext).style,
              child: toHero.child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
