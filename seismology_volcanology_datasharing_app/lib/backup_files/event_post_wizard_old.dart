// import 'dart:ffi';

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// import '../models/event_post_model.dart';

// import '../utils_services/stringformatter_validator.dart';

// import '../widgets/date_time_picker_field.dart';
// import '../widgets/dropdowns.dart';


// class EventPostWizardScreen extends StatefulWidget {
//   const EventPostWizardScreen({super.key});

//   @override
//   State<EventPostWizardScreen> createState() => _EventPostWizardScreenState();
// }

// class _EventPostWizardScreenState extends State<EventPostWizardScreen> {
//   // 1 - basic details step
//   int _currentStep = 0;
//   EventType? _eventType;
//   Enum? _eventSubtype;
//   // 2 - extra details step
//   //location
//   Country? _country;
//   String? _stateprovince; String? _towncity;
//   double? _longitude; double? _latitude;
//   //timerange
//   String? _years; String? _days; String? _hours; String? _minutes; String? _seconds; String? _microseconds;
//   DateTime? _startT; DateTime? _endT;
//   // 3 - upload step
//   Event? _preview;

//   final List<String> _stepTitles = [
//     '1 - basic details',
//     '2 - extra details',
//     '3 - upload',
//   ];

//   void _nothing() {}

//   void _continue() {
//     if (_currentStep < _stepTitles.length - 1) {
//       setState(() => _currentStep++);
//     } else {
//       // TODO: submit event
//       Navigator.of(context).pop();
//     }
//   }

//   void _goBack() {
//     if (_currentStep > 0) {
//       setState(() => _currentStep--);
//     } else {
//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFE8E4DC),
//       body: Column(
//         children: [
//           // Top navigation bar
//           Container(
//             color: const Color(0xFFD4CFC4),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: SafeArea(
//               bottom: false,
//               child: Row(
//                 children: [
//                   _NavButton(icon: Icons.view_timeline, label: 'Timeline'),
//                   const Spacer(),
//                   _NavButton(icon: Icons.map_outlined, label: 'Map'),
//                   const Spacer(),
//                   _NavButton(icon: Icons.list, label: 'Event List'),
//                   const Spacer(),
//                   // Back button (styled)
//                   InkWell(
//                     onTap: _goBack,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 8),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black, width: 2),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: const Text(
//                         'back <',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.w300,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Draft/Post buttons
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 _OutlineButton(
//                   label: 'Draft',
//                   icon: Icons.description_outlined,
//                   onTap: () {},
//                 ),
//                 const SizedBox(width: 8),
//                 _FilledButton(
//                   label: 'Post',
//                   icon: Icons.add,
//                   onTap: _nothing,
//                 ),
//               ],
//             ),
//           ),

//           // Step headers
//           Container(
//             color: const Color(0xFFD4CFC4),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: Row(
//               children: List.generate(_stepTitles.length, (index) {
//                 final isActive = index == _currentStep;
//                 return Expanded(
//                   child: Center(
//                     child: Text(
//                       _stepTitles[index],
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),

//           // Content area
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: _buildStepContent(),
//             ),
//           ),

//           // Bottom next button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Align(
//               alignment: Alignment.bottomRight,
//               child: InkWell(
//                 onTap: _continue,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 24, vertical: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.black, width: 2),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: const Text(
//                     'next >',
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.w300,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepContent() {
//     switch (_currentStep) {
//       case 0:
//         return _BasicDetailsStepEvent(
//           eventType: _eventType,
//           eventSubtype: _eventSubtype,
//           onEventTypeChanged: (type) {
//             setState(() {
//               _eventType = type;
//               _eventSubtype = null;
//             });
//           },
//           onEventSubtypeChanged: (subtype) {
//             setState(() => _eventSubtype = subtype);
//           },
//         );
//       case 1:
//         return _BasicDetailsStepLocation(
//           // location
//           country: _country,
//           onCountryChanged: (Country? value) {
//             setState(() {
//               _country = value ?? Country.unspecified;
//             });
//           },
//           longitude: _longitude,
//           latitude: _latitude,
//           onCoordinatesChanged: ((double, double) coords) {
//             setState(() {
//               _longitude = coords.$1 as double?; _latitude = coords.$2 as double?;
//             });
//           },
//           stateprovince: _stateprovince,
//           onStateprovinceChanged: (String? value) {
//             setState(() {
//               _stateprovince = value;
//             });
//           },
//           towncity: _towncity,
//           onTowncityChanged: (String? value) {
//             setState(() {
//               _towncity = value;
//             });
//           },
//           // time
//           years: _years,
//           onYearsChanged: (String? value) {
//             setState(() {
//               _years = (value != null && value.isNumeric && value.isLessThan(101)) ? value : '0';
//             });
//           },
//           days: _days,
//           onDaysChanged: (String? value) {
//             setState(() {
//               _days = value != null && value.isLessThan(365) ? value : '0';
//             });
//           },
//           hours: _hours,
//           onHoursChanged: (String? value) {
//             setState(() {
//               _hours = value != null && value.isLessThan(24) ? value : '0';
//             });
//           },
//           minutes: _minutes,
//           onMinutesChanged: (String? value) {
//             setState(() {
//               _minutes = value != null && value.isLessThan(60) ? value : '0';
//             });
//           },
//           seconds: _seconds,
//           onSecondsChanged: (String? value) {
//             setState(() {
//               _seconds = value != null && value.isLessThan(60) ? value : '0';
//             });
//           },
//           microseconds: _microseconds,
//           onMicrosecondsChanged: (String? value) {
//             setState(() {
//               _microseconds = value != null && value.isLessThan(1000000) ? value : '0';
//             });
//           },
//           startTime: _startT,
//           endTime: _endT,
//           onStartTimeChanged: (dt) {
//             setState(() => _startT = dt);
//           },
//           onEndTimeChanged: (dt) {
//             setState(() => _endT = dt);
//           },
//         );
//       case 2:
//         return _UploadStep();
//       default:
//         return const SizedBox();
//     }
//   }
// }

// class _NavButton extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const _NavButton({required this.icon, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return TextButton.icon(
//       onPressed: () {},
//       icon: Icon(icon, color: Colors.black),
//       label: Text(
//         label,
//         style: const TextStyle(color: Colors.black, fontSize: 16),
//       ),
//     );
//   }
// }

// class _OutlineButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _OutlineButton({
//     required this.label,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return OutlinedButton.icon(
//       onPressed: onTap,
//       icon: Icon(icon, color: Colors.black),
//       label: Text(label, style: const TextStyle(color: Colors.black)),
//       style: OutlinedButton.styleFrom(
//         side: const BorderSide(color: Colors.black),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
//     );
//   }
// }

// class _FilledButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _FilledButton({
//     required this.label,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: onTap,
//       icon: Icon(icon, color: Colors.white),
//       label: Text(label, style: const TextStyle(color: Colors.white)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.black,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
//     );
//   }
// }

// class _BasicDetailsStepEvent extends StatelessWidget {
//   final EventType? eventType;
//   final Enum? eventSubtype;
//   final ValueChanged<EventType?> onEventTypeChanged;
//   final ValueChanged<Enum?> onEventSubtypeChanged;

//   const _BasicDetailsStepEvent({
//     required this.eventType,
//     required this.eventSubtype,
//     required this.onEventTypeChanged,
//     required this.onEventSubtypeChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'event type and subtype',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         const SizedBox(height: 8),

//         EventTypeDropdown(
//           value: eventType,
//           onChanged: onEventTypeChanged,
//         ),

//         const SizedBox(height: 8),

//         EventSubtypeDropdown(
//           eventType: eventType,
//           value: eventSubtype,
//           onChanged: onEventSubtypeChanged,
//         ),
//       ],
//     );
//   }
// }

// class _BasicDetailsStepLocation extends StatefulWidget {
//   final Country? country;
//   final ValueChanged<Country?> onCountryChanged;
//   final double? longitude; final double? latitude;
//   final ValueChanged<(double, double)>? onCoordinatesChanged;
//   // final void Function(double lon, double lat)? onCoordinatesChanged;
//   final String? stateprovince; final String? towncity;
//   final ValueChanged<String> onStateprovinceChanged; final ValueChanged<String> onTowncityChanged;
//   //
//   final String? years; final String? days; final String? hours; final String? minutes; 
//     final String? seconds; final String? microseconds;
//   final ValueChanged<String> onYearsChanged; final ValueChanged<String> onDaysChanged;
//   final ValueChanged<String> onHoursChanged; final ValueChanged<String> onMinutesChanged;
//   final ValueChanged<String> onSecondsChanged; final ValueChanged<String> onMicrosecondsChanged;
//   //
//   final DateTime? startTime; final DateTime? endTime;
//   final ValueChanged<DateTime?> onStartTimeChanged; final ValueChanged<DateTime?> onEndTimeChanged;

//   const _BasicDetailsStepLocation({
//     Key? key,
//     required this.country,
//     required this.onCountryChanged,
//     required this.longitude, this.latitude,
//     required this.onCoordinatesChanged,
//     required this.stateprovince, required this.towncity,
//     required this.onStateprovinceChanged, required this.onTowncityChanged,
//     required this.years, required this.days, required this.hours, required this.minutes, 
//       required this.seconds, required this.microseconds,
//     required this.onYearsChanged, required this.onDaysChanged, required this.onHoursChanged,
//       required this.onMinutesChanged, required this.onSecondsChanged, required this.onMicrosecondsChanged,
//     required this.startTime, required this.endTime,
//     required this.onStartTimeChanged, required this.onEndTimeChanged,
//   }) : super(key: key);

//   @override
//   State<_BasicDetailsStepLocation> createState() => _BasicDetailsStepLocationState();
// }

// class _BasicDetailsStepLocationState extends State<_BasicDetailsStepLocation> {
//   Country? get country => widget.country;
//   ValueChanged<Country?> get onCountryChanged => widget.onCountryChanged;
//   final TextEditingController _stateprovinceController = TextEditingController();
//   final TextEditingController _towncityController = TextEditingController();

//   final MapController _mapController = MapController();
//   LatLng _selectedLocation = LatLng(0, 0);
//   final TextEditingController _longitudeController = TextEditingController();
//   final TextEditingController _latitudeController = TextEditingController();

//   final TextEditingController _yearsController = TextEditingController();
//   final TextEditingController _daysController = TextEditingController();
//   final TextEditingController _hoursController = TextEditingController();
//   final TextEditingController _minutesController = TextEditingController();
//   final TextEditingController _secondsController = TextEditingController();
//   final TextEditingController _microsecondsController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _stateprovinceController.text = widget.stateprovince ?? '';
//     _towncityController.text = widget.towncity ?? '';

//     if (widget.latitude != null && widget.longitude != null) {
//       _selectedLocation = LatLng(widget.latitude!, widget.longitude!);
//     }

//     _longitudeController.text =
//         _selectedLocation.longitude.toStringAsFixed(6);
//     _latitudeController.text =
//         _selectedLocation.latitude.toStringAsFixed(6);
    
//     _yearsController.text = widget.years ?? '';
//   }

//   // to keep in sync upon rebuild
//   @override
//   void didUpdateWidget(covariant _BasicDetailsStepLocation oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (widget.stateprovince != oldWidget.stateprovince) {
//       _stateprovinceController.text = widget.stateprovince ?? '';
//     }
//     if (widget.towncity != oldWidget.towncity) {
//       _towncityController.text = widget.towncity ?? '';
//     }

//     if (widget.latitude != oldWidget.latitude ||
//         widget.longitude != oldWidget.longitude) {
//       if (widget.latitude != null && widget.longitude != null) {
//         final newLocation = LatLng(widget.latitude!, widget.longitude!);

//         setState(() {
//           _selectedLocation = newLocation;
//           _longitudeController.text =
//               newLocation.longitude.toStringAsFixed(6);
//           _latitudeController.text =
//               newLocation.latitude.toStringAsFixed(6);
//         });

//         _mapController.move(newLocation, _mapController.camera.zoom);
//       }
//     }

//     if (widget.years != oldWidget.years && widget.years!.length < 3) {
//       if (widget.years?.isNumeric ?? false) {
//         _yearsController.text = widget.years ?? '0';
//       }
//     }
//   }

//   void _updateLocationFromMap(LatLng location) {
//     setState(() {
//       _selectedLocation = location;
//       _longitudeController.text = location.longitude.toStringAsFixed(6);
//       _latitudeController.text = location.latitude.toStringAsFixed(6);
//     });
//     widget.onCoordinatesChanged?.call((location.longitude, location.latitude));
//   }

//   void _updateLocationFromCoordinates() {
//     final lon = double.tryParse(_longitudeController.text);
//     final lat = double.tryParse(_latitudeController.text);
    
//     if (lon != null && lat != null) {
//       setState(() {
//         _selectedLocation = LatLng(lat, lon);
//         _mapController.move(_selectedLocation, _mapController.camera.zoom);
//       });
//       widget.onCoordinatesChanged?.call((lon, lat));
//     }
//   }

//   @override
//   void dispose() {
//     _longitudeController.dispose();
//     _latitudeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'location',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         CountrySelectionDropdown(
//           value: country,
//           onChanged: onCountryChanged),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _stateprovinceController, 
//           decoration: InputDecoration(
//             labelText: 'State/province (press enter)',
//             filled: true,
//             // isError: false,
//             fillColor: Color(0xFF8C8B9E),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: widget.onStateprovinceChanged),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _towncityController,
//           decoration: InputDecoration(
//             labelText: 'Town/city (press enter)',
//             filled: true,
//             // isError: false,
//             fillColor: Color(0xFF8C8B9E),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: widget.onTowncityChanged),
//         const SizedBox(height: 8),
        
//         // Interactive coordinate fields
//         TextField(
//           controller: _longitudeController,
//           keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
//           decoration: InputDecoration(
//             labelText: 'Longitude (press enter)',
//             filled: true,
//             fillColor: const Color(0xFFE89B9B),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: (_) => _updateLocationFromCoordinates(),
//         ),
//         const SizedBox(height: 8),
        
//         TextField(
//           controller: _latitudeController,
//           keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
//           decoration: InputDecoration(
//             labelText: 'Latitude (press enter)',
//             filled: true,
//             fillColor: const Color(0xFFE89B9B),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: (_) => _updateLocationFromCoordinates(),
//         ),
//         const SizedBox(height: 16),
        
//         // Interactive Map
//         Container(
//           height: 300,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black87),
//           ),
//           child: FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _selectedLocation,
//               initialZoom: 13.0,
//               onTap: (tapPosition, point) => _updateLocationFromMap(point),
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.example.app',
//               ),
//               MarkerLayer(
//                 markers: [
//                   Marker(
//                     point: _selectedLocation,
//                     width: 40,
//                     height: 40,
//                     child: const Icon(
//                       Icons.location_pin,
//                       color: Colors.red,
//                       size: 40,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Tap on the map to select a location',
//           style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//         ),
        
//         const SizedBox(height: 24),
//         const Text(
//           'timerange',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _yearsController, 
//           decoration: InputDecoration(
//             labelText: 'Years (press enter)',
//             filled: true,
//             // isError: false,
//             fillColor: Color(0xFF8C8B9E),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: widget.onYearsChanged),
//         const SizedBox(height: 8),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _daysController, 
//           decoration: InputDecoration(
//             labelText: 'Days (press enter)',
//             filled: true,
//             // isError: false,
//             fillColor: Color(0xFF8C8B9E),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: widget.onDaysChanged),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _hoursController, 
//           decoration: InputDecoration(
//             labelText: 'Hours (press enter)',
//             filled: true,
//             // isError: false,
//             fillColor: Color(0xFF8C8B9E),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: widget.onHoursChanged),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _minutesController, 
//           decoration: InputDecoration(
//             labelText: 'Minutes (press enter)',
//             filled: true,
//             // isError: false,
//             fillColor: Color(0xFF8C8B9E),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: widget.onMinutesChanged),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _secondsController, 
//           decoration: InputDecoration(
//             labelText: 'Seconds (press enter)',
//             filled: true,
//             // isError: false,
//             fillColor: Color(0xFF8C8B9E),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: widget.onSecondsChanged),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _microsecondsController, 
//           decoration: InputDecoration(
//             labelText: 'Microseconds (press enter)',
//             filled: true,
//             // isError: false,
//             fillColor: Color(0xFF8C8B9E),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           onSubmitted: widget.onMicrosecondsChanged),
//         const SizedBox(height: 8),
//         DateTimePickerField(
//           label: 'start time',
//           value: widget.startTime,
//           isError: widget.endTime != null &&
//                   widget.startTime != null &&
//                   widget.startTime!.isAfter(widget.endTime!),
//           onChanged: widget.onStartTimeChanged,
//         ),
//         const SizedBox(height: 8),
//         DateTimePickerField(
//           label: 'end time',
//           value: widget.endTime,
//           isError: widget.startTime != null &&
//                   widget.endTime != null &&
//                   widget.endTime!.isBefore(widget.startTime!),
//           onChanged: widget.onEndTimeChanged,
//         ),
//       ],
//     );
//   }
// }

// class _UploadStep extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text(
//         'Upload media and confirm',
//         style: TextStyle(fontSize: 18),
//       ),
//     );
//   }
// }

// class _TextField extends StatelessWidget {
//   final String label;
//   final bool isError;
//   final ValueChanged<String>? onChanged;

//   const _TextField({required this.label, this.isError = false, this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       decoration: InputDecoration(
//         labelText: label,
//         filled: true,
//         fillColor: isError ? const Color(0xFFE89B9B) : const Color(0xFF8C8B9E),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide.none,
//         ),
//         labelStyle: const TextStyle(color: Colors.white70),
//       ),
//       style: const TextStyle(color: Colors.white),
//       onChanged: onChanged,
//     );
//   }
// }
