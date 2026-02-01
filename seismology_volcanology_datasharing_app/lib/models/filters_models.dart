import 'package:flutter/material.dart';
import 'event_post_model.dart';

class FilterState {
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? quickTimeFilter;
  final String? country;
  final String? city;
  final String? province;
  final double? latitude;
  final double? longitude;
  final Set<EventType> selectedEventTypes;
  final Map<String, bool> geospatialCategories;
  final double timeAdjusterValue;
  final String searchQuery;

  FilterState({
    this.fromDate,
    this.toDate,
    this.quickTimeFilter,
    this.country,
    this.city,
    this.province,
    this.latitude,
    this.longitude,
    Set<EventType>? selectedEventTypes,
    Map<String, bool>? geospatialCategories,
    this.timeAdjusterValue = 0.5,
    this.searchQuery = '',
  })  : selectedEventTypes = selectedEventTypes ?? Set.from(EventType.values),
        geospatialCategories = geospatialCategories ?? {
          'continental/onshore': true,
          'aquatic/offshore': true,
        };

  FilterState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    String? quickTimeFilter,
    String? country,
    String? city,
    String? province,
    double? latitude,
    double? longitude,
    Set<EventType>? selectedEventTypes,
    Map<String, bool>? geospatialCategories,
    double? timeAdjusterValue,
    String? searchQuery,
    bool clearDates = false,
    bool clearLocation = false,
  }) {
    return FilterState(
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
      quickTimeFilter: quickTimeFilter ?? this.quickTimeFilter,
      country: clearLocation ? null : (country ?? this.country),
      city: clearLocation ? null : (city ?? this.city),
      province: clearLocation ? null : (province ?? this.province),
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      selectedEventTypes: selectedEventTypes ?? this.selectedEventTypes,
      geospatialCategories: geospatialCategories ?? this.geospatialCategories,
      timeAdjusterValue: timeAdjusterValue ?? this.timeAdjusterValue,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  FilterState reset() {
    return FilterState(
      selectedEventTypes: Set.from(EventType.values),
      geospatialCategories: {
        'continental/onshore': true,
        'aquatic/offshore': true,
      },
    );
  }

  bool get hasActiveFilters {
    return fromDate != null ||
        toDate != null ||
        quickTimeFilter != null ||
        country != null ||
        city != null ||
        province != null ||
        latitude != null ||
        longitude != null ||
        selectedEventTypes.length < EventType.values.length ||
        searchQuery.isNotEmpty;
  }
}

class QuickTimeOptions {
  static const List<String> options = [
    '1h', '3h', '6h', '12h',
    '1d', '3d', '1w', '2w'
  ];

  static Duration? getDuration(String option) {
    switch (option) {
      case '1h': return const Duration(hours: 1);
      case '3h': return const Duration(hours: 3);
      case '6h': return const Duration(hours: 6);
      case '12h': return const Duration(hours: 12);
      case '1d': return const Duration(days: 1);
      case '3d': return const Duration(days: 3);
      case '1w': return const Duration(days: 7);
      case '2w': return const Duration(days: 14);
      default: return null;
    }
  }
}