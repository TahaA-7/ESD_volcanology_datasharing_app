// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
// import '../utils_services/event_builder.dart';

import '../models/event_post_model.dart';
import '../controllers/event_post_wizard_controller.dart';
import '../utils_services/event_drafter_submitter.dart';
import '../utils_services/stringformatter_validator.dart';
import '../widgets/date_time_picker_field.dart';
import '../widgets/dropdowns.dart';
import '../widgets/buttons.dart';


class EventPostWizardScreen extends StatefulWidget {
  const EventPostWizardScreen({super.key});

  @override
  State<EventPostWizardScreen> createState() => _EventPostWizardScreenState();
}

class _EventPostWizardScreenState extends State<EventPostWizardScreen> {
  final List<String> _stepTitles = [
    '1 - basic details',
    '2 - extra details',
    '3 - upload',
  ];

  // void _saveDraft() {
  //   final controller = context.read<EventPostWizardController>();
  //   if (controller.canBuildEvent) {
  //     controller.saveDraft();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Draft saved!')),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill in required fields')),
  //     );
  //   }
  // }

  Future<void> _saveDraft() async {
    final controller = context.read<EventPostWizardController>();
    if (!controller.canBuildEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    try {
      final event = controller.buildEventDuration();
      // Call submission service
      await EventSubmissionService().submit(event, draft: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved successfully!')),
      );
      controller.reset();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _submitEvent() async {
    final controller = context.read<EventPostWizardController>();
    if (!controller.canBuildEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    try {
      final event = controller.buildEventDuration();
      // Call submission service
      await EventSubmissionService().submit(event);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event posted successfully!')),
      );
      controller.reset();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _nothing() {}

  void _continue() {
    final controller = context.read<EventPostWizardController>();
    if (controller.currentStep < _stepTitles.length - 1) {
      controller.nextStep();
    } else {
      _submitEvent();
    }
  }

  void _goBack() {
    final controller = context.read<EventPostWizardController>();
    if (controller.currentStep > 0) {
      controller.previousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4DC),
      body: Column(
        children: [
          // Top navigation bar
          Container(
            color: const Color(0xFFD4CFC4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // align to the right
                children: [
                  // Back button (styled)
                  InkWell(
                    onTap: _goBack,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'back <',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Draft/Post buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlineButton(
                  label: 'Draft',
                  icon: Icons.description_outlined,
                  onTap: _saveDraft,
                ),
                const SizedBox(width: 8),
                FilledButton_(
                  label: 'Post',
                  icon: Icons.add,
                  onTap: _nothing,
                ),
              ],
            ),
          ),

          // Step headers
          Container(
            color: const Color(0xFFD4CFC4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: List.generate(_stepTitles.length, (index) {
                final isActive = index == controller.currentStep;
                return Expanded(
                  child: Center(
                    child: Text(
                      _stepTitles[index],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(controller),
            ),
          ),

          // Bottom next button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: _continue,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'next >',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(EventPostWizardController controller) {
    switch (controller.currentStep) {
      case 0:
        return _BasicDetailsStep();
      case 1:
        return _ExtraDetailsStep();
      case 2:
        return _UploadStep();
      default:
        return const SizedBox();
    }
  }
}

class _BasicDetailsStep extends StatelessWidget {
  const _BasicDetailsStep();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'event type and subtype',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        EventTypeDropdown(
          value: controller.eventType,
          onChanged: (type) {
            controller.eventType = type;
            controller.eventSubtype = null;
            controller.notifyListeners();
          },
        ),

        const SizedBox(height: 8),

        EventSubtypeDropdown(
          eventType: controller.eventType,
          value: controller.eventSubtype,
          onChanged: (subtype) {
            controller.eventSubtype = subtype;
            controller.notifyListeners();
          },
        ),
      ],
    );
  }
}

class _ExtraDetailsStep extends StatefulWidget {
  const _ExtraDetailsStep();

  @override
  State<_ExtraDetailsStep> createState() => _ExtraDetailsStepState();
}

class _ExtraDetailsStepState extends State<_ExtraDetailsStep> {
  final TextEditingController _stateprovinceController = TextEditingController();
  final TextEditingController _towncityController = TextEditingController();

  final MapController _mapController = MapController();
  LatLng _selectedLocation = LatLng(0, 0);
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();

  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  final TextEditingController _microsecondsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final controller = context.read<EventPostWizardController>();
    
    _stateprovinceController.text = controller.stateprovince ?? '';
    _towncityController.text = controller.towncity ?? '';

    if (controller.latitude != null && controller.longitude != null) {
      _selectedLocation = LatLng(controller.latitude!, controller.longitude!);
    }

    _longitudeController.text = _selectedLocation.longitude.toStringAsFixed(6);
    _latitudeController.text = _selectedLocation.latitude.toStringAsFixed(6);
    
    _yearsController.text = controller.years ?? '';
    _daysController.text = controller.days ?? '';
    _hoursController.text = controller.hours ?? '';
    _minutesController.text = controller.minutes ?? '';
    _secondsController.text = controller.seconds ?? '';
    _microsecondsController.text = controller.microseconds ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeControllers();
  }

  void _updateLocationFromMap(LatLng location) {
    final controller = context.read<EventPostWizardController>();
    
    setState(() {
      _selectedLocation = location;
      _longitudeController.text = location.longitude.toStringAsFixed(6);
      _latitudeController.text = location.latitude.toStringAsFixed(6);
    });
    
    controller.longitude = location.longitude;
    controller.latitude = location.latitude;
    controller.notifyListeners();
  }

  void _updateLocationFromCoordinates() {
    final controller = context.read<EventPostWizardController>();
    final lon = double.tryParse(_longitudeController.text);
    final lat = double.tryParse(_latitudeController.text);
    
    if (lon != null && lat != null) {
      setState(() {
        _selectedLocation = LatLng(lat, lon);
        _mapController.move(_selectedLocation, _mapController.camera.zoom);
      });
      
      controller.longitude = lon;
      controller.latitude = lat;
      controller.notifyListeners();
    }
  }

  @override
  void dispose() {
    _stateprovinceController.dispose();
    _towncityController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _yearsController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _microsecondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        CountrySelectionDropdown(
          value: controller.country,
          onChanged: (Country? value) {
            controller.country = value ?? Country.unspecified;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _stateprovinceController, 
          decoration: InputDecoration(
            labelText: 'State/province (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            controller.stateprovince = value;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _towncityController,
          decoration: InputDecoration(
            labelText: 'Town/city (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            controller.towncity = value;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
        
        // Interactive coordinate fields
        TextField(
          controller: _longitudeController,
          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(
            labelText: 'Longitude (press enter)',
            filled: true,
            fillColor: const Color(0xFFE89B9B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _updateLocationFromCoordinates(),
        ),
        const SizedBox(height: 8),
        
        TextField(
          controller: _latitudeController,
          keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: InputDecoration(
            labelText: 'Latitude (press enter)',
            filled: true,
            fillColor: const Color(0xFFE89B9B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _updateLocationFromCoordinates(),
        ),
        const SizedBox(height: 16),
        
        // Interactive Map
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black87),
          ),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13.0,
              onTap: (tapPosition, point) => _updateLocationFromMap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap on the map to select a location',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        
        const SizedBox(height: 24),
        const Text(
          'timerange',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _yearsController, 
          decoration: InputDecoration(
            labelText: 'Years (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isNumeric && value.isLessThan(101)) {
              controller.years = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _daysController, 
          decoration: InputDecoration(
            labelText: 'Days (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(365)) {
              controller.days = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _hoursController, 
          decoration: InputDecoration(
            labelText: 'Hours (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(24)) {
              controller.hours = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _minutesController, 
          decoration: InputDecoration(
            labelText: 'Minutes (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(60)) {
              controller.minutes = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _secondsController, 
          decoration: InputDecoration(
            labelText: 'Seconds (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(60)) {
              controller.seconds = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _microsecondsController, 
          decoration: InputDecoration(
            labelText: 'Microseconds (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(1000000)) {
              controller.microseconds = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        DateTimePickerField(
          label: 'start time',
          value: controller.startTime,
          isError: !controller.isTimeRangeValid,
          onChanged: (dt) {
            controller.startTime = dt;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
        DateTimePickerField(
          label: 'end time',
          value: controller.endTime,
          isError: !controller.isTimeRangeValid,
          onChanged: (dt) {
            controller.endTime = dt;
            controller.notifyListeners();
          },
        ),
      ],
    );
  }
}

class _UploadStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Upload media and confirm',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
