import 'package:flutter/material.dart';

enum HomeTab { timeline, map, eventList }

class TopTabs extends StatefulWidget {
  const TopTabs({super.key});

  @override
  State<TopTabs> createState() => _TopTabsState();
}

class _TopTabsState extends State<TopTabs> {
  HomeTab selectedTab = HomeTab.timeline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tabButton(label: 'Timeline', tab: HomeTab.timeline),
          _tabButton(
            label: 'Map',
            icon: Icons.map_outlined,
            tab: HomeTab.map,
          ),
          _tabButton(
            label: 'Event List',
            icon: Icons.list,
            tab: HomeTab.eventList,
          ),
        ],
      ),
    );
  }

  /// Tab button widget (your code, unchanged)
  Widget _tabButton({
    required String label,
    IconData? icon,
    required HomeTab tab,
  }) {
    final bool isSelected = selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = tab;
          });

          // later: navigation logic goes here
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isSelected ? Colors.grey[700] : Colors.grey[300],
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.black),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
