import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_post_model.dart';

enum EventListView { grid, list }

class EventListWidget extends StatefulWidget {
  final List<Event>? events;
  const EventListWidget({super.key, this.events});

  @override
  State<EventListWidget> createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  EventListView _viewMode = EventListView.grid;
  
  List<Event> get _events => widget.events ?? [];

  String _formatEventType(EventType type) {
    return type.name.replaceAll('_', ' ');
  }

  String _formatLocation(Event event) {
    final parts = <String>[];
    if (event.townCity.isNotEmpty) parts.add(event.townCity);
    if (event.stateProvince.isNotEmpty) parts.add(event.stateProvince);
    if (event.country != Country.unspecified) parts.add(event.country.name);
    
    return parts.isEmpty ? 'Location not specified' : parts.join(', ');
  }

  String _formatCoordinates(Event event) {
    if (event.latitude != null && event.longitude != null) {
      return '${event.latitude!.toStringAsFixed(6)}, ${event.longitude!.toStringAsFixed(6)}';
    }
    return 'N/A';
  }

  String _formatDuration(Event event) {
    if (event.duration.inSeconds == 0) return 'N/A';
    
    final hours = event.duration.inHours;
    final minutes = event.duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDateRange(Event event) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    
    if (event.timeRange != null) {
      return '${dateFormat.format(event.timeRange!.start)} - ${dateFormat.format(event.timeRange!.end)}';
    } else if (event.startTime != null) {
      final endTime = event.startTime!.add(event.duration);
      return '${dateFormat.format(event.startTime!)} - ${dateFormat.format(endTime)}';
    }
    
    return 'Time not specified';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF6B6B9C),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _events.isEmpty
                ? const Center(
                    child: Text(
                      'No events to display',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : _viewMode == EventListView.grid
                    ? _buildGridView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.pause, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          Text(
            '${_events.length} results',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          Row(
            children: [
              _buildViewButton(
                icon: Icons.list,
                isSelected: _viewMode == EventListView.list,
                onTap: () {
                  setState(() {
                    _viewMode = EventListView.list;
                  });
                },
              ),
              const SizedBox(width: 8),
              _buildViewButton(
                icon: Icons.grid_view,
                isSelected: _viewMode == EventListView.grid,
                onTap: () {
                  setState(() {
                    _viewMode = EventListView.grid;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(_events[index]);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event type: ${_formatEventType(event.eventType)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Source: ${event.source.isEmpty ? 'N/A' : event.source}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Location: ${_formatLocation(event)}',
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Coordinates: ${_formatCoordinates(event)}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${_formatDuration(event)}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Time: ${_formatDateRange(event)}',
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  'id: ${event.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _showEventDetails(event);
                },
                child: const Text(
                  'More details (click)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Checkbox(
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    _buildHeaderCell('Type', flex: 2),
                    _buildHeaderCell('Source', flex: 2),
                    _buildHeaderCell('Location', flex: 2),
                    _buildHeaderCell('Coordinates', flex: 2),
                    _buildHeaderCell('Duration', flex: 1),
                    _buildHeaderCell('Time Range', flex: 3),
                    _buildHeaderCell('Id', flex: 2),
                    const SizedBox(width: 100),
                  ],
                ),
              ),
              
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  return _buildListRow(_events[index], index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildListRow(Event event, int index) {
    final isEven = index % 2 == 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEven ? Colors.grey[100] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          _buildDataCell(_formatEventType(event.eventType), flex: 2),
          _buildDataCell(event.source.isEmpty ? 'N/A' : event.source, flex: 2),
          _buildDataCell(_formatLocation(event), flex: 2),
          _buildDataCell(_formatCoordinates(event), flex: 2),
          _buildDataCell(_formatDuration(event), flex: 1),
          _buildDataCell(_formatDateRange(event), flex: 3),
          _buildDataCell(event.id, flex: 2),
          
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _showEventDetails(event);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'More details',
                      style: TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildDataCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_formatEventType(event.eventType)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID', event.id),
              _buildDetailRow('Type', _formatEventType(event.eventType)),
              if (event.source.isNotEmpty)
                _buildDetailRow('Source', event.source),
              if (event.description.isNotEmpty)
                _buildDetailRow('Description', event.description),
              _buildDetailRow('Location', _formatLocation(event)),
              _buildDetailRow('Coordinates', _formatCoordinates(event)),
              _buildDetailRow('Duration', _formatDuration(event)),
              _buildDetailRow('Time Range', _formatDateRange(event)),
              _buildDetailRow('Status', event.status.name),
              _buildDetailRow('Draft', event.draft ? 'Yes' : 'No'),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}