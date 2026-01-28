import '../screens/event_post_wizard.dart';
import '../models/event_post_model.dart';

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


abstract class EventRepository {
  Future<void> save(Event event, {bool draft = false});
  Future<List<Event>> loadAll({bool draftsOnly = false});
  Future<Event?> loadById(String id);
  Future<void> delete(String id);
}

class JsonFileEventRepository implements EventRepository {
  final String _filename = 'events.json';
  
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_filename');
  }
  
  Future<List<dynamic>> _loadEventsFromFile() async {
    final file = await _getFile();
    if (!await file.exists()) return [];
    
    final content = await file.readAsString();
    if (content.isEmpty) return [];
    
    return jsonDecode(content) as List<dynamic>;
  }
  
  @override
  Future<void> save(Event event, {bool draft = false}) async {
    final file = await _getFile();
    final events = await _loadEventsFromFile();
    
    final eventJson = _serializeEvent(event, draft: draft);
    
    // Update existing event or add new one
    final existingIndex = events.indexWhere((e) => e['id'] == event.id);
    if (existingIndex != -1) {
      events[existingIndex] = eventJson;
    } else {
      events.add(eventJson);
    }
    
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(events), mode: FileMode.write);
  }
  
  @override
  Future<List<Event>> loadAll({bool draftsOnly = false}) async {
    final events = await _loadEventsFromFile();
    
    return events
        .where((json) => !draftsOnly || json['draftBool'] == true)
        .map((json) => _deserializeEvent(json))
        .whereType<Event>()
        .toList();
  }
  
  @override
  Future<Event?> loadById(String id) async {
    final events = await _loadEventsFromFile();
    
    try {
      final eventJson = events.firstWhere((e) => e['id'] == id);
      return _deserializeEvent(eventJson);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> delete(String id) async {
    final file = await _getFile();
    final events = await _loadEventsFromFile();
    
    events.removeWhere((e) => e['id'] == id);
    await file.writeAsString(jsonEncode(events), mode: FileMode.write);
  }
  
  Map<String, dynamic> _serializeEvent(Event event, {bool draft = false}) {
    final baseData = {
      'id': event.id,
      'eventType': event.eventType.name,
      'country': event.country.name,
      'stateProvince': event.stateProvince,
      'townCity': event.townCity,
      'longitude': event.longitude,
      'latitude': event.latitude,
      'duration_ms': event.duration.inMilliseconds,
      'startTime': event.startTime?.toIso8601String(),
      'timeRange': event.timeRange != null
          ? {
              'start': event.timeRange!.start.toIso8601String(),
              'end': event.timeRange!.end.toIso8601String(),
            }
          : null,
      'draftBool': draft,
    };
    
    final serializer = EventSerializerRegistry.getSerializer(event.eventType);
    final specificData = serializer.serializeSpecific(event as dynamic);
    
    return {...baseData, ...specificData};
  }
  
  Event? _deserializeEvent(Map<String, dynamic> json) {
    try {
      final eventTypeStr = json['eventType'] as String;
      final eventType = EventType.values.firstWhere(
        (e) => e.name == eventTypeStr,
        orElse: () => EventType.unspecified_anomalous,
      );
      
      final serializer = EventSerializerRegistry.getSerializer(eventType);
      return serializer.deserialize(json);
    } 
    catch (e) {
      print('Error deserializing event: $e');
      return null;
    }
  }
}


class EventSubmissionService {
  final JsonFileEventRepository _repository = JsonFileEventRepository();
  
  Future<void> submit(Event event, {bool draft = false}) async {
    try {
      await _repository.save(event, draft: draft);
      
      final directory = await getApplicationDocumentsDirectory();
      print('Event saved in: ${directory.path}');
    } 
    catch (e) {
      throw Exception("Error saving event: $e");
    }
  }
  
  Future<List<Event>> loadDrafts() async {
    return await _repository.loadAll(draftsOnly: true);
  }
  
  Future<List<Event>> loadAllEvents() async {
    return await _repository.loadAll(draftsOnly: false);
  }
  
  Future<void> deleteEvent(String id) async {
    await _repository.delete(id);
  }
}
