import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
        // ESRI World Imagery
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/'
            'World_Imagery/MapServer/tile/{z}/{y}/{x}';

      case MapLayer.terrain:
        // OpenTopoMap
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';

      case MapLayer.standard:
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }
}

/// Main map screen
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 2.0;
  MapLayer _selectedLayer = MapLayer.standard;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The map itself
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(0, 0),
            initialZoom: _currentZoom,
            onPositionChanged: (position, _) {
              _currentZoom = position.zoom ?? _currentZoom;
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _selectedLayer.urlTemplate,
              subdomains: ['a', 'b', 'c'], // required for OpenTopoMap
              userAgentPackageName: 'com.example.volcano_app',
            ),
          ],
        ),
        const MapLegend(),

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
