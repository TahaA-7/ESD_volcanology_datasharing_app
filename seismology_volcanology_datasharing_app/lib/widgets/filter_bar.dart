import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/event_post_landing_screen.dart';
import '../screens/event_post_wizard.dart';
import '../controllers/filter_controller.dart';
import '../models/event_post_model.dart';
import '../utils_services/responsive_sizes.dart';
import 'time_filters_section.dart' as time_filters;
import 'location_sections.dart' as location_filters;
import 'geospatial_section.dart' as geo_filters;
import 'event_type_section.dart' as event_filters;
import 'data_section.dart' as data_filters;
import 'download_widget.dart';
import 'report_generator_wizard.dart';

class FilterBar extends StatefulWidget {
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
  final Future<void> Function()? onEventPosted;

  const FilterBar({
    super.key,
    this.onTimeRangeChanged,
    this.onQuickTimeSelected,
    this.onLocationFiltersChanged,
    this.onEventTypeFiltersChanged,
    this.onEventPosted,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late FilterController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = FilterController(
      onTimeRangeChanged: widget.onTimeRangeChanged,
      onQuickTimeSelected: widget.onQuickTimeSelected,
      onLocationFiltersChanged: widget.onLocationFiltersChanged,
      onEventTypeFiltersChanged: widget.onEventTypeFiltersChanged,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveSizes.getHorizontalPadding(context);

    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Container(
              color: Colors.grey[300],
              child: Row(
                children: [
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) {
                      return ElevatedButton.icon(
                        onPressed: _controller.toggleFiltersVisibility,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _controller.showFilters
                              ? const Color(0xFF868686)
                              : null,
                          foregroundColor:
                              _controller.showFilters ? Colors.white : null,
                        ),
                        icon: const Icon(Icons.filter_alt_outlined),
                        label: const Text('Filters'),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _controller.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search events, volcanoes, locations...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ),

        ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _controller.showFilters
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: _buildFilterPanel(),
              secondChild: const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        _iconButton(Icons.info_outline, 'Tutorial', onPressed: () {}),
        _iconButton(Icons.bookmark_border, 'Bookmarks', onPressed: () {}),
        _iconButton(
          Icons.download_outlined,
          'Export',
          onPressed: () => _showDownloadDialog(context),
        ),
        _iconButton(
          Icons.star,
          'Generate report',
          onPressed: () => _showReportDialog(context),
        ),
        _iconButton(
          Icons.post_add,
          'Post',
          onPressed: () => _navigateToPostEvent(context),
        ),
      ],
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(top: BorderSide(color: Colors.grey.shade400)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: time_filters.TimeFiltersSection(controller: _controller)),
                  _verticalDivider(),
                  Expanded(flex: 2, child: time_filters.QuickTimeSection(controller: _controller)),
                  _verticalDivider(),
                  Expanded(flex: 2, child: time_filters.TimeAdjusterSection(controller: _controller)),
                  _verticalDivider(),
                  Expanded(flex: 2, child: time_filters.SpatialFiltersSection(controller: _controller)),
                ],
              ),

              const SizedBox(height: 12),
              _buildExpandButton(),

              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _controller.expandedFilters
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: _buildExpandedSection(),
                    secondChild: const SizedBox.shrink(),
                  );
                },
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _controller.resetAllFilters,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset all to default'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Center(
          child: IconButton(
            onPressed: _controller.toggleExpandedFilters,
            icon: Icon(
              _controller.expandedFilters
                  ? Icons.expand_less
                  : Icons.expand_more,
              size: 32,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Location and spatial filters
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: location_filters.LocationSection(controller: _controller)),
              _verticalDivider(),
              const Expanded(flex: 2, child: location_filters.DistanceSection()),
              _verticalDivider(),
              Expanded(flex: 2, child: geo_filters.GeospatialSection(controller: _controller)),
              _verticalDivider(),
              Expanded(flex: 3, child: event_filters.EventTypeSection(controller: _controller)),
            ],
          ),
          const SizedBox(height: 16),
          // Data aggregation
          const data_filters.DataSection(),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 100,
      color: Colors.grey.shade400,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _iconButton(
    IconData icon,
    String label, {
    required VoidCallback onPressed,
  }) {
    final padding = ResponsiveSizes.getHorizontalPadding(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding / 2),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DownloadWidget(
        events: const [],
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ReportGeneratorWizard(),
    );
  }

  Future<void> _navigateToPostEvent(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ChangeNotifierProvider(
          create: (_) => EventPostWizardController(),
          child: const EventPostLandingScreen(),
        ),
      ),
    );
    widget.onEventPosted?.call();
  }
}