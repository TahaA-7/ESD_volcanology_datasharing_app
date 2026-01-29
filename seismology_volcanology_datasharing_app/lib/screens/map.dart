import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import '../widgets/legend.dart';

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

/// Selection bounds model
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
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 2.0;
  MapLayer _selectedLayer = MapLayer.standard;

  // Selection state
  bool _selectionMode = false; // Toggle for selection mode
  Offset? _selectionStart;
  Offset? _selectionEnd;
  SelectionBounds? _selectedBounds;

  void _startSelection(Offset position) {
    if (_selectionMode) {
      setState(() {
        _selectionStart = position;
        _selectionEnd = position;
        _selectedBounds = null; // Clear previous selection
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
      // Only create selection if drag was significant (more than 20 pixels)
      final dx = (_selectionStart!.dx - _selectionEnd!.dx).abs();
      final dy = (_selectionStart!.dy - _selectionEnd!.dy).abs();
      
      if (dx > 20 || dy > 20) {
        // Convert screen coordinates to lat/lng using camera's visibleBounds
        final camera = _mapController.camera;
        
        // Get the screen size
        final bounds = camera.visibleBounds;
        final size = camera.size;
        
        // Calculate the lat/lng based on proportional screen position
        final lat1 = bounds.north - (_selectionStart!.dy / size.height) * (bounds.north - bounds.south);
        final lng1 = bounds.west + (_selectionStart!.dx / size.width) * (bounds.east - bounds.west);
        
        final lat2 = bounds.north - (_selectionEnd!.dy / size.height) * (bounds.north - bounds.south);
        final lng2 = bounds.west + (_selectionEnd!.dx / size.width) * (bounds.east - bounds.west);
        
        final point1 = LatLng(lat1, lng1);
        final point2 = LatLng(lat2, lng2);

        // Calculate bounds
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

        // You can emit this selection to filter your events
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
    // TODO: Filter your events based on the bounds
    // You can call a callback or update a provider here
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The map itself with gesture detection
        GestureDetector(
          onPanStart: (details) {
            // Always start selection on pan start
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
                    ? InteractiveFlag.none // Disable map interactions in selection mode
                    : InteractiveFlag.all,  // Enable all interactions in normal mode
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _selectedLayer.urlTemplate,
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.volcano_app',
              ),
              // Show selected bounds polygon
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
            ],
          ),
        ),

        // Draw selection rectangle while dragging
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

        // Selection tools (top left)
        Positioned(
          top: 16,
          left: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Draw selection button
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectionMode = !_selectionMode;
                      if (!_selectionMode) {
                        // Clear selection drawings when exiting selection mode
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
              // Clear selection button
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

        /// Layer selector button (top right)
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

        /// Zoom in/out buttons (bottom right)
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