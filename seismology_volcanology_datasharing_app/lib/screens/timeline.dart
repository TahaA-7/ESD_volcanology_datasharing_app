import 'package:flutter/material.dart';
import 'map.dart';
import '../homeshell.dart';
import '../widgets/top_tabs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeTab selectedTab = HomeTab.timeline;

  Widget _buildContent() {
    switch (selectedTab) {
      case HomeTab.map:
        return const MapScreen();

      case HomeTab.eventList:
        return const Center(
          child: Text(
            'Event List content',
            style: TextStyle(fontSize: 18),
          ),
        );

      case HomeTab.timeline:
      default:
        return const Center(
          child: Text(
            'Timeline content',
            style: TextStyle(fontSize: 18),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeShell(
      selectedTab: selectedTab,
      onTabSelected: (tab) {
        setState(() {
          selectedTab = tab;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Color(0xFFE5CFC7),
            width: 4,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }
}
