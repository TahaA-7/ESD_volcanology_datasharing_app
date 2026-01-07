import 'package:flutter/material.dart';
import 'map.dart';
import '../homeshell.dart';
import '../widgets/filter_bar.dart';
import '../widgets/top_tabs.dart';

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
    return HomeShell(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE5CFC7),
            width: 4,
          ),
        ),
        child: const Center(
          child: Text(
            'Timeline content',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
