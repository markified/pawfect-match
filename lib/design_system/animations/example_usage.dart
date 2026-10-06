import 'package:flutter/material.dart';
import 'paw_animations.dart';
import 'transitions.dart';
import 'micro_interactions.dart';

void navigateWithSlideTransition(BuildContext context, Widget destination) {
  Navigator.push(
    context,
    PawPageRoute(
      page: destination,
      transitionType: PawTransitionType.slide,
    ),
  );
}

void navigateWithFadeTransition(BuildContext context, Widget destination) {
  Navigator.push(
    context,
    PawPageRoute(
      page: destination,
      transitionType: PawTransitionType.fade,
    ),
  );
}


class DogImageWithHero extends StatelessWidget {
  final String dogId;
  final String imageUrl;
  
  const DogImageWithHero({
    super.key,
    required this.dogId,
    required this.imageUrl,
  });
  
  @override
  Widget build(BuildContext context) {
    return PawHero(
      tag: 'dog-$dogId',
      child: Image.network(imageUrl),
    );
  }
}


class AnimatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  
  const AnimatedButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return PressAnimation(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}


class FormWithSuccessAnimation extends StatefulWidget {
  const FormWithSuccessAnimation({super.key});
  
  @override
  State<FormWithSuccessAnimation> createState() => _FormWithSuccessAnimationState();
}

class _FormWithSuccessAnimationState extends State<FormWithSuccessAnimation> {
  bool _showSuccess = false;
  
  void _submitForm() {
    
    setState(() {
      _showSuccess = true;
    });
    
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSuccess = false;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Submit'),
        ),
        SuccessAnimation(
          show: _showSuccess,
          size: 100,
          color: Colors.green,
        ),
      ],
    );
  }
}


class CustomAnimatedWidget extends StatefulWidget {
  const CustomAnimatedWidget({super.key});
  
  @override
  State<CustomAnimatedWidget> createState() => _CustomAnimatedWidgetState();
}

class _CustomAnimatedWidgetState extends State<CustomAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PawAnimations.medium,
      vsync: this,
    );
    
    
    _scaleAnimation = PawAnimations.createScaleAnimation(
      controller: _controller,
      begin: 0.5,
      end: 1.0,
    );
    
    _slideAnimation = PawAnimations.createSlideAnimation(
      controller: _controller,
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    );
    
    _fadeAnimation = PawAnimations.createFadeAnimation(
      controller: _controller,
      begin: 0.0,
      end: 1.0,
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}


class StaggeredListExample extends StatelessWidget {
  final List<String> items;
  
  const StaggeredListExample({
    super.key,
    required this.items,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: PawAnimations.medium,
          curve: PawAnimations.decelerate,
          
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: ListTile(
            title: Text(items[index]),
          ),
        );
      },
    );
  }
}
