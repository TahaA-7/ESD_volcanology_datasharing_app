part of '../screens/event_post_wizard.dart';

class EventPreviewCard extends StatelessWidget {
  final Event event;
  
  const EventPreviewCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black26),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with event type
            Row(
              children: [
                Icon(
                  _getEventIcon(event.eventType),
                  size: 28,
                  color: Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatEventType(event.eventType),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event is EventVolcanicEruptive || event is EventVolcanicNonEruptive)
                        Text(
                          _formatSubtype(event),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Location section
            _buildSection(
              'Location',
              Icons.location_on_outlined,
              [
                if (event.townCity.isNotEmpty) event.townCity,
                if (event.stateProvince.isNotEmpty) event.stateProvince,
                if (event.country != Country.unspecified) event.country.name,
                if (event.latitude != null && event.longitude != null)
                  '${event.latitude!.toStringAsFixed(4)}, ${event.longitude!.toStringAsFixed(4)}',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Time section
            _buildSection(
              'Time',
              Icons.access_time,
              [
                if (event.startTime != null)
                  'Start: ${_formatDateTime(event.startTime!)}',
                if (event.timeRange != null)
                  'End: ${_formatDateTime(event.timeRange!.end)}',
                if (event.duration.inSeconds > 0)
                  'Duration: ${_formatDuration(event.duration)}',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Event-specific details
            _buildEventSpecificDetails(event),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items) {
    final nonEmptyItems = items.where((item) => item.isNotEmpty).toList();
    if (nonEmptyItems.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...nonEmptyItems.map((item) => Padding(
          padding: const EdgeInsets.only(left: 26, top: 2),
          child: Text(
            item,
            style: const TextStyle(fontSize: 14),
          ),
        )),
      ],
    );
  }

  Widget _buildEventSpecificDetails(Event event) {
    final details = <String>[];
    
    switch (event) {
      case EventSeismic e:
        if (e.magnitude != null) details.add('Magnitude: ${e.magnitude}');
        if (e.depth != null) details.add('Depth: ${e.depth} km');
        break;
      case EventVolcanicEruptive e:
        if (e.volcanoName != null) details.add('Volcano: ${e.volcanoName}');
        if (e.plumeHeightMeters != null) details.add('Plume: ${e.plumeHeightMeters} m');
        if (e.vei != null) details.add('VEI: ${e.vei}');
        break;
      case EventVolcanicNonEruptive e:
        if (e.volcanoName != null) details.add('Volcano: ${e.volcanoName}');
        if (e.groundDeformationMm != null) details.add('Deformation: ${e.groundDeformationMm} mm');
        break;
      case EventMassMovement e:
        if (e.volumeM3 != null) details.add('Volume: ${e.volumeM3} m³');
        if (e.velocityMetersPerSecond != null) details.add('Velocity: ${e.velocityMetersPerSecond} m/s');
        break;
      case EventAnthropogenic e:
        if (e.activityType != null) details.add('Activity: ${e.activityType}');
        if (e.explosiveYieldKg != null) details.add('Yield: ${e.explosiveYieldKg} kg');
        break;
      case EventAtmospheric e:
        if (e.phenomenon != null) details.add('Phenomenon: ${e.phenomenon}');
        break;
      case EventCryoseismic e:
        if (e.iceThicknessMeters != null) details.add('Ice Thickness: ${e.iceThicknessMeters} m');
        if (e.airTemperatureCelsius != null) details.add('Temperature: ${e.airTemperatureCelsius}°C');
        break;
      case EventGeodetic e:
        if (e.displacementNorthMm != null) details.add('North: ${e.displacementNorthMm} mm');
        if (e.displacementEastMm != null) details.add('East: ${e.displacementEastMm} mm');
        break;
      case EventHydrothermal e:
        if (e.featureType != null) details.add('Feature: ${e.featureType}');
        if (e.waterTemperatureCelsius != null) details.add('Temp: ${e.waterTemperatureCelsius}°C');
        break;
      default:
        break;
    }
    
    if (details.isEmpty) return const SizedBox.shrink();
    
    return _buildSection(
      'Event Details',
      Icons.info_outline,
      details,
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.seismic_tectonic:
        return Icons.waves;
      case EventType.volcanicEruptive_surfaceProcess:
      case EventType.volcanicNonEruptive:
        return Icons.terrain;
      case EventType.massMovement_surfaceInstability:
        return Icons.landslide;
      case EventType.anthropogenic:
        return Icons.construction;
      case EventType.atmospheric_coupledSignals:
        return Icons.cloud;
      case EventType.cryoseismic_glacial:
        return Icons.ac_unit;
      case EventType.geodetic_deformation:
        return Icons.straighten;
      case EventType.hydrothermal_fluidDriven:
        return Icons.water_drop;
      default:
        return Icons.event;
    }
  }

  String _formatEventType(EventType type) {
    return type.name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatSubtype(Event event) {
    if (event is EventVolcanicEruptive) {
      return event.eventSubtype.name;
    } else if (event is EventVolcanicNonEruptive) {
      return event.eventSubtype.name;
    }
    return '';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');
    
    return parts.join(' ');
  }
}
