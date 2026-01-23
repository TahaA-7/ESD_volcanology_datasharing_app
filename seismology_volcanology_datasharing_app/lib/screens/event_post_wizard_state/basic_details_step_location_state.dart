part of '../event_post_wizard.dart';

class _BasicDetailsStepLocationState extends State<_BasicDetailsStepLocation> {
  final TextEditingController _stateprovinceController = TextEditingController();
  final TextEditingController _towncityController = TextEditingController();

  final MapController _mapController = MapController();
  LatLng _selectedLocation = LatLng(0, 0);
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();


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
      ],
    );
  }
}
