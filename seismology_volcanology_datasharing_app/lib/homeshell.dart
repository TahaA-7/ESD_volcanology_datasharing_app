import 'package:flutter/material.dart';
import 'widgets/filter_bar.dart';
import 'widgets/top_tabs.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDFD8),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const TopTabs(),
          const FilterBar(), // 👈 shared across all pages
          Expanded(child: child),
        ],
      ),
    );
  }
}
