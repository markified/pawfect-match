# Design Tokens

This directory contains all the design tokens for the Pawfect application. Design tokens are the visual design atoms of the design system — specifically, they are named entities that store visual design attributes.

## Files

### Core Token Files

1. **paw_colors.dart** - Complete color palette
   - Primary colors (Steel blue: #0369A1)
   - Secondary colors (Coral: #B91C1C)
   - Semantic colors (success, warning, error, info)
   - Surface colors (backgrounds, cards)
   - Text colors (primary, secondary, tertiary, disabled)
   - Border colors
   - Overlay colors
   - Interactive state colors (ripple, hover, focus)

2. **paw_typography.dart** - Typography scale with 8 text styles
   - `displayLarge` - 32sp/bold - Hero headings
   - `h1` - 28sp/bold - Screen titles
   - `h2` - 22sp/bold - Section headers
   - `h3` - 18sp/semibold - Subsection headers
   - `bodyLarge` - 16sp - Primary content
   - `bodyMedium` - 14sp - Secondary content
   - `bodySmall` - 12sp - Captions
   - `labelLarge` - 16sp/semibold - Button text (large)
   - `labelMedium` - 14sp/semibold - Button text (medium)
   - `labelSmall` - 12sp/semibold - Chip text
   - `caption` - 11sp - Metadata

3. **paw_spacing.dart** - Spacing scale based on 4dp units
   - `xs` = 4dp
   - `sm` = 8dp
   - `md` = 16dp (base)
   - `lg` = 24dp
   - `xl` = 32dp
   - `xxl` = 48dp
   - Semantic spacing (contentPadding, cardPadding, etc.)
   - Helper widgets (verticalMD, horizontalLG, etc.)

4. **paw_elevation.dart** - Elevation levels for shadows
   - `flat` = 0dp
   - `low` = 2dp
   - `medium` = 4dp
   - `high` = 8dp
   - `veryHigh` = 12dp
   - `modal` = 16dp

5. **paw_radius.dart** - Border radius values
   - `none` = 0
   - `sm` = 8dp
   - `md` = 12dp
   - `lg` = 16dp
   - `xl` = 20dp
   - `full` = 9999dp (circular)
   - Semantic radius (button, card, input, chip, avatar)

6. **paw_durations.dart** - Animation durations
   - `instant` = 0ms
   - `fast` = 150ms
   - `short` = 200ms
   - `medium` = 300ms
   - `long` = 400ms
   - `xlong` = 500ms
   - Semantic durations (microInteraction, transition, pageTransition, etc.)
   - Auto-dismiss durations (snackbar, tooltip, toast)

### Helper Files

- **tokens.dart** - Barrel file that exports all token files for easy import
- **tokens_test_example.dart** - Example usage demonstrating how to use tokens
- **README.md** - This documentation file

## Usage

Import all tokens at once:

```dart
import 'package:pawfect/design_system/tokens/tokens.dart';
```

Or import individual token files:

```dart
import 'package:pawfect/design_system/tokens/paw_colors.dart';
import 'package:pawfect/design_system/tokens/paw_typography.dart';
```

### Example Usage

```dart
Container(
  padding: PawSpacing.contentInsets,
  decoration: BoxDecoration(
    color: PawColors.cardBackground,
    borderRadius: BorderRadius.circular(PawRadius.card),
  ),
  child: Text(
    'Hello Pawfect',
    style: PawTypography.h2,
  ),
)
```

## Requirements Coverage

This implementation satisfies the following requirements from the spec:

- ✅ **Requirement 1.1** - Color palettes (primary, secondary, surface, semantic)
- ✅ **Requirement 1.1** - Typography scales (8 text styles)
- ✅ **Requirement 1.1** - Spacing system (4px base with 6 levels)
- ✅ **Requirement 1.1** - Elevation levels (6 levels)
- ✅ **Requirement 1.1** - Border radius values (4 sizes)
- ✅ **Requirement 1.1** - Animation durations (3 timing presets)

## Design Principles

1. **Consistency** - Use tokens instead of hard-coded values
2. **Semantic Naming** - Use semantic tokens (e.g., `PawSpacing.contentPadding`) for common patterns
3. **Accessibility** - Color contrast ratios follow WCAG AA standards
4. **Flexibility** - Tokens can be composed and customized as needed
5. **Type Safety** - All tokens are strongly typed (Color, TextStyle, double, Duration)

## Next Steps

With the design tokens layer complete, the next phase is to build the component library that uses these tokens:

1. Enhanced buttons (PawButton)
2. Advanced text fields (PawTextField)
3. Card variants (PawCard, DogProfileCard, MatchCard)
4. Navigation components (PawBottomNav, PawAppBar)
5. Feedback components (PawSnackbar, SkeletonLoader)
