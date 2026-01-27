import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../models/event_post_model.dart';
// import '../controllers/event_post_wizard_controller.dart';
import '../screens/event_post_wizard.dart';

class EventPostLandingScreen extends StatelessWidget {
  const EventPostLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4DC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Event Post',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // New Post Button
                _ActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'Start New Post',
                  onTap: () {
                    final controller = context.read<EventPostWizardController>();
                    controller.reset();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: controller,
                          child: const EventPostWizardScreen(),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Load Draft Button
                _ActionButton(
                  icon: Icons.drafts_outlined,
                  label: 'Load Draft',
                  onTap: () {
                    final controller = context.read<EventPostWizardController>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: controller,
                          child: const DraftsListScreen(),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Back Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFD4CFC4),
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DraftsListScreen extends StatefulWidget {
  const DraftsListScreen({super.key});

  @override
  State<DraftsListScreen> createState() => _DraftsListScreenState();
}

class _DraftsListScreenState extends State<DraftsListScreen> {
  List<Map<String, dynamic>> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/events.json');

      if (!await file.exists()) {
        setState(() {
          _drafts = [];
          _isLoading = false;
        });
        return;
      }

      final String content = await file.readAsString();
      if (content.isEmpty) {
        setState(() {
          _drafts = [];
          _isLoading = false;
        });
        return;
      }

      final List<dynamic> allEvents = jsonDecode(content);
      
      // Filter only drafts
      setState(() {
        _drafts = allEvents
            .where((event) => event['draftBool'] == true)
            .cast<Map<String, dynamic>>()
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading drafts: $e')),
        );
      }
    }
  }

  Future<void> _deleteDraft(int index) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/events.json');
      
      final String content = await file.readAsString();
      List<dynamic> allEvents = jsonDecode(content);
      
      // Find and remove the draft
      final draftToRemove = _drafts[index];
      allEvents.removeWhere((event) => 
        event['id'] == draftToRemove['id'] && 
        event['draftBool'] == true
      );
      
      // Save updated list
      await file.writeAsString(jsonEncode(allEvents), mode: FileMode.write);
      
      // Reload drafts
      await _loadDrafts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting draft: $e')),
        );
      }
    }
  }

  void _loadDraft(Map<String, dynamic> draftData) {
    final controller = context.read<EventPostWizardController>();
    
    // Load basic data
    controller.eventType = EventType.values.firstWhere(
      (e) => e.name == draftData['eventType'],
      orElse: () => EventType.unspecified_anomalous,
    );
    
    controller.location.country = Country.values.firstWhere(
      (e) => e.name == draftData['country'],
      orElse: () => Country.unspecified,
    );
    
    controller.location.stateprovince = draftData['stateProvince'];
    controller.location.towncity = draftData['townCity'];
    controller.location.longitude = draftData['longitude'];
    controller.location.latitude = draftData['latitude'];
    
    // Load time data
    if (draftData['startTime'] != null) {
      controller.durationTime.startTime = DateTime.parse(draftData['startTime']);
    }
    
    if (draftData['timeRange'] != null) {
      controller.durationTime.startTime = DateTime.parse(draftData['timeRange']['start']);
      controller.durationTime.endTime = DateTime.parse(draftData['timeRange']['end']);
    }
    
    // Load duration
    if (draftData['duration_ms'] != null) {
      final duration = Duration(milliseconds: draftData['duration_ms']);
      controller.durationTime.days = duration.inDays.toString();
      controller.durationTime.hours = (duration.inHours % 24).toString();
      controller.durationTime.minutes = (duration.inMinutes % 60).toString();
      controller.durationTime.seconds = (duration.inSeconds % 60).toString();
    }
    
    // Navigate to wizard
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const EventPostWizardScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4CFC4),
        title: const Text('Drafts', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _drafts.isEmpty
              ? const Center(
                  child: Text(
                    'No drafts found',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _drafts.length,
                  itemBuilder: (context, index) {
                    final draft = _drafts[index];
                    return _DraftCard(
                      draft: draft,
                      onLoad: () => _loadDraft(draft),
                      onDelete: () => _deleteDraft(index),
                    );
                  },
                ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final Map<String, dynamic> draft;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.draft,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              draft['eventType'] ?? 'Unknown Type',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (draft['townCity'] != null && draft['townCity'].isNotEmpty)
              Text('Location: ${draft['townCity']}'),
            if (draft['stateProvince'] != null && draft['stateProvince'].isNotEmpty)
              Text('State/Province: ${draft['stateProvince']}'),
            if (draft['startTime'] != null)
              Text('Start: ${DateTime.parse(draft['startTime']).toString().split('.')[0]}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onLoad,
                  icon: const Icon(Icons.edit),
                  label: const Text('Continue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4CFC4),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
