import 'package:flutter/material.dart';
import '../../tokens/paw_colors.dart';
import '../../tokens/paw_typography.dart';

class PawTabs extends StatelessWidget {
  final List<String> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  
  const PawTabs({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      onTap: onTap,
      isScrollable: isScrollable,
      labelColor: PawColors.primary,
      unselectedLabelColor: PawColors.textSecondary,
      labelStyle: PawTypography.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: PawTypography.labelMedium,
      indicatorColor: PawColors.primary,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: tabs.map((tab) => Tab(text: tab)).toList(),
    );
  }
}


class PawTabView extends StatelessWidget {
  final List<Widget> children;
  final TabController? controller;
  
  const PawTabView({
    super.key,
    required this.children,
    this.controller,
  });
  
  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      children: children,
    );
  }
}


class PawTabbedView extends StatefulWidget {
  final List<TabItem> tabs;
  final int initialIndex;
  
  const PawTabbedView({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
  });
  
  @override
  State<PawTabbedView> createState() => _PawTabbedViewState();
}

class _PawTabbedViewState extends State<PawTabbedView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PawTabs(
          tabs: widget.tabs.map((t) => t.label).toList(),
          controller: _controller,
          isScrollable: widget.tabs.length > 4,
        ),
        Expanded(
          child: PawTabView(
            controller: _controller,
            children: widget.tabs.map((t) => t.content).toList(),
          ),
        ),
      ],
    );
  }
}


class TabItem {
  final String label;
  final Widget content;
  
  const TabItem({
    required this.label,
    required this.content,
  });
}
