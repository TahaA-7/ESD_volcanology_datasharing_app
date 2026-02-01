import 'package:flutter/material.dart';
import 'widgets/top_tabs.dart';
import 'widgets/filter_bar.dart';
import 'utils_services/responsive_sizes.dart';

class HomeShell extends StatelessWidget {
  final HomeTab selectedTab;
  final Function(HomeTab) onTabSelected;
  final Function(DateTime?, DateTime?)? onTimeRangeChanged;
  final Function(String?)? onQuickTimeSelected;
  final Function({
    String? country,
    String? city,
    String? province,
    double? latitude,
    double? longitude,
  })? onLocationFiltersChanged;
  final Future<void> Function()? onEventPosted;
  final Widget child;

  const HomeShell({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.child,
    this.onTimeRangeChanged,
    this.onQuickTimeSelected,
    this.onLocationFiltersChanged,
    this.onEventPosted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFE5CFC7),
        child: Column(
          children: [
            TopTabs(
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
            ),
            FilterBar(
              onTimeRangeChanged: onTimeRangeChanged,
              onQuickTimeSelected: onQuickTimeSelected,
              onLocationFiltersChanged: onLocationFiltersChanged,
              onEventPosted: onEventPosted,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}