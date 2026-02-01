import 'package:flutter/material.dart';
import '../../controllers/filter_controller.dart';

class LocationSection extends StatefulWidget {
  final FilterController controller;

  const LocationSection({
    super.key,
    required this.controller,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _provinceController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController();
    _cityController = TextEditingController();
    _provinceController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _updateFilters() {
    widget.controller.setLocationFilters(
      country: _countryController.text.isEmpty ? null : _countryController.text,
      city: _cityController.text.isEmpty ? null : _cityController.text,
      province: _provinceController.text.isEmpty ? null : _provinceController.text,
      latitude: _latitudeController.text.isEmpty
          ? null
          : double.tryParse(_latitudeController.text),
      longitude: _longitudeController.text.isEmpty
          ? null
          : double.tryParse(_longitudeController.text),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      onChanged: (_) => _updateFilters(),
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

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: _textField(_countryController, 'country')),
            const SizedBox(width: 8),
            Expanded(child: _textField(_cityController, 'city/town')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _textField(_provinceController, 'State/Province')),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _textField(_latitudeController, 'latitude')),
                  const SizedBox(width: 4),
                  Expanded(child: _textField(_longitudeController, 'longitude')),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DistanceSection extends StatefulWidget {
  const DistanceSection({super.key});

  @override
  State<DistanceSection> createState() => _DistanceSectionState();
}

class _DistanceSectionState extends State<DistanceSection> {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _gpsDistanceController = TextEditingController();

  @override
  void dispose() {
    _distanceController.dispose();
    _gpsDistanceController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
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
}