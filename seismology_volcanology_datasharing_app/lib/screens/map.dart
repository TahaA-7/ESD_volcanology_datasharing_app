import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../widgets/legend.dart';
import '../models/event_post_model.dart';
import '../utils_services/event_storage.dart';

/// Map layers enum
enum MapLayer {
  standard,
  satellite,
  terrain,
}

/// Extension to provide URL templates and labels
extension MapLayerExtension on MapLayer {
  String get label {
    switch (this) {
      case MapLayer.satellite:
        return 'Satellite';
      case MapLayer.terrain:
        return 'Terrain';
      case MapLayer.standard:
      default:
        return 'Standard';
    }
  }

  String get urlTemplate {
    switch (this) {
      case MapLayer.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/'
            'World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapLayer.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapLayer.standard:
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }
}

/// Selection model
class SelectionBounds {
  final LatLng northEast;
  final LatLng southWest;

  SelectionBounds(this.northEast, this.southWest);

  bool contains(LatLng point) {
    return point.latitude <= northEast.latitude &&
        point.latitude >= southWest.latitude &&
        point.longitude <= northEast.longitude &&
        point.longitude >= southWest.longitude;
  }
}

/// Main map screen with selection
class MapScreen extends StatefulWidget {
  final List<Event>? events;
  const MapScreen({super.key, this.events});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 2.0;
  MapLayer _selectedLayer = MapLayer.standard;

  // Events
  List<Event> _events = [];
  bool _isLoading = true;

  // Selection state
  bool _selectionMode = false;
  Offset? _selectionStart;
  Offset? _selectionEnd;
  SelectionBounds? _selectedBounds;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update events when user passes new filtered events
    if (widget.events != null) {
      setState(() {
        _events = widget.events!;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    // events posted by user
    if (widget.events != null) {
      setState(() {
        _events = widget.events!;
        _isLoading = false;
      });
    } else {
      // load from storage
      final events = await EventStorage.loadEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  // Future<void> _loadEvents() async {
  //   final events = await EventStorage.loadEvents();
  //   setState(() {
  //     _events = events;
  //     _isLoading = false;
  //   });
  // }

  void _startSelection(Offset position) {
    if (_selectionMode) {
      setState(() {
        _selectionStart = position;
        _selectionEnd = position;
        _selectedBounds = null;
      });
    }
  }

  void _updateSelection(Offset position) {
    if (_selectionMode && _selectionStart != null) {
      setState(() {
        _selectionEnd = position;
      });
    }
  }

  void _endSelection() {
    if (_selectionMode && _selectionStart != null && _selectionEnd != null) {
      final dx = (_selectionStart!.dx - _selectionEnd!.dx).abs();
      final dy = (_selectionStart!.dy - _selectionEnd!.dy).abs();
      
      if (dx > 20 || dy > 20) {
        final camera = _mapController.camera;
        final bounds = camera.visibleBounds;
        final size = camera.size;
        
        final lat1 = bounds.north - (_selectionStart!.dy / size.height) * (bounds.north - bounds.south);
        final lng1 = bounds.west + (_selectionStart!.dx / size.width) * (bounds.east - bounds.west);
        
        final lat2 = bounds.north - (_selectionEnd!.dy / size.height) * (bounds.north - bounds.south);
        final lng2 = bounds.west + (_selectionEnd!.dx / size.width) * (bounds.east - bounds.west);
        
        final point1 = LatLng(lat1, lng1);
        final point2 = LatLng(lat2, lng2);

        final north = point1.latitude > point2.latitude ? point1.latitude : point2.latitude;
        final south = point1.latitude < point2.latitude ? point1.latitude : point2.latitude;
        final east = point1.longitude > point2.longitude ? point1.longitude : point2.longitude;
        final west = point1.longitude < point2.longitude ? point1.longitude : point2.longitude;

        setState(() {
          _selectedBounds = SelectionBounds(
            LatLng(north, east),
            LatLng(south, west),
          );
        });

        _onSelectionComplete(_selectedBounds!);
      }
      
      setState(() {
        _selectionStart = null;
        _selectionEnd = null;
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedBounds = null;
      _selectionStart = null;
      _selectionEnd = null;
    });
  }

  void _onSelectionComplete(SelectionBounds bounds) {
    print('Selection complete: ${bounds.northEast}, ${bounds.southWest}');
  }

  Rect? _getSelectionRect() {
    if (_selectionStart == null || _selectionEnd == null) return null;

    final left = _selectionStart!.dx < _selectionEnd!.dx
        ? _selectionStart!.dx
        : _selectionEnd!.dx;
    final top = _selectionStart!.dy < _selectionEnd!.dy
        ? _selectionStart!.dy
        : _selectionEnd!.dy;
    final width = (_selectionStart!.dx - _selectionEnd!.dx).abs();
    final height = (_selectionStart!.dy - _selectionEnd!.dy).abs();

    return Rect.fromLTWH(left, top, width, height);
  }

  List<LatLng> _getBoundsPolygon() {
    if (_selectedBounds == null) return [];

    return [
      LatLng(_selectedBounds!.northEast.latitude, _selectedBounds!.southWest.longitude),
      _selectedBounds!.northEast,
      LatLng(_selectedBounds!.southWest.latitude, _selectedBounds!.northEast.longitude),
      _selectedBounds!.southWest,
    ];
  }

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
      case EventType.volcanicNonEruptive:
        return Icons.terrain;
      case EventType.massMovement_surfaceInstability:
        return Icons.landslide;
      case EventType.cryoseismic_glacial:
        return Icons.ac_unit;
      case EventType.hydrothermal_fluidDriven:
        return Icons.water_drop;
      case EventType.atmospheric_coupledSignals:
        return Icons.cloud;
      case EventType.anthropogenic:
        return Icons.construction;
      case EventType.geodetic_deformation:
        return Icons.compress;
      case EventType.multiSensor:
        return Icons.sensors;
      case EventType.false_test:
        return Icons.cancel;
      case EventType.unspecified_anomalous:
      default:
        return Icons.help_outline;
    }
  }

  List<Marker> _buildEventMarkers() {
    return _events
        .where((event) => event.latitude != null && event.longitude != null)
        .map((event) {
      final color = _getEventColor(event.eventType);
      final icon = _getEventIcon(event.eventType);

      return Marker(
        point: LatLng(event.latitude!, event.longitude!),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            _showEventDetails(event);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.eventType.name.replaceAll('_', ' ')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.source.isNotEmpty)
              Text('Source: ${event.source}'),
            if (event.description.isNotEmpty)
              Text('Description: ${event.description}'),
            if (event.startTime != null)
              Text('Start: ${event.startTime}'),
            if (event.country != Country.unspecified)
              Text('Country: ${event.country.name}'),
            if (event.townCity.isNotEmpty)
              Text('Location: ${event.townCity}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GestureDetector(
          onPanStart: (details) {
            _startSelection(details.localPosition);
          },
          onPanUpdate: (details) {
            _updateSelection(details.localPosition);
          },
          onPanEnd: (details) {
            _endSelection();
          },
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: _currentZoom,
              onPositionChanged: (position, _) {
                _currentZoom = position.zoom ?? _currentZoom;
              },
              interactionOptions: InteractionOptions(
                flags: _selectionMode 
                    ? InteractiveFlag.none
                    : InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _selectedLayer.urlTemplate,
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.volcano_app',
              ),
              if (_selectedBounds != null)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _getBoundsPolygon(),
                      color: Colors.blue.withOpacity(0.2),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),
              // Event markers
              MarkerLayer(
                markers: _buildEventMarkers(),
              ),
            ],
          ),
        ),

        if (_selectionMode && _selectionStart != null && _selectionEnd != null && _getSelectionRect() != null)
          Positioned.fromRect(
            rect: _getSelectionRect()!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                border: Border.all(
                  color: Colors.blue,
                  width: 2.0,
                ),
              ),
            ),
          ),

        const MapLegend(),

        Positioned(
          top: 16,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectionMode = !_selectionMode;
                      if (!_selectionMode) {
                        _selectionStart = null;
                        _selectionEnd = null;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectionMode
                          ? Colors.blue.shade100
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.crop_free,
                          color: _selectionMode
                              ? Colors.blue
                              : Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectionMode
                              ? 'Selection Mode (ON)'
                              : 'Selection Mode',
                          style: TextStyle(
                            color: _selectionMode
                                ? Colors.blue
                                : Colors.black87,
                            fontWeight: _selectionMode ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedBounds != null) ...[
                const SizedBox(height: 8),
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _clearSelection,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Clear Selection'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        Positioned(
          top: 16,
          right: 16,
          child: PopupMenuButton<MapLayer>(
            onSelected: (layer) {
              setState(() {
                _selectedLayer = layer;
              });
            },
            itemBuilder: (context) => MapLayer.values
                .map(
                  (layer) => PopupMenuItem(
                    value: layer,
                    child: Text(layer.label),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.layers),
            ),
          ),
        ),

        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'zoom_in',
                mini: true,
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _currentZoom + 1,
                  );
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _currentZoom - 1,
                  );
                },
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }
}