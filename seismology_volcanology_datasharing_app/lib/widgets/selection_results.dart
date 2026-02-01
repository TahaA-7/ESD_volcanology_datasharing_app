import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_post_model.dart';
import '../screens/eventlist_detail.dart';
import '../utils_services/download_service.dart';
import '../widgets/event_details_dialog.dart';

class SelectionResultsPanel extends StatelessWidget {
  final List<Event> events;
  final VoidCallback onClose;
  final VoidCallback? onMinimize;
  
  const SelectionResultsPanel({
    super.key,
    required this.events,
    required this.onClose,
    this.onMinimize,
  });

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Results count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            child: Text(
              '${events.length} result${events.length != 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // lijst met events 
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Text(
                      'No events in selected region',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: events.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return _buildEventCard(context, events[index], dateFormat);
                    },
                  ),
          ),
          
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Selection Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // kleiner maken
          if (onMinimize != null)
            IconButton(
              icon: const Icon(Icons.minimize, size: 20),
              onPressed: onMinimize,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Minimize',
            ),
          const SizedBox(width: 8),
          // close knop
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event event, DateFormat dateFormat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getEventTypeColor(event.eventType).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(event.eventType),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Event type: ${event.eventType.name.replaceAll('_', ' ')}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // details van events
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Event subtype:', event.eventSubtype.name.replaceAll('_', ' ')),
                if (event.townCity.isNotEmpty || event.country != Country.unspecified)
                  _buildDetailRow(
                    'Location:',
                    '${event.townCity}${event.townCity.isNotEmpty && event.country != Country.unspecified ? ', ' : ''}${event.country != Country.unspecified ? event.country.name : ''}',
                  ),
                if (event.latitude != null && event.longitude != null)
                  _buildDetailRow(
                    'Location:',
                    '${event.latitude!.toStringAsFixed(6)}, ${event.longitude!.toStringAsFixed(6)}',
                  ),
                _buildDetailRow('Duration:', _formatDuration(event.duration)),
                if (event.startTime != null)
                  _buildDetailRow(
                    'Duration:',
                    '${dateFormat.format(event.startTime!)} -\n${dateFormat.format(event.startTime!.add(event.duration))}',
                  ),
                if (event.id.isNotEmpty)
                  _buildDetailRow('id:', event.id),
                
                const SizedBox(height: 8),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'More details (click)',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black87,
            height: 1.3,
          ),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          top: BorderSide(color: Colors.grey.shade400),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionButton(Icons.share, 'Share'),
          const SizedBox(width: 8),
          _buildActionButton(Icons.bookmark_border, 'Bookmark'),
          const SizedBox(width: 8),
          PopupMenuButton<ExportFormat>(
            child: const Row(
              children: [
                Icon(Icons.download, size: 18),
                SizedBox(width: 8),
                Text('Download'),
              ],
            ),
            onSelected: (ExportFormat format) async {
              final downloadService = DownloadService();
              try {
                final filename = await downloadService.downloadEvents(events, format: format);
                if (context.mounted && filename != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloaded ${format.name.toUpperCase()}: $filename')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Download failed: $e')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: ExportFormat.json, child: Text('JSON (.json)')),
              const PopupMenuItem(value: ExportFormat.csv, child: Text('CSV (.csv)')),
              const PopupMenuItem(value: ExportFormat.excel, child: Text('Excel (.xlsx)')),
              const PopupMenuItem(value: ExportFormat.pdf, child: Text('PDF (.pdf)')),
              const PopupMenuItem(value: ExportFormat.text, child: Text('Text (.txt)')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 20, color: Colors.grey[800]),
            ),
          ),
        ),
      ),
    );
  }

  Color _getEventTypeColor(EventType type) {
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
}