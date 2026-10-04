import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_spacing.dart';
import '../../tokens/paw_radius.dart';
import '../../tokens/paw_durations.dart';
import '../../animations/paw_animations.dart';



class PawChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final VoidCallback? onDelete;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  
  const PawChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leadingIcon,
    this.onDelete,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: PawDurations.short,
      scale: selected ? 1.0 : 0.95,
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(PawRadius.chip),
          child: AnimatedContainer(
            duration: PawDurations.short,
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: onDelete != null ? PawSpacing.sm : PawSpacing.md,
              vertical: PawSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? (selectedColor ?? PawColors.primary.withValues(alpha: 0.2))
                  : (backgroundColor ?? Theme.of(context).cardColor),
              border: Border.all(
                color: selected
                  ? PawColors.primary
                  : Theme.of(context).colorScheme.primary,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(PawRadius.chip),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(
                    leadingIcon,
                    size: 18,
                    color: selected
                      ? PawColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: PawSpacing.xs),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: textColor ??
                      (selected
                        ? PawColors.primary
                        : Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: PawSpacing.xs),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.close,
                      size: 18,
                        color: selected
                          ? PawColors.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class ChipInput extends StatelessWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<String> onItemTap;
  final ValueChanged<String>? onItemRemove;
  final int? maxVisible;
  final Widget Function(String item, bool selected, VoidCallback onTap, VoidCallback? onRemove)? chipBuilder;
  final String? moreLabel;
  final VoidCallback? onMoreTap;
  
  const ChipInput({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onItemTap,
    this.onItemRemove,
    this.maxVisible,
    this.chipBuilder,
    this.moreLabel,
    this.onMoreTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final visibleItems = maxVisible != null && items.length > maxVisible!
        ? items.take(maxVisible!).toList()
        : items;
    final hiddenCount = maxVisible != null && items.length > maxVisible!
        ? items.length - maxVisible!
        : 0;
    
    return Wrap(
      spacing: PawSpacing.sm,
      runSpacing: PawSpacing.sm,
      children: [
        ...visibleItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = selectedItems.contains(item);
          
          
          if (chipBuilder != null) {
            return _AnimatedChipWrapper(
              key: ValueKey(item),
              index: index,
              child: chipBuilder!(
                item,
                isSelected,
                () => onItemTap(item),
                onItemRemove != null ? () => onItemRemove!(item) : null,
              ),
            );
          }
          
          
          return _AnimatedChipWrapper(
            key: ValueKey(item),
            index: index,
            child: PawChip(
              label: item,
              selected: isSelected,
              onTap: () => onItemTap(item),
              onDelete: onItemRemove != null ? () => onItemRemove!(item) : null,
            ),
          );
        }),
        if (hiddenCount > 0)
          InkWell(
            onTap: onMoreTap,
            borderRadius: BorderRadius.circular(PawRadius.chip),
            child: PawChip(
              label: moreLabel ?? '+$hiddenCount more',
              selected: false,
              backgroundColor: PawColors.surfaceElevated,
              onTap: onMoreTap,
            ),
          ),
      ],
    );
  }
}


class _AnimatedChipWrapper extends StatefulWidget {
  final Widget child;
  final int index;
  
  const _AnimatedChipWrapper({
    super.key,
    required this.child,
    required this.index,
  });
  
  @override
  State<_AnimatedChipWrapper> createState() => _AnimatedChipWrapperState();
}

class _AnimatedChipWrapperState extends State<_AnimatedChipWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PawAnimations.medium,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    
    Future.delayed(PawAnimations.staggerDelay(widget.index), () {
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}


class SelectedChipsView extends StatelessWidget {
  final List<String> selectedItems;
  final ValueChanged<String> onRemove;
  final int? maxVisible;
  final Widget Function(String item, VoidCallback onRemove)? chipBuilder;
  
  const SelectedChipsView({
    super.key,
    required this.selectedItems,
    required this.onRemove,
    this.maxVisible,
    this.chipBuilder,
  });
  
  @override
  Widget build(BuildContext context) {
    if (selectedItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final visibleItems = maxVisible != null && selectedItems.length > maxVisible!
        ? selectedItems.take(maxVisible!).toList()
        : selectedItems;
    final hiddenCount = maxVisible != null && selectedItems.length > maxVisible!
        ? selectedItems.length - maxVisible!
        : 0;
    
    return Wrap(
      spacing: PawSpacing.sm,
      runSpacing: PawSpacing.sm,
      children: [
        ...visibleItems.map((item) {
          
          return AnimatedScale(
            key: ValueKey(item),
            duration: PawDurations.fast,
            scale: 1.0,
            child: chipBuilder != null
                ? chipBuilder!(item, () => onRemove(item))
                : PawChip(
                    label: item,
                    selected: true,
                    onDelete: () => onRemove(item),
                  ),
          );
        }),
        if (hiddenCount > 0)
          PawChip(
            label: '+$hiddenCount more',
            selected: true,
            backgroundColor: PawColors.surfaceElevated,
          ),
      ],
    );
  }
}
