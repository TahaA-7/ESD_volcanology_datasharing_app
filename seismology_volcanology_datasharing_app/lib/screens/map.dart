import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../widgets/legend.dart';
import '../widgets/map_event_marker.dart';
import '../widgets/map_cluster_marker.dart';
import '../widgets/event_details_dialog.dart';
import '../models/event_post_model.dart';
import '../utils_services/event_storage.dart';
import '../utils_services/event_cluster.dart';
import '../utils_services/responsive_sizes.dart'; 

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
    if (widget.events != null) {
      setState(() {
        _events = widget.events!;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEvents() async {
    if (widget.events != null) {
      setState(() {
        _events = widget.events!;
        _isLoading = false;
      });
    } else {
      final events = await EventStorage.loadEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

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

  double _calculateHaloSize(Event event) {
    // Calculate halo size based on event duration
    final duration = event.duration;
    
    if (duration.inDays > 7) return 100.0;
    if (duration.inDays > 3) return 80.0;
    if (duration.inDays > 1) return 65.0;
    if (duration.inHours > 12) return 55.0;
    if (duration.inHours > 6) return 50.0;
    if (duration.inHours > 1) return 45.0;
    
    return 40.0; // Minimum size
  }

  List<Marker> _buildEventMarkers() {
    // Cluster events based on zoom level
    final clusters = EventClusterManager.clusterEvents(_events, _currentZoom);

    return clusters.map((cluster) {
      if (cluster.isCluster) {
        // Multiple events - show cluster marker
        return Marker(
          point: cluster.center,
          width: 80,
          height: 80,
          child: MapClusterMarker(
            cluster: cluster,
            onTap: () {
              // Zoom in to cluster location
              _mapController.move(
                cluster.center,
                _currentZoom + 2,
              );
            },
          ),
        );
      } else {
        // Single event - show regular marker with halo
        final event = cluster.events.first;
        final haloSize = _calculateHaloSize(event);
        
        return Marker(
          point: cluster.center,
          width: haloSize,
          height: haloSize,
          child: MapEventMarker(
            data: EventMarkerData(
              event: event,
              position: cluster.center,
              haloSize: haloSize,
            ),
            onTap: () => _showEventDetails(event),
          ),
        );
      }
    }).toList();
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => EventDetailsDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveSizes.getHorizontalPadding(context);

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
                setState(() {
                  _currentZoom = position.zoom ?? _currentZoom;
                });
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
              MarkerLayer(
                markers: _buildEventMarkers(),
              ),
            ],
          ),
        ),

        if (_selectionMode && _selectionStart != null && _selectionEnd != null && _getSelectionRect() != null)
          Positioned.fromRect(
            rect: _getSelectionRect()!,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(horizontalPadding),
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