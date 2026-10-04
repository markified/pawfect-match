# Pawfect Animation Framework

This directory contains the animation utilities and components for the Pawfect app, providing smooth, consistent animations throughout the application.

## Components

### 1. paw_animations.dart

Core animation utilities including:

- **Standard Curves**: Material Design standard curves (standard, decelerate, accelerate, spring)
- **Animation Durations**: Predefined durations (fast: 150ms, short: 200ms, medium: 300ms, long: 400ms, xlong: 500ms)
- **Stagger Helpers**: `staggerDelay()` for sequential item animations
- **Animation Factory Methods**:
  - `createScaleAnimation()` - Scale animations with customizable begin/end values
  - `createSlideAnimation()` - Slide animations with offset control
  - `createFadeAnimation()` - Fade animations with opacity control

**Usage Example:**
```dart
final controller = AnimationController(
  duration: PawAnimations.medium,
  vsync: this,
);

final scaleAnimation = PawAnimations.createScaleAnimation(
  controller: controller,
  begin: 0.8,
  end: 1.0,
);
```

### 2. transitions.dart

Screen transition utilities:

- **PawPageRoute**: Custom page route with 4 transition types
  - `slide` - Slide from right (default)
  - `fade` - Simple fade in
  - `scale` - Scale + fade combination
  - `fadeThrough` - Material Design fade through transition

- **PawHero**: Enhanced Hero widget with custom flight animation for smoother shared element transitions

**Usage Example:**
```dart
// Navigate with slide transition
Navigator.push(
  context,
  PawPageRoute(
    page: DetailsScreen(),
    transitionType: PawTransitionType.slide,
  ),
);

// Shared element transition
PawHero(
  tag: 'dog-${dog.id}',
  child: Image.network(dog.imageUrl),
)
```

### 3. micro_interactions.dart

Reusable micro-interaction animations:

- **PressAnimation**: Button press feedback (scale down to 0.95 on tap)
- **ToggleAnimation**: Smooth toggle transitions between states
- **SuccessAnimation**: Animated checkmark with scale effect (500ms duration)
- **ShimmerAnimation**: Loading shimmer effect for skeleton screens

**Usage Example:**
```dart
// Press animation
PressAnimation(
  onPressed: () => print('Tapped!'),
  child: Container(
    padding: EdgeInsets.all(16),
    child: Text('Press Me'),
  ),
)

// Success animation
SuccessAnimation(
  show: formSubmitted,
  size: 80,
  color: Colors.green,
  onComplete: () => Navigator.pop(context),
)

// Shimmer effect
ShimmerAnimation(
  child: Container(
    width: 200,
    height: 100,
    color: Colors.grey[300],
  ),
)
```

## Animation Guidelines

### Durations
- **Micro-interactions**: 150ms (fast) - button presses, toggles
- **Transitions**: 300ms (medium) - screen transitions, modal animations
- **Page transitions**: 400ms (long) - full-page navigation
- **Success/celebration**: 500ms (xlong) - confirmation animations

### Curves
- **standard** (easeInOutCubic): Default for most animations
- **decelerate** (easeOut): Enter animations, expanding elements
- **accelerate** (easeIn): Exit animations, collapsing elements
- **spring** (elasticOut): Playful, attention-grabbing animations

### Best Practices

1. **Use consistent durations**: Stick to predefined duration constants
2. **Respect reduced motion**: Always check accessibility settings
3. **Keep it subtle**: Animations should enhance, not distract
4. **Test on real devices**: Verify 60fps performance
5. **Stagger wisely**: Limit stagger to 5 items max to avoid excessive delays

## Requirements Mapping

This animation framework satisfies the following requirements:

- **Requirement 4.1**: Platform-appropriate screen transitions (slide, fade, scale)
- **Requirement 4.2**: Shared element transitions with hero animations
- **Requirement 4.3**: Bottom sheet animations with backdrop effects
- **Requirement 4.4**: List item entrance animations with staggered timing
- **Requirement 4.5**: Skeleton screen loaders with shimmer effects
- **Requirement 4.6**: Micro-interactions (button press, toggle, success)

## See Also

- `example_usage.dart` - Detailed usage examples
- `../tokens/paw_durations.dart` - Duration token definitions (if needed)
- Design document: `.kiro/specs/ui-design-improvements/design.md`
