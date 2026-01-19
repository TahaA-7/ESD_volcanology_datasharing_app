import 'package:flutter/material.dart';
import 'map.dart';
import '../homeshell.dart';
import '../widgets/top_tabs.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/eventlist_widget.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeTab selectedTab = HomeTab.timeline;
  
  // Filter state
  DateTime? _filterFromDate;
  DateTime? _filterToDate;
  String? _quickTimeFilter;

  void _handleTimeRangeChanged(DateTime? fromDate, DateTime? toDate) {
    setState(() {
      _filterFromDate = fromDate;
      _filterToDate = toDate;
      _quickTimeFilter = null;
    });
  }

  void _handleQuickTimeSelected(String quickTime) {
    setState(() {
      _quickTimeFilter = quickTime;
      _filterFromDate = null;
      _filterToDate = null;
    });
  }

  Widget _buildContent() {
    switch (selectedTab) {
      case HomeTab.map:
        return const MapScreen();

      case HomeTab.eventList:
        return const EventListWidget(); // Add this

      case HomeTab.timeline:
      default:
        return TimelineWidget(
          filterFromDate: _filterFromDate,
          filterToDate: _filterToDate,
          quickTimeFilter: _quickTimeFilter,
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
      onTimeRangeChanged: _handleTimeRangeChanged,
      onQuickTimeSelected: _handleQuickTimeSelected,
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