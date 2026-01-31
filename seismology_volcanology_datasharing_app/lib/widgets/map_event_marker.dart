import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/event_post_model.dart';
import 'package:intl/intl.dart';
import 'event_details_dialog.dart';

class EventMarkerData {
  final Event event;
  final LatLng position;
  final double haloSize;

  EventMarkerData({
    required this.event,
    required this.position,
    required this.haloSize,
  });
}

class MapEventMarker extends StatefulWidget {
  final EventMarkerData data;
  final VoidCallback? onTap;

  const MapEventMarker({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  State<MapEventMarker> createState() => _MapEventMarkerState();
}

class _MapEventMarkerState extends State<MapEventMarker> {
  bool _isHovered = false;

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.seismic_tectonic:
        return Colors.red;
      case EventType.volcanicEruptive_surfaceProcess:
        return Colors.orange;
      case EventType.volcanicNonEruptive:
        return Colors.deepOrange;
      case EventType.massMovement_surfaceInstability:
        return Colors.brown;
      case EventType.cryoseismic_glacial:
        return Colors.lightBlue;
      case EventType.hydrothermal_fluidDriven:
        return Colors.blue;
      case EventType.atmospheric_coupledSignals:
        return Colors.purple;
      case EventType.anthropogenic:
        return Colors.grey;
      case EventType.geodetic_deformation:
        return Colors.green;
      case EventType.multiSensor:
        return Colors.teal;
      case EventType.false_test:
        return Colors.black;
      case EventType.unspecified_anomalous:
      default:
        return Colors.yellow;
    }
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.seismic_tectonic:
        return Icons.waves;
      case EventType.volcanicEruptive_surfaceProcess:
        return Icons.terrain;
      case EventType.volcanicNonEruptive:
        return Icons.landscape;
      case EventType.massMovement_surfaceInstability:
        return Icons.landslide;
      case EventType.cryoseismic_glacial:
        return Icons.ac_unit;
      case EventType.hydrothermal_fluidDriven:
        return Icons.water_drop;
      case EventType.atmospheric_coupledSignals:
        return Icons.cloud;
      case EventType.anthropogenic:
        return Icons.factory;
      case EventType.geodetic_deformation:
        return Icons.layers;
      case EventType.multiSensor:
        return Icons.sensors;
      case EventType.false_test:
        return Icons.cancel;
      case EventType.unspecified_anomalous:
      default:
        return Icons.help_outline;
    }
  }

  void _showEventDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsDialog(event: widget.data.event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor(widget.data.event.eventType);
    final icon = _getEventIcon(widget.data.event.eventType);
    final haloSize = widget.data.haloSize;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              } else {
                _showEventDetails(context);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer halo (duration-based)
                Container(
                  width: haloSize,
                  height: haloSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                
                // Inner halo
                Container(
                  width: haloSize * 0.6,
                  height: haloSize * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                    border: Border.all(
                      color: color.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                
                // Core marker
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _isHovered ? color : color.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isHovered ? Colors.white : Colors.white.withOpacity(0.8),
                      width: _isHovered ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isHovered ? 0.5 : 0.3),
                        blurRadius: _isHovered ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          
          // Tooltip on hover
          if (_isHovered)
            Positioned(
              bottom: haloSize / 2 + 10,
              child: IgnorePointer(
                child: _buildTooltip(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTooltip() {
    final event = widget.data.event;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.eventType.name.replaceAll('_', ' '),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            if (event.source.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Source: ${event.source}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
            if (event.townCity.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Location: ${event.townCity}${event.country != Country.unspecified ? ', ${event.country.name}' : ''}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
            if (event.startTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Time: ${dateFormat.format(event.startTime!)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
            if (event.duration.inMinutes > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Duration: ${_formatDuration(event.duration)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}