import 'package:flutter/material.dart';
import '../../controllers/filter_controller.dart';
import '../../models/event_post_model.dart';

class EventTypeSection extends StatelessWidget {
  final FilterController controller;

  const EventTypeSection({
    super.key,
    required this.controller,
  });

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.seismic_tectonic:
        return 'seismic / tectonic';
      case EventType.volcanicEruptive_surfaceProcess:
        return 'volcanic (eruptive / surface-process)';
      case EventType.volcanicNonEruptive:
        return 'volcanic (non-eruptive)';
      case EventType.massMovement_surfaceInstability:
        return 'mass movement / surface instability';
      case EventType.cryoseismic_glacial:
        return 'cryoseismic / glacial';
      case EventType.hydrothermal_fluidDriven:
        return 'hydrothermal / fluid-driven';
      case EventType.atmospheric_coupledSignals:
        return 'atmospheric / coupled signals';
      case EventType.anthropogenic:
        return 'anthropogenic';
      case EventType.geodetic_deformation:
        return 'geodetic / deformation';
      case EventType.multiSensor:
        return 'multi-sensor';
      case EventType.unspecified_anomalous:
        return 'unspecified / anomalous';
      case EventType.false_test:
        return 'false / test';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final allSelected = controller.state.selectedEventTypes.length == 
                           EventType.values.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: allSelected,
                    tristate: true,
                    onChanged: (value) {
                      controller.toggleAllEventTypes(value ?? true);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'all on/off',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EventType.values.map((type) {
                final isSelected = controller.state.selectedEventTypes.contains(type);
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          controller.setEventTypeFilter(type, value ?? false);
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getEventTypeLabel(type),
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.info_outline, size: 12),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}