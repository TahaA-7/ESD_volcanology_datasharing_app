import 'package:flutter/material.dart';
import 'map.dart';

enum HomeTab { timeline, map, eventList }

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  HomeTab selectedTab = HomeTab.timeline;
  // void _onPressed() {
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEDFD8), // beige background
      body: Column(
        children: [
          const SizedBox(height: 16),

          /// Top segmented navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabButton(
                  label: 'Timeline',
                  icon: null,
                  tab: HomeTab.timeline,
                ),
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
          ),

          const SizedBox(height: 16),

          /// Main content container
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE5CFC7),
                    width: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tab button widget
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
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
