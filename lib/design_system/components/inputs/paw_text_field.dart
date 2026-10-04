import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_radius.dart';
import '../../tokens/paw_durations.dart';
import '../../animations/paw_animations.dart';















class PawTextField extends StatefulWidget {
  
  final String? label;

  
  final String? hint;

  
  final String? helperText;

  
  final String? errorText;

  
  final TextEditingController? controller;

  
  final TextInputType? keyboardType;

  
  final bool obscureText;

  
  final bool enabled;

  
  final int? maxLines;

  
  final int? maxLength;

  
  final Widget? prefixIcon;

  
  final Widget? suffixIcon;

  
  final ValueChanged<String>? onChanged;

  
  final VoidCallback? onTap;

  
  final FormFieldValidator<String>? validator;

  
  final bool showCharacterCount;

  
  final bool autofocus;

  
  final bool showClearButton;

  
  final bool showSuccessState;

  
  final ValueChanged<String>? onSubmitted;

  
  final TextInputAction? textInputAction;

  
  final FocusNode? focusNode;

  
  final TextCapitalization textCapitalization;

  const PawTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.validator,
    this.showCharacterCount = false,
    this.autofocus = false,
    this.showClearButton = true,
    this.showSuccessState = false,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<PawTextField> createState() => _PawTextFieldState();
}

class _PawTextFieldState extends State<PawTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late FocusNode _internalFocusNode;
  late TextEditingController _internalController;
  
  bool _isFocused = false;
  bool _obscureTextToggled = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;
  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();

    
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }

    
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }

    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400), 
      vsync: this,
    );

    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.linear,
    ));

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(PawTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    
    if (widget.errorText != null && oldWidget.errorText == null) {
      _playShakeAnimation();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _playShakeAnimation() {
    _shakeController.forward(from: 0.0);
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  void _toggleObscureText() {
    setState(() {
      _obscureTextToggled = !_obscureTextToggled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * (widget.errorText != null ? 1 : 0),
            0,
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(),
          _buildHelperOrErrorText(),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150), 
      curve: PawAnimations.standard,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PawRadius.input),
        boxShadow: _isFocused && widget.enabled && widget.errorText == null
            ? [
                BoxShadow(
                  color: PawColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText && !_obscureTextToggled,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.showCharacterCount ? widget.maxLength : null,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        onSubmitted: widget.onSubmitted,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: PawTypography.bodyLarge.copyWith(
          color: widget.enabled
              ? Theme.of(context).colorScheme.onSurface
              : PawColors.textDisabled,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          filled: true,
          fillColor: widget.enabled
              ? Theme.of(context).cardColor
              : Theme.of(context).cardColor.withValues(alpha: 0.5),
          labelStyle: TextStyle(
              color: _getLabelColor(context),
            fontSize: 16,
          ),
          floatingLabelStyle: TextStyle(
              color: _getLabelColor(context),
            fontSize: 12,
          ),
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: widget.errorText != null
                  ? PawColors.error
                  : Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(PawRadius.input),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _getBorderColor(context),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(PawRadius.input),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: PawColors.error, width: 1),
            borderRadius: BorderRadius.circular(PawRadius.input),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: PawColors.error, width: 2),
            borderRadius: BorderRadius.circular(PawRadius.input),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(PawRadius.input),
          ),
          
          errorText: null,
          
          helperText: null,
          counterStyle: PawTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Color _getLabelColor(BuildContext context) {
    if (!widget.enabled) return PawColors.textDisabled;
    if (widget.errorText != null) return PawColors.error;
    if (widget.showSuccessState) return PawColors.success;
    if (_isFocused) return PawColors.primary;
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _getBorderColor(BuildContext context) {
    if (widget.errorText != null) return PawColors.error;
    if (widget.showSuccessState) return PawColors.success;
    return PawColors.primary;
  }

  Widget? _buildSuffixIcon() {
    
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    
    if (widget.showSuccessState && _controller.text.isNotEmpty) {
      return const Icon(
        Icons.check_circle,
        color: PawColors.success,
        size: 20,
      );
    }

    if (widget.errorText != null) {
      return const Icon(
        Icons.error,
        color: PawColors.error,
        size: 20,
      );
    }

    
    final widgets = <Widget>[];

    
    if (widget.obscureText) {
      widgets.add(
        IconButton(
          icon: Icon(
            _obscureTextToggled ? Icons.visibility : Icons.visibility_off,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: _toggleObscureText,
          tooltip: _obscureTextToggled ? 'Hide password' : 'Show password',
        ),
      );
    }

    
    if (widget.showClearButton &&
        widget.enabled &&
        _controller.text.isNotEmpty) {
      widgets.add(
        AnimatedOpacity(
          duration: PawDurations.fast,
          opacity: _controller.text.isNotEmpty ? 1.0 : 0.0,
          child: IconButton(
            icon: const Icon(
              Icons.clear,
              size: 20,
                color: PawColors.textSecondary,
            ),
            onPressed: _clearText,
            tooltip: 'Clear',
          ),
        ),
      );
    }

    if (widgets.isEmpty) return null;
    if (widgets.length == 1) return widgets.first;

    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  Widget _buildHelperOrErrorText() {
    
    if (widget.errorText != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 4),
        child: AnimatedOpacity(
          duration: PawDurations.short,
          opacity: 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: PawColors.error,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: PawTypography.bodySmall.copyWith(
                    color: PawColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.helperText != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 4),
        child: Text(
          widget.helperText!,
          style: PawTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
