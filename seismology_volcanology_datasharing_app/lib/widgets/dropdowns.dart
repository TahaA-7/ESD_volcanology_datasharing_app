import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/event_post_wizard.dart';
import '../models/event_post_model.dart';
// import '../utils_services/event_builder.dart';
import '../utils_services/stringformatter_validator.dart';

class _DropdownField extends StatelessWidget {
  final String label;

  const _DropdownField({required this.label});

  // @override State<_DropdownField> createState() => _DropdownFieldState();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF8C8B9E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
    );
  }
}


class EventTypeDropdown extends StatelessWidget {
  final EventType? value;
  final ValueChanged<EventType?> onChanged;

  const EventTypeDropdown({
    required this.value,
    required this.onChanged,
  });

  static const eventTypesNames = [
    'unspecified / anomalous',
    'seismic / tectonic',
    'volcanic eruptive / surface process',
    'volcanic non-eruptive',
    'mass movement / surface instability',
    'cryoseismic / glacial',
    'hydothermal / fluid-driven',
    'atmospheric / coupled signals',
    'anthropogenic',
    'geodetic / deformation',
    'multisensor',
    'false / test',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EventType>(
      initialValue: value,
      hint: const Text('Event type', style: TextStyle(color: Colors.white)),
      decoration: _dropdownDecoration(),
      dropdownColor: const Color(0xFF8C8B9E),
      iconEnabledColor: Colors.white,
      items: EventType.values.asMap().entries.map((entry) {
        return DropdownMenuItem(
          value: entry.value,
          child: Text(
            eventTypesNames[entry.key],
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class EventSubtypeDropdown extends StatelessWidget {
  final EventType? eventType;
  final Enum? value;
  final ValueChanged<Enum?> onChanged;

  const EventSubtypeDropdown({
    required this.eventType,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<EventPostWizardController>();
    final subtypes = controller.getAvailableSubtypes();
    // final subtypes = eventType != null
    //     ? List<Enum>.from(getAvailableSubtypes(eventType!))
    //     : <Enum>[];

    return DropdownButtonFormField<Enum>(
      initialValue: value,
      hint: const Text('Event subtype', style: TextStyle(color: Colors.white)),
      decoration: _dropdownDecoration(),
      dropdownColor: const Color(0xFF8C8B9E),
      iconEnabledColor: Colors.white,
      items: subtypes.map((subtype) {
        return DropdownMenuItem<Enum>(
          value: subtype,
          child: Text(
            subtype.name,
            style: const TextStyle(color: Colors.white),
          ),
        );
      }).toList(),
      onChanged: eventType == null ? null : onChanged,
    );
  }
}

class CountrySelectionDropdown extends StatelessWidget {
  final Country? value;
  final ValueChanged<Country?> onChanged;

  const CountrySelectionDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Country> (
      initialValue: value,
      hint: const Text('Country', style: TextStyle(color: Colors.white)),
      decoration: _dropdownDecoration(),
      dropdownColor: const Color(0xFF8C8B9E),
      iconEnabledColor: Colors.white,
      items: Country.values.asMap().entries.map((entry) {
        return DropdownMenuItem(
          value: entry.value,
          child: Text (
            entry.value.name.toString().title(),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class EventPostStatusSelectionDropdown extends StatelessWidget {
  final EventPostStatus? value;
  final ValueChanged<EventPostStatus?> onChanged;

  const EventPostStatusSelectionDropdown ({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EventPostStatus> (
      initialValue: value,
      hint: const Text('Event Post Status', style: TextStyle(color: Colors.white)),
      decoration: _dropdownDecoration(),
      dropdownColor: const Color(0xFF8C8B9E),
      iconEnabledColor: Colors.white,
      items: EventPostStatus.values.asMap().entries.map((entry) {
        return DropdownMenuItem(
          value: entry.value,
          child: Text (
            entry.value.name.toString().title(),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

InputDecoration _dropdownDecoration() => InputDecoration(
  filled: true,
  fillColor: const Color(0xFF8C8B9E),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
);
