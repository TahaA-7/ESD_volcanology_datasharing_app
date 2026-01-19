import 'package:flutter/material.dart';

enum EventListView { grid, list }

class EventListWidget extends StatefulWidget {
  const EventListWidget({super.key});

  @override
  State<EventListWidget> createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  EventListView _viewMode = EventListView.grid;
  
  // Mock event data
  final List<Map<String, dynamic>> _events = [
    {
      'type': 'seismic',
      'subtype': 'earthquake',
      'location': 'Kocaeli, Türkiye',
      'coordinates': '40.881304, 30.068038',
      'duration': '55m',
      'dateRange': '14-12-2025 14:30 - 14-21-2025 15:25',
      'id': '71B1883a-8664-4760-bb57-8b428b7b2a24',
    },
    {
      'type': 'seismic',
      'subtype': 'earthquake',
      'location': 'Izmir, Türkiye',
      'coordinates': '38.423733, 27.142826',
      'duration': '40m',
      'dateRange': '13-12-2025 14:35 - 14-21-2025 15:15',
      'id': '144be38a-2ff2-4058-bfc7-a232424c0e970',
    },
    {
      'type': 'lorem',
      'subtype': 'ipsum',
      'location': 'dolor',
      'coordinates': 'sit',
      'duration': 'amet',
      'dateRange': 'consectetur',
      'id': 'adipiscing',
    },
    {
      'type': 'lorem',
      'subtype': 'ipsum',
      'location': 'dolor',
      'coordinates': 'sit',
      'duration': 'amet',
      'dateRange': 'consectetur',
      'id': 'adipiscing',
    },
    {
      'type': 'lorem',
      'subtype': 'ipsum',
      'location': 'dolor',
      'coordinates': 'sit',
      'duration': 'amet',
      'dateRange': 'consectetur',
      'id': 'adipiscing',
    },
    {
      'type': 'lorem',
      'subtype': 'ipsum',
      'location': 'dolor',
      'coordinates': 'sit',
      'duration': 'amet',
      'dateRange': 'consectetur',
      'id': 'adipiscing',
    },
    {
      'type': 'lorem',
      'subtype': 'ipsum',
      'location': 'dolor',
      'coordinates': 'sit',
      'duration': 'amet',
      'dateRange': 'consectetur',
      'id': 'adipiscing',
    },
    {
      'type': 'lorem',
      'subtype': 'ipsum',
      'location': 'dolor',
      'coordinates': 'sit',
      'duration': 'amet',
      'dateRange': 'consectetur',
      'id': 'adipiscing',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF6B6B9C),
      child: Column(
        children: [
          // Header with results count and view toggle
          _buildHeader(),
          
          // Content area
          Expanded(
            child: _viewMode == EventListView.grid
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
          // Collapse/Expand button
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
          
          // Results count
          Text(
            '${_events.length} results',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // View mode toggle buttons
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

  Widget _buildEventCard(Map<String, dynamic> event) {
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
                  'Event type: ${event['type']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Event subtype: ${event['subtype']}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Location: ${event['location']}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Location: ${event['coordinates']}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${event['duration']}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${event['dateRange']}',
                  style: const TextStyle(fontSize: 13),
                ),
                const Spacer(),
                Text(
                  'id: ${event['id']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {},
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
              // Header row
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
                    _buildHeaderCell('Subtype', flex: 2),
                    _buildHeaderCell('Location', flex: 2),
                    _buildHeaderCell('Location', flex: 2),
                    _buildHeaderCell('Duration', flex: 2),
                    _buildHeaderCell('Duration', flex: 3),
                    _buildHeaderCell('Id', flex: 3),
                    const SizedBox(width: 100), // Space for checkbox and button
                  ],
                ),
              ),
              
              // Data rows
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

  Widget _buildListRow(Map<String, dynamic> event, int index) {
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
          _buildDataCell(event['type'], flex: 2),
          _buildDataCell(event['subtype'], flex: 2),
          _buildDataCell(event['location'], flex: 2),
          _buildDataCell(event['coordinates'], flex: 2),
          _buildDataCell(event['duration'], flex: 2),
          _buildDataCell(event['dateRange'], flex: 3),
          _buildDataCell(event['id'], flex: 3),
          
          // Checkbox and button
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
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'More details (click)',
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
}