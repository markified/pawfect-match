import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_radius.dart';



class PawBadge extends StatelessWidget {
  final Widget child;
  final String? label;
  final int? count;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBadge;
  final BadgePosition position;
  
  const PawBadge({
    super.key,
    required this.child,
    this.label,
    this.count,
    this.backgroundColor,
    this.textColor,
    this.showBadge = true,
    this.position = BadgePosition.topRight,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!showBadge) return child;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: position.top,
          right: position.right,
          bottom: position.bottom,
          left: position.left,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: label != null || (count != null && count! > 9) ? 6 : 0,
              vertical: label != null || (count != null && count! > 9) ? 2 : 0,
            ),
            decoration: BoxDecoration(
              color: backgroundColor ?? PawColors.error,
              borderRadius: BorderRadius.circular(PawRadius.full),
              border: Border.all(color: PawColors.background, width: 2),
            ),
            constraints: BoxConstraints(
              minWidth: label != null || (count != null && count! > 9) ? 16 : 12,
              minHeight: label != null || (count != null && count! > 9) ? 16 : 12,
            ),
            child: Center(
              child: _buildBadgeContent(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBadgeContent() {
    if (label != null) {
      return Text(
        label!,
        style: PawTypography.caption.copyWith(
          color: textColor ?? Colors.white,
          fontSize: 10,
        ),
      );
    }
    
    if (count != null) {
      return Text(
        count! > 99 ? '99+' : count.toString(),
        style: PawTypography.caption.copyWith(
          color: textColor ?? Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

class BadgePosition {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  
  const BadgePosition({this.top, this.right, this.bottom, this.left});
  
  static const topRight = BadgePosition(top: -6, right: -6);
  static const topLeft = BadgePosition(top: -6, left: -6);
  static const bottomRight = BadgePosition(bottom: -6, right: -6);
  static const bottomLeft = BadgePosition(bottom: -6, left: -6);
}



class PawAvatar extends StatelessWidget {
  final String? imageUrl;
  final IconData? icon;
  final String? initials;
  final double size;
  final bool showOnlineStatus;
  final bool isOnline;
  final Color? backgroundColor;
  
  const PawAvatar({
    super.key,
    this.imageUrl,
    this.icon,
    this.initials,
    this.size = 40.0,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? PawColors.primary,
        shape: BoxShape.circle,
      ),
      child: _buildAvatarContent(),
    );
    
    if (showOnlineStatus) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: isOnline ? PawColors.success : PawColors.textSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: PawColors.background, width: 2),
              ),
            ),
          ),
        ],
      );
    }
    
    return avatar;
  }
  
  Widget _buildAvatarContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        ),
      );
    }
    
    return _buildFallback();
  }
  
  Widget _buildFallback() {
    if (icon != null) {
      return Icon(icon, size: size * 0.6, color: Colors.white);
    }
    
    if (initials != null && initials!.isNotEmpty) {
      return Center(
        child: Text(
          initials!.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    
    return Icon(Icons.person, size: size * 0.6, color: Colors.white);
  }
}
