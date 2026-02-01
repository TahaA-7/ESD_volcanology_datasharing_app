import 'package:flutter/material.dart';
import '../models/event_post_model.dart';

class MapLegend extends StatefulWidget {
  const MapLegend({super.key});

  @override
  State<MapLegend> createState() => _MapLegendState();
}

class _MapLegendState extends State<MapLegend> {
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = true;
  bool _isMinimized = false;
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      case EventType.multiSensor:
        return Icons.sensors;
      case EventType.unspecified_anomalous:
        return Icons.help_outline;
      case EventType.false_test:
        return Icons.science;
      default:
        return Icons.event;
    }
  }

  Color _getEventColor(EventType type) {
    switch (type) {
      case EventType.seismic_tectonic:
        return Colors.deepOrange;
      case EventType.volcanicEruptive_surfaceProcess:
        return Colors.red;
      case EventType.volcanicNonEruptive:
        return Colors.redAccent;
      case EventType.massMovement_surfaceInstability:
        return Colors.brown;
      case EventType.cryoseismic_glacial:
        return Colors.lightBlue;
      case EventType.hydrothermal_fluidDriven:
        return Colors.teal;
      case EventType.atmospheric_coupledSignals:
        return Colors.indigo;
      case EventType.anthropogenic:
        return Colors.purple;
      case EventType.geodetic_deformation:
        return Colors.green;
      case EventType.multiSensor:
        return Colors.cyan;
      case EventType.unspecified_anomalous:
        return Colors.yellow;
      case EventType.false_test:
        return Colors.grey;
    }
  }

  String _getEventLabel(EventType type) {
    switch (type) {
      case EventType.seismic_tectonic:
        return 'Seismic / Tectonic';
      case EventType.volcanicEruptive_surfaceProcess:
        return 'Volcanic (Eruptive)';
      case EventType.volcanicNonEruptive:
        return 'Volcanic (Non-Eruptive)';
      case EventType.massMovement_surfaceInstability:
        return 'Mass Movement';
      case EventType.cryoseismic_glacial:
        return 'Cryoseismic / Glacial';
      case EventType.hydrothermal_fluidDriven:
        return 'Hydrothermal';
      case EventType.atmospheric_coupledSignals:
        return 'Atmospheric';
      case EventType.anthropogenic:
        return 'Anthropogenic';
      case EventType.geodetic_deformation:
        return 'Geodetic';
      case EventType.multiSensor:
        return 'Multi-Sensor';
      case EventType.unspecified_anomalous:
        return 'Unspecified';
      case EventType.false_test:
        return 'False / Test';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Minimized button only
    if (_isMinimized) {
      return Positioned(
        bottom: 16,
        left: 16,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              setState(() {
                _isMinimized = false;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                size: 24,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return Positioned(
      bottom: 16,
      left: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        constraints: BoxConstraints(
          maxHeight: _isExpanded ? 250 : 60,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomLeft: _isExpanded ? Radius.zero : const Radius.circular(8),
                  bottomRight: _isExpanded ? Radius.zero : const Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Legend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Collapse/Expand button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Minimize button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isMinimized = true;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.minimize,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable event types (max 4 visible)
            if (_isExpanded)
              Flexible(
                child: Stack(
                  children: [
                    Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 4,
                      radius: const Radius.circular(2),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            children: [
                              // All event types
                              ...EventType.values.map((type) => _LegendItem(
                                icon: _getEventIcon(type),
                                color: _getEventColor(type),
                                label: _getEventLabel(type),
                              )),
                              
                              const SizedBox(height: 4),
                              const Divider(height: 1),
                              const SizedBox(height: 4),
                              
                              // Cluster
                              const _LegendItem(
                                icon: Icons.star,
                                color: Colors.blueGrey,
                                label: 'Cluster',
                                isCluster: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Scroll indicators
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildScrollIndicator(Icons.arrow_upward, () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: _buildScrollIndicator(Icons.arrow_downward, () {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      }),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300]?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 12, color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isCluster;

  const _LegendItem({
    required this.icon,
    required this.color,
    required this.label,
    this.isCluster = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Icon
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          
          // Color circle (not for cluster)
          if (!isCluster)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
          
          // Star for cluster
          if (isCluster)
            Icon(
              Icons.star,
              size: 12,
              color: color,
            ),
          
          const SizedBox(width: 6),
          
          // Label
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}