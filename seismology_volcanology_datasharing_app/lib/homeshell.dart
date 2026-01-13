import 'package:flutter/material.dart';
import 'widgets/filter_bar.dart';
import 'widgets/top_tabs.dart';

class HomeShell extends StatelessWidget {
  final Widget child;
  final HomeTab selectedTab;
  final ValueChanged<HomeTab> onTabSelected;

  const HomeShell({
    super.key,
    required this.child,
    required this.selectedTab,
    required this.onTabSelected,
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
          const FilterBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
