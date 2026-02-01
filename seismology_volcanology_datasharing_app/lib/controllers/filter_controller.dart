import 'package:flutter/material.dart';
import '../models/filters_models.dart';
import '../models/event_post_model.dart';

class FilterController extends ChangeNotifier {
  FilterState _state = FilterState();
  bool _showFilters = true;
  bool _expandedFilters = false;

  final Function(DateTime?, DateTime?)? onTimeRangeChanged;
  final Function(String?)? onQuickTimeSelected;
  final Function({
    String? country,
    String? city,
    String? province,
    double? latitude,
    double? longitude,
  })? onLocationFiltersChanged;
  final Function(Set<EventType>)? onEventTypeFiltersChanged;

  FilterController({
    this.onTimeRangeChanged,
    this.onQuickTimeSelected,
    this.onLocationFiltersChanged,
    this.onEventTypeFiltersChanged,
  });

  FilterState get state => _state;
  bool get showFilters => _showFilters;
  bool get expandedFilters => _expandedFilters;

  void toggleFiltersVisibility() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void toggleExpandedFilters() {
    _expandedFilters = !_expandedFilters;
    notifyListeners();
  }

  void setFromDate(DateTime? date) {
    _state = _state.copyWith(fromDate: date);
    onTimeRangeChanged?.call(_state.fromDate, _state.toDate);
    notifyListeners();
  }

  void setToDate(DateTime? date) {
    _state = _state.copyWith(toDate: date);
    onTimeRangeChanged?.call(_state.fromDate, _state.toDate);
    notifyListeners();
  }

  void resetTimeRange() {
    _state = _state.copyWith(clearDates: true);
    onTimeRangeChanged?.call(null, null);
    notifyListeners();
  }

  void setQuickTimeFilter(String? filter) {
    _state = _state.copyWith(quickTimeFilter: filter);
    onQuickTimeSelected?.call(filter);
    notifyListeners();
  }

  void setTimeAdjuster(double value) {
    _state = _state.copyWith(timeAdjusterValue: value);
    notifyListeners();
  }

  void setLocationFilters({
    String? country,
    String? city,
    String? province,
    double? latitude,
    double? longitude,
  }) {
    _state = _state.copyWith(
      country: country,
      city: city,
      province: province,
      latitude: latitude,
      longitude: longitude,
    );
    onLocationFiltersChanged?.call(
      country: _state.country,
      city: _state.city,
      province: _state.province,
      latitude: _state.latitude,
      longitude: _state.longitude,
    );
    notifyListeners();
  }

  void resetLocationFilters() {
    _state = _state.copyWith(clearLocation: true);
    onLocationFiltersChanged?.call(
      country: null,
      city: null,
      province: null,
      latitude: null,
      longitude: null,
    );
    notifyListeners();
  }

  void setEventTypeFilter(EventType type, bool enabled) {
    final updated = Set<EventType>.from(_state.selectedEventTypes);
    if (enabled) {
      updated.add(type);
    } else {
      updated.remove(type);
    }
    _state = _state.copyWith(selectedEventTypes: updated);
    onEventTypeFiltersChanged?.call(_state.selectedEventTypes);
    notifyListeners();
  }

  void toggleAllEventTypes(bool enabled) {
    final updated = enabled ? Set<EventType>.from(EventType.values) : <EventType>{};
    _state = _state.copyWith(selectedEventTypes: updated);
    onEventTypeFiltersChanged?.call(_state.selectedEventTypes);
    notifyListeners();
  }

  void setGeospatialCategory(String category, bool enabled) {
    final updated = Map<String, bool>.from(_state.geospatialCategories);
    updated[category] = enabled;
    _state = _state.copyWith(geospatialCategories: updated);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void resetAllFilters() {
    _state = _state.reset();
    onTimeRangeChanged?.call(null, null);
    onQuickTimeSelected?.call(null);
    onLocationFiltersChanged?.call(
      country: null,
      city: null,
      province: null,
      latitude: null,
      longitude: null,
    );
    onEventTypeFiltersChanged?.call(_state.selectedEventTypes);
    notifyListeners();
  }
}