import 'package:flutter/material.dart';
import '../utils_services/event_cluster.dart';

class MapClusterMarker extends StatefulWidget {
  final EventCluster cluster;
  final VoidCallback onTap;

  const MapClusterMarker({
    super.key,
    required this.cluster,
    required this.onTap,
  });

  @override
  State<MapClusterMarker> createState() => _MapClusterMarkerState();
}

class _MapClusterMarkerState extends State<MapClusterMarker> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final count = widget.cluster.count;
    final size = _getClusterSize(count);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: widget.onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer halo
                Container(
                  width: size + 30,
                  height: size + 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                
                // Middle halo
                Container(
                  width: size + 15,
                  height: size + 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.purple.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                
                // Core with star
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: _isHovered ? Colors.purple : Colors.purple.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: _isHovered ? 4 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isHovered ? 0.5 : 0.3),
                        blurRadius: _isHovered ? 8 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                // Event count badge
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tooltip on hover
          if (_isHovered)
            Positioned(
              bottom: size / 2 + 25,
              child: IgnorePointer(
                child: _buildTooltip(),
              ),
            ),
        ],
      ),
    );
  }

  double _getClusterSize(int count) {
    if (count > 100) return 60.0;
    if (count > 50) return 55.0;
    if (count > 20) return 50.0;
    if (count > 10) return 45.0;
    return 40.0;
  }

  Widget _buildTooltip() {
    return Material(
      color: Colors.transparent,
      child: Container(
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
        child: Text(
          '${widget.cluster.count} events\nClick to zoom in',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}