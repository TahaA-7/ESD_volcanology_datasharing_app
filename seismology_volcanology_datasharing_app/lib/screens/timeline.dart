import 'package:flutter/material.dart';
import 'map.dart';
import '../homeshell.dart';
import '../widgets/top_tabs.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/eventlist_widget.dart';
import '../models/event_post_model.dart';
import '../utils_services/event_storage.dart';

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

  List<Event> _postedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await EventStorage.loadEvents();
    setState(() {
      _postedEvents = events;
      _isLoading = false;
    });
    print('Loaded ${events.length} events from storage');
  }

  Future<void> _refreshEvents() async {
    await _loadEvents();
  }

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

  // time filters to events
  List<Event> _getFilteredEvents() {
    if (_postedEvents.isEmpty) return [];

    DateTime? fromDate = _filterFromDate;
    DateTime? toDate = _filterToDate;

    // quick time filter if set
    if (_quickTimeFilter != null) {
      final now = DateTime.now();
      switch (_quickTimeFilter) {
        case '1h':
          fromDate = now.subtract(const Duration(hours: 1));
          toDate = now;
          break;
        case '3h':
          fromDate = now.subtract(const Duration(hours: 3));
          toDate = now;
          break;
        case '6h':
          fromDate = now.subtract(const Duration(hours: 6));
          toDate = now;
          break;
        case '12h':
          fromDate = now.subtract(const Duration(hours: 12));
          toDate = now;
          break;
        case '1d':
          fromDate = now.subtract(const Duration(days: 1));
          toDate = now;
          break;
        case '3d':
          fromDate = now.subtract(const Duration(days: 3));
          toDate = now;
          break;
        case '1w':
          fromDate = now.subtract(const Duration(days: 7));
          toDate = now;
          break;
        case '2w':
          fromDate = now.subtract(const Duration(days: 14));
          toDate = now;
          break;
      }
    }

    // If no filters, return all events
    if (fromDate == null && toDate == null) {
      return _postedEvents;
    }

    // Filter events by date range
    return _postedEvents.where((event) {
      if (event.startTime == null) return false;
      
      final eventTime = event.startTime!;
      
      if (fromDate != null && eventTime.isBefore(fromDate)) {
        return false;
      }
      
      if (toDate != null && eventTime.isAfter(toDate)) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // filtered events based on current filters
    final filteredEvents = _getFilteredEvents();

    switch (selectedTab) {
      case HomeTab.map:
        return MapScreen(events: filteredEvents);

      case HomeTab.eventList:
        return EventListWidget(events: filteredEvents);

      case HomeTab.timeline:
      default:
        return TimelineWidget(
          filterFromDate: _filterFromDate,
          filterToDate: _filterToDate,
          quickTimeFilter: _quickTimeFilter,
          events: filteredEvents,
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
      onEventPosted: _refreshEvents,
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