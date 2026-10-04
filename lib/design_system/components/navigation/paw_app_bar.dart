import 'package:flutter/material.dart';
import '../../tokens/paw_typography.dart';
import '../../tokens/paw_elevation.dart';



class PawAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  
  const PawAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation = PawElevation.appBar,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      titleTextStyle: PawTypography.h2,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      centerTitle: centerTitle,
      iconTheme: IconThemeData(
        color: foregroundColor ?? theme.colorScheme.onSurface,
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


class PawSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool floating;
  final bool pinned;
  final bool snap;
  final double expandedHeight;
  final Widget? flexibleSpace;
  
  const PawSliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.floating = true,
    this.pinned = false,
    this.snap = true,
    this.expandedHeight = kToolbarHeight,
    this.flexibleSpace,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      titleTextStyle: PawTypography.h2,
      actions: actions,
      leading: leading,
      floating: floating,
      pinned: pinned,
      snap: snap,
      expandedHeight: expandedHeight,
      backgroundColor: theme.scaffoldBackgroundColor,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: PawElevation.appBar,
      flexibleSpace: flexibleSpace,
      iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
    );
  }
}
