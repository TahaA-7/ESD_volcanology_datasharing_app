import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_post_model.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ScrollController _descriptionController = ScrollController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  String _formatCoordinates(double? lat, double? lon) {
    if (lat == null || lon == null) return 'N/A';
    
    final latDeg = lat.abs().floor();
    final latMin = ((lat.abs() - latDeg) * 60).floor();
    final latSec = ((lat.abs() - latDeg - latMin / 60) * 3600);
    final latDir = lat >= 0 ? 'N' : 'S';
    
    final lonDeg = lon.abs().floor();
    final lonMin = ((lon.abs() - lonDeg) * 60).floor();
    final lonSec = ((lon.abs() - lonDeg - lonMin / 60) * 3600);
    final lonDir = lon >= 0 ? 'E' : 'W';
    
    return '${latDeg}° ${latMin}\' ${latSec.toStringAsFixed(1)}" $latDir, '
           '${lonDeg}° ${lonMin}\' ${lonSec.toStringAsFixed(1)}" $lonDir';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Top Navigation Bar with Back Button
          _buildTopBar(context),
          
          // Main Content
          Expanded(
            child: Row(
              children: [
                // Left Panel - Event Details
                Expanded(
                  flex: 5,
                  child: _buildLeftPanel(dateFormat),
                ),
                
                // Right Panel - Description
                Expanded(
                  flex: 5,
                  child: _buildRightPanel(),
                ),
              ],
            ),
          ),
          
          // Bottom Action Bar
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_back,
                        size: 32,
                        color: Colors.grey[800],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Action Buttons
          _buildActionButton(Icons.share, 'Share'),
          const SizedBox(width: 12),
          _buildActionButton(Icons.bookmark_border, 'Bookmark'),
          const SizedBox(width: 12),
          _buildActionButton(Icons.download, 'Download'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$tooltip functionality coming soon')),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 28, color: Colors.grey[800]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel(DateFormat dateFormat) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Type
            _buildDetailItem(
              'Event type:',
              widget.event.eventType.name.replaceAll('_', ' '),
              fontSize: 20,
            ),
            const SizedBox(height: 16),
            
            // Event Subtype
            _buildDetailItem(
              'Event subtype:',
              widget.event.eventSubtype.name.replaceAll('_', ' '),
              fontSize: 20,
            ),
            const SizedBox(height: 16),
            
            // Location (City/Country)
            if (widget.event.townCity.isNotEmpty || widget.event.country != Country.unspecified)
              _buildDetailItem(
                'Location:',
                '${widget.event.townCity}${widget.event.townCity.isNotEmpty && widget.event.country != Country.unspecified ? ', ' : ''}${widget.event.country != Country.unspecified ? widget.event.country.name : ''}',
                fontSize: 20,
              ),
            if (widget.event.townCity.isNotEmpty || widget.event.country != Country.unspecified)
              const SizedBox(height: 16),
            
            // Location (Coordinates - Decimal)
            if (widget.event.latitude != null && widget.event.longitude != null)
              _buildDetailItem(
                'Location:',
                '${widget.event.latitude}, ${widget.event.longitude}',
                fontSize: 20,
              ),
            if (widget.event.latitude != null && widget.event.longitude != null)
              const SizedBox(height: 16),
            
            // Location (Coordinates - DMS)
            if (widget.event.latitude != null && widget.event.longitude != null)
              _buildDetailItem(
                'Location:',
                _formatCoordinates(widget.event.latitude, widget.event.longitude),
                fontSize: 20,
              ),
            if (widget.event.latitude != null && widget.event.longitude != null)
              const SizedBox(height: 16),
            
            // Duration
            _buildDetailItem(
              'Duration:',
              _formatDuration(widget.event.duration),
              fontSize: 20,
            ),
            const SizedBox(height: 16),
            
            // Duration (Date Range)
            if (widget.event.startTime != null)
              _buildDetailItem(
                'Duration:',
                '${dateFormat.format(widget.event.startTime!)} -\n${dateFormat.format(widget.event.startTime!.add(widget.event.duration))}',
                fontSize: 20,
              ),
            if (widget.event.startTime != null)
              const SizedBox(height: 24),
            
            const Divider(height: 32, thickness: 2),
            
            // Event Details Section
            const Text(
              'Event details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Custom fields based on event type
            ..._buildEventSpecificDetails(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEventSpecificDetails() {
    final details = <Widget>[];
    
    // Add event-specific details based on type
    if (widget.event is EventSeismic) {
      final seismic = widget.event as EventSeismic;
      // Add magnitude, depth, seismic network, etc.
      details.add(_buildDetailItem('Magnitude:', '4.0', fontSize: 18));
      details.add(const SizedBox(height: 12));
      details.add(_buildDetailItem('Population:', '2,102,907', fontSize: 18));
      details.add(const SizedBox(height: 12));
      details.add(_buildDetailItem(
        'Seismic Station Network:',
        'AFAD (Disaster and Emergency Management Authority) and Kandilli Observatory',
        fontSize: 18,
      ));
      details.add(const SizedBox(height: 12));
      details.add(_buildDetailItem(
        'Primary Recording Station:',
        'ERBA, Turkey (Seismic Station Code)',
        fontSize: 18,
      ));
      details.add(const SizedBox(height: 12));
      details.add(_buildDetailItem('Depth:', 'N/A', fontSize: 18));
    }
    
    // Add source if available
    if (widget.event.source.isNotEmpty) {
      details.add(const SizedBox(height: 12));
      details.add(_buildDetailItem('Source:', widget.event.source, fontSize: 18));
    }
    
    return details;
  }

  Widget _buildRightPanel() {
    return Container(
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Header
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Description:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          
          // Description Content with Scrollbar
          Expanded(
            child: widget.event.description.isEmpty
                ? const SizedBox.shrink() // Empty if no description
                : Stack(
                    children: [
                      // Description Text
                      Scrollbar(
                        controller: _descriptionController,
                        thumbVisibility: true,
                        thickness: 8,
                        radius: const Radius.circular(4),
                        child: SingleChildScrollView(
                          controller: _descriptionController,
                          padding: const EdgeInsets.fromLTRB(32, 0, 48, 32),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              widget.event.description,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Up/Down scroll indicators
                      Positioned(
                        right: 16,
                        top: 16,
                        child: _buildScrollIndicator(Icons.arrow_upward, () {
                          _descriptionController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: _buildScrollIndicator(Icons.arrow_downward, () {
                          _descriptionController.animateTo(
                            _descriptionController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollIndicator(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade400.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {double fontSize = 16}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black87,
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}