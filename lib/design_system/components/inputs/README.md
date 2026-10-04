# Input Components

This directory contains enhanced input components for the Pawfect design system.

## PawTextField

An enhanced text field component with animations, visual feedback, and comprehensive features.

### Features

- **Floating Label Animation**: Label floats up with 150ms smooth animation when focused or has content
- **Focus Shadow Effect**: Subtle shadow appears when field is focused for better visual feedback
- **Error State**: 
  - Shake animation (3 cycles, 400ms total) when error appears
  - Red border and error icon
  - Error message display with icon below field
- **Success State**: Green checkmark icon when validation passes
- **Clear Button**: Fade-in animation, appears when text is present
- **Character Counter**: Shows character count when enabled
- **Prefix/Suffix Icons**: Support for icons before and after input
- **Password Toggle**: Automatic visibility toggle icon for password fields
- **Multiline Support**: Configurable line count
- **Validation**: Built-in validator support
- **All Standard TextField Properties**: Full compatibility with Flutter's TextField

### Requirements

Implements Requirements:
- 2.2: Enhanced Visual Hierarchy and Spacing
- 5.1: Form interaction with visual feedback
- 5.2: Real-time validation feedback
- 5.3: Error state styling and shake animation
- 5.6: Form submission flow

### Usage

#### Basic Text Field

```dart
PawTextField(
  label: 'Dog Name',
  hint: 'Enter your dog\'s name',
  prefixIcon: Icon(Icons.pets),
  onChanged: (value) {
    print('Name: $value');
  },
)
```

#### Email Field with Validation

```dart
final emailController = TextEditingController();
String? emailError;
bool emailSuccess = false;

void validateEmail(String value) {
  setState(() {
    if (value.isEmpty) {
      emailError = null;
      emailSuccess = false;
    } else if (!value.contains('@')) {
      emailError = 'Please enter a valid email address';
      emailSuccess = false;
    } else {
      emailError = null;
      emailSuccess = true;
    }
  });
}

// In widget tree:
PawTextField(
  label: 'Email',
  controller: emailController,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icon(Icons.email),
  errorText: emailError,
  showSuccessState: emailSuccess,
  onChanged: validateEmail,
  helperText: 'We\'ll never share your email',
)
```

#### Password Field

```dart
PawTextField(
  label: 'Password',
  obscureText: true,
  prefixIcon: Icon(Icons.lock),
  helperText: 'Must be at least 8 characters',
  showClearButton: false, // Optional: hide clear button for passwords
)
```

#### Multiline Text Field with Character Counter

```dart
PawTextField(
  label: 'Biography',
  hint: 'Tell us about your dog',
  maxLines: 5,
  maxLength: 500,
  showCharacterCount: true,
  prefixIcon: Icon(Icons.description),
)
```

#### Disabled Field

```dart
PawTextField(
  label: 'Breed',
  hint: 'Golden Retriever',
  enabled: false,
  prefixIcon: Icon(Icons.block),
)
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `label` | `String?` | `null` | Label text that floats when focused |
| `hint` | `String?` | `null` | Hint text shown when field is empty |
| `helperText` | `String?` | `null` | Helper text shown below field |
| `errorText` | `String?` | `null` | Error text (triggers shake animation) |
| `controller` | `TextEditingController?` | `null` | Text controller |
| `keyboardType` | `TextInputType?` | `null` | Keyboard type |
| `obscureText` | `bool` | `false` | Whether to obscure text (passwords) |
| `enabled` | `bool` | `true` | Whether field is enabled |
| `maxLines` | `int?` | `1` | Maximum lines (null for unlimited) |
| `maxLength` | `int?` | `null` | Maximum character length |
| `prefixIcon` | `Widget?` | `null` | Icon before input |
| `suffixIcon` | `Widget?` | `null` | Icon after input |
| `onChanged` | `ValueChanged<String>?` | `null` | Callback when text changes |
| `onTap` | `VoidCallback?` | `null` | Callback when field is tapped |
| `validator` | `FormFieldValidator<String>?` | `null` | Validator function |
| `showCharacterCount` | `bool` | `false` | Show character counter |
| `autofocus` | `bool` | `false` | Autofocus on mount |
| `showClearButton` | `bool` | `true` | Show clear button when text present |
| `showSuccessState` | `bool` | `false` | Show success checkmark |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Callback on keyboard submit |
| `textInputAction` | `TextInputAction?` | `null` | Keyboard action button |
| `focusNode` | `FocusNode?` | `null` | Custom focus node |
| `textCapitalization` | `TextCapitalization` | `none` | Text capitalization |

### Animations

1. **Focus Transition** (150ms): Border width, color, and shadow
2. **Label Float** (150ms): Label size and position
3. **Shake Animation** (400ms): Horizontal oscillation on error (3 cycles)
4. **Clear Button Fade** (150ms): Opacity transition
5. **Success/Error Icon** (200ms): Fade in/out

### Design Tokens Used

- **Colors**: `PawColors.primary`, `PawColors.error`, `PawColors.success`, `PawColors.textPrimary`, etc.
- **Typography**: `PawTypography.bodyLarge`, `PawTypography.bodySmall`
- **Spacing**: Standard 16dp padding
- **Radius**: `PawRadius.input` (12dp)
- **Durations**: `PawDurations.fast` (150ms), `PawDurations.short` (200ms)

### Accessibility

- Proper semantic labels for screen readers
- Minimum 48x48dp touch targets
- High contrast error/success states
- Clear visual feedback for all states
- Password visibility toggle labeled

### Notes

- The shake animation automatically triggers when `errorText` changes from null to a value
- Password fields automatically get a visibility toggle icon
- Clear button automatically appears when text is present (unless disabled)
- Success and error states are mutually exclusive (success takes precedence)
- Focus shadow only appears when field is focused and not in error state
- Character counter is only shown when both `showCharacterCount` is true and `maxLength` is set

### Example App

See `paw_text_field_example.dart` for a complete example demonstrating all features.
