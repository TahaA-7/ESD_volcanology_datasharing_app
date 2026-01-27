import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seismology_volcanology_datasharing_app/screens/event_post_landing_screen.dart';
// import '../controllers/event_post_wizard_controller.dart';
import '../screens/event_post_wizard.dart';

class FilterBar extends StatefulWidget {
  final Function(DateTime?, DateTime?)? onTimeRangeChanged;
  final Function(String)? onQuickTimeSelected;
  
  const FilterBar({
    super.key,
    this.onTimeRangeChanged,
    this.onQuickTimeSelected,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  bool _showFilters = true;
  bool _expandedFilters = false;
  String _selectedQuickTime = '1d';
  DateTime? _fromDate;
  DateTime? _toDate;
  double _timeAdjusterValue = 0.5;
  
  // Event type filters
  final Map<String, bool> _eventTypes = {
    'seismic / tectonic': true,
    'volcanic (eruptive / surface-process)': true,
    'volcanic (non-eruptive)': true,
    'mass movement / surface instability': true,
    'cryoseismic / glacial': false,
    'hydro-meteorological / fluid-related': false,
    'atmospheric / coupled signals': false,
    'anthropogenic': false,
    'geodetic / deformation': false,
    'multi-sensor': false,
    'unspecified / anomalous': false,
    'false / test': false,
    'all on/off': false,
  };
  
  // Geospatial categories
  final Map<String, bool> _geospatialCategories = {
    'continental/onshore': true,
    'aquatic/offshore': true,
  };
  
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _gpsDistanceController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _distanceController.dispose();
    _gpsDistanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TOP BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey[300],
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showFilters
                      ? const Color(0xFF868686)
                      : null,
                  foregroundColor: _showFilters ? Colors.white : null,
                ),
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Filters'),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: _searchController,
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

              _iconButton(Icons.info_outline, 'Tutorial', onPressed: () {}),
              _iconButton(Icons.bookmark_border, 'Bookmarks', onPressed: () {}),
              _iconButton(Icons.download_outlined, 'Export', onPressed: () {}),
              _iconButton(
                Icons.post_add,
                'Post',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => EventPostWizardController(),
                        // child: const EventPostWizardScreen(),
                        child: const EventPostLandingScreen(),
                      ),
            // BACKUP FOR IF FLUTTER PROVIDER PACKAGE DOESN'T WORK ANYMORE --- DO NOT REMOVE
            // _iconButton(
            //   Icons.post_add,
            //   'Post',
            //   onPressed: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         fullscreenDialog: true,
            //         builder: (_) => const EventPostWizardScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // FILTER DROPDOWN PANEL
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showFilters
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _filterPanel(),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }


  Widget _filterPanel() {
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
          // FIRST ROW - Always visible
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TIME FILTERS/SETTINGS
              Expanded(
                flex: 2,
                child: _timeFiltersSection(),
              ),

              _verticalDivider(),

              // QUICK TIME SELECTION
              Expanded(
                flex: 2,
                child: _quickTimeSection(),
              ),

              _verticalDivider(),

              // TIME ADJUSTER
              Expanded(
                flex: 2,
                child: _timeAdjusterSection(),
              ),

              _verticalDivider(),

              // SPATIAL FILTERS PREVIEW
              Expanded(
                flex: 2,
                child: _spatialFiltersPreview(),
              ),
            ],
          ),
          
          // EXPAND/COLLAPSE BUTTON
          const SizedBox(height: 12),
          Center(
            child: IconButton(
              onPressed: () {
                setState(() {
                  _expandedFilters = !_expandedFilters;
                });
              },
              icon: Icon(
                _expandedFilters ? Icons.pause : Icons.pause,
                size: 32,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // EXPANDED SECTION
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _expandedFilters
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _expandedSection(),
            secondChild: const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 12),
          
          // RESET BUTTON
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _resetFilters,
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


  Widget _expandedSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SECOND ROW - Location and Distance filters
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _locationSection(),
              ),
              
              _verticalDivider(),
              
              Expanded(
                flex: 2,
                child: _distanceSection(),
              ),
              
              _verticalDivider(),
              
              Expanded(
                flex: 2,
                child: _geospatialSection(),
              ),
              
              _verticalDivider(),
              
              Expanded(
                flex: 3,
                child: _eventTypeSection(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // THIRD ROW - Data aggregation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _dataSection(),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _timeFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Filters/Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        
        const Text('Time Range', style: TextStyle(fontSize: 11)),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: _dateField(
                label: 'From: [dd-mm-yy : hh-mm-ss...]',
                date: _fromDate,
                onTap: () => _selectDate(context, true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _dateField(
                label: 'Till: [Now (default)]',
                date: _toDate,
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh, size: 12),
          label: const Text('Reset to default', style: TextStyle(fontSize: 11)),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _quickTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'View events from last:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.skip_previous),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '1h 3h 6h 12h 1d 3d 1w 2w',
                  style: TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.skip_next),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: ['1h', '3h', '6h', '12h', '1d', '3d', '1w'].map((time) {
            final isSelected = _selectedQuickTime == time;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedQuickTime = time;
                });
                // Notify parent widget about quick time selection
                widget.onQuickTimeSelected?.call(time);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF868686) : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF868686) : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _timeAdjusterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Adjuster',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              thumbColor: Colors.blue,
            ),
            child: Slider(
              value: _timeAdjusterValue,
              onChanged: (value) {
                setState(() {
                  _timeAdjusterValue = value;
                });
              },
              activeColor: Colors.blue,
              inactiveColor: Colors.grey.shade300,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Period Shortener',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          '3h 14h 15h 16h 17h 18h 19h 20h 21h 22h 23h 1d',
          style: TextStyle(fontSize: 10, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _spatialFiltersPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spatial Filters/Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        const Text(
          'Expand to see location, distance, and region filters',
          style: TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh, size: 12),
          label: const Text('Reset to default', style: TextStyle(fontSize: 11)),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _locationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _textField(_countryController, 'country'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _textField(_cityController, 'city/town'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _textField(_latitudeController, 'latitude - latitude...'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _textField(_longitudeController, 'longitude - latitude...'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _distanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'distance from point',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        
        _textField(_distanceController, '10km within selected region'),
        const SizedBox(height: 8),
        _textField(_gpsDistanceController, '10km within my gps location'),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Checkbox(
              value: false,
              onChanged: (value) {},
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const Expanded(
              child: Text(
                'show only events from current map view',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _geospatialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'geospatial category',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        
        ..._geospatialCategories.entries.map((entry) {
          return CheckboxListTile(
            value: entry.value,
            onChanged: (value) {
              setState(() {
                _geospatialCategories[entry.key] = value ?? false;
              });
            },
            title: Text(entry.key, style: const TextStyle(fontSize: 11)),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ],
    );
  }

  Widget _eventTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Type',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _eventTypes.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        _eventTypes[entry.key] = value ?? false;
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 4),
                Text(entry.key, style: const TextStyle(fontSize: 10)),
                const SizedBox(width: 2),
                const Icon(Icons.info_outline, size: 12),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _dataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('aggregation', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Checkbox(
                        value: false,
                        onChanged: (value) {},
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Expanded(
                        child: Text(
                          'aggregate only events that are visible with current zoom',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 32),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('order by', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  _radioOption('date-time'),
                  _radioOption('duration'),
                  _radioOption('event type (seismic first, false/test last)'),
                ],
              ),
            ),
            
            const SizedBox(width: 32),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('order by', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  _radioOption('descending'),
                  _radioOption('ascending'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _radioOption(String label) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: '',
          onChanged: (value) {},
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
      style: const TextStyle(fontSize: 11),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null
                    ? '${date.day}-${date.month}-${date.year}'
                    : label,
                style: TextStyle(
                  fontSize: 11,
                  color: date != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
      
      // Notify parent widget about the change
      widget.onTimeRangeChanged?.call(_fromDate, _toDate);
    }
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 100,
      color: Colors.grey.shade400,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _iconButton(IconData icon,
    String label, {
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }


  void _resetFilters() {
    setState(() {
      _selectedQuickTime = '1d';
      _fromDate = null;
      _toDate = null;
      _timeAdjusterValue = 0.5;
      _searchController.clear();
      _countryController.clear();
      _cityController.clear();
      _latitudeController.clear();
      _longitudeController.clear();
      _distanceController.clear();
      _gpsDistanceController.clear();
      
      _eventTypes.updateAll((key, value) => key == 'seismic / tectonic' || 
                                             key == 'volcanic (eruptive / surface-process)' ||
                                             key == 'volcanic (non-eruptive)' ||
                                             key == 'mass movement / surface instability');
      _geospatialCategories.updateAll((key, value) => true);
    });
  }
}