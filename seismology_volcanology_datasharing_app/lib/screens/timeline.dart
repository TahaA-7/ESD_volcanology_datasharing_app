import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'map.dart';
import '../homeshell.dart';
import '../widgets/top_tabs.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/eventlist_widget.dart';
import '../models/event_post_model.dart';
import '../utils_services/event_storage.dart';
import '../utils_services/geocoding_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeTab selectedTab = HomeTab.timeline;

  // Time filter state
  DateTime? _filterFromDate;
  DateTime? _filterToDate;
  String? _quickTimeFilter;

  // Location filter state
  String? _countryFilter;
  String? _cityFilter;
  String? _provinceFilter;
  double? _latitudeFilter;
  double? _longitudeFilter;

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

  void _handleQuickTimeSelected(String? quickTime) {
    setState(() {
      _quickTimeFilter = quickTime;
      if (quickTime == null) {
        _filterFromDate = null;
        _filterToDate = null;
      } else {
        _filterFromDate = null;
        _filterToDate = null;
      }
    });
  }

  void _handleLocationFiltersChanged({
    String? country,
    String? city,
    String? province,
    double? latitude,
    double? longitude,
  }) {
    setState(() {
      _countryFilter = country;
      _cityFilter = city;
      _provinceFilter = province;
      _latitudeFilter = latitude;
      _longitudeFilter = longitude;
    });
  }

  // Apply all filters to events
  List<Event> _getFilteredEvents() {
    if (_postedEvents.isEmpty) return [];

    List<Event> filtered = List.from(_postedEvents);

    //tijd filters
    DateTime? fromDate = _filterFromDate;
    DateTime? toDate = _filterToDate;

    if (_quickTimeFilter != null && _quickTimeFilter!.isNotEmpty) {
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

    if (fromDate != null || toDate != null) {
      filtered = filtered.where((event) {
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

    // Apply location filters
    if (_countryFilter != null || _cityFilter != null || _provinceFilter != null) {
      filtered = filtered.where((event) {
        return GeocodingHelper.eventMatchesLocation(
          event,
          countryFilter: _countryFilter,
          cityFilter: _cityFilter,
          provinceFilter: _provinceFilter,
        );
      }).toList();
    }

    // coordinates filters
    if (_latitudeFilter != null && _longitudeFilter != null) {
      final centerPoint = LatLng(_latitudeFilter!, _longitudeFilter!);
      filtered = filtered.where((event) {
        return GeocodingHelper.eventWithinDistance(event, centerPoint, 50);
      }).toList();
    }

    return filtered;
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
      onLocationFiltersChanged: _handleLocationFiltersChanged,
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