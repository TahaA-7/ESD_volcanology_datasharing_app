import 'package:flutter/material.dart';
import 'widgets/filter_bar.dart';
import 'widgets/top_tabs.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  final HomeTab selectedTab;
  final ValueChanged<HomeTab> onTabSelected;
  final Function(DateTime?, DateTime?)? onTimeRangeChanged;
  final Function(String)? onQuickTimeSelected;

  const HomeShell({
    super.key,
    required this.child,
    required this.selectedTab,
    required this.onTabSelected,
    this.onTimeRangeChanged,
    this.onQuickTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDFD8),
      body: Column(
        children: [
          const SizedBox(height: 16),
          TopTabs(
            selectedTab: selectedTab,
            onTabSelected: onTabSelected,
          ),
          FilterBar(
            onTimeRangeChanged: onTimeRangeChanged,
            onQuickTimeSelected: onQuickTimeSelected,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}