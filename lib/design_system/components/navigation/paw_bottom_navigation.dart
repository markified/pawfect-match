import 'package:flutter/material.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_durations.dart';



class PawBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PawNavItem> items;
  final bool hideOnScroll;
  final ScrollController? scrollController;
  
  const PawBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.hideOnScroll = false,
    this.scrollController,
  });
  
  @override
  State<PawBottomNavigation> createState() => _PawBottomNavigationState();
}

class _PawBottomNavigationState extends State<PawBottomNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _hideController;
  bool _isVisible = true;
  double _lastScrollOffset = 0;
  
  @override
  void initState() {
    super.initState();
    _hideController = AnimationController(
      duration: PawDurations.short,
      vsync: this,
      value: 1.0,
    );
    
    if (widget.hideOnScroll && widget.scrollController != null) {
      widget.scrollController!.addListener(_onScroll);
    }
  }
  
  @override
  void dispose() {
    _hideController.dispose();
    if (widget.hideOnScroll && widget.scrollController != null) {
      widget.scrollController!.removeListener(_onScroll);
    }
    super.dispose();
  }
  
  void _onScroll() {
    if (widget.scrollController == null) return;
    
    final currentOffset = widget.scrollController!.offset;
    final isScrollingDown = currentOffset > _lastScrollOffset;
    final isAtTop = currentOffset <= 0;
    
    if (isAtTop) {
      _show();
    } else if (isScrollingDown && _isVisible) {
      _hide();
    } else if (!isScrollingDown && !_isVisible) {
      _show();
    }
    
    _lastScrollOffset = currentOffset;
  }
  
  void _hide() {
    setState(() => _isVisible = false);
    _hideController.reverse();
  }
  
  void _show() {
    setState(() => _isVisible = true);
    _hideController.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _hideController,
        curve: Curves.easeInOut,
      )),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                widget.items.length,
                (index) => _NavItemWidget(
                  item: widget.items[index],
                  isSelected: index == widget.currentIndex,
                  onTap: () => widget.onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final PawNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: PawDurations.short,
              curve: Curves.easeInOut,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: PawDurations.short,
              style: PawTypography.labelSmall.copyWith(
                color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}


class PawNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  
  const PawNavItem({
    required this.label,
    required this.icon,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}
