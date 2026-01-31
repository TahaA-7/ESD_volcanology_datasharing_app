import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
import '../models/event_post_model.dart';

/// Service for downloading/exporting events in various formats
enum ExportFormat {
  csv,
  json,
  excel,
  pdf,
  text,
}

class ExportConfig {
  final bool includeCoordinates;
  final bool includeDuration;
  final bool includeDescription;
  final bool includeSource;
  final bool includeStatus;
  final String? customFilename;

  const ExportConfig({
    this.includeCoordinates = true,
    this.includeDuration = true,
    this.includeDescription = true,
    this.includeSource = true,
    this.includeStatus = false,
    this.customFilename,
  });
}

class DownloadService {
  /// Generate a default filename with timestamp
  static String generateFilename(ExportFormat format, int eventCount) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd_HHmmss').format(now);
    final extension = _getExtension(format);
    return 'events_export_${eventCount}_$dateStr$extension';
  }

  /// Get file extension for format
  static String _getExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.json:
        return '.json';
      case ExportFormat.excel:
        return '.xlsx';
      case ExportFormat.pdf:
        return '.pdf';
      case ExportFormat.text:
        return '.txt';
    }
  }

  /// Get MIME type for format
  static MimeType _getMimeType(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return MimeType.csv;
      case ExportFormat.json:
        return MimeType.json;
      case ExportFormat.excel:
        return MimeType.microsoftExcel;
      case ExportFormat.pdf:
        return MimeType.pdf;
      case ExportFormat.text:
        return MimeType.text;
    }
  }

  /// Download multiple events in specified format
  Future<String?> downloadEvents(
    List<Event> events, {
    required ExportFormat format,
    ExportConfig config = const ExportConfig(),
  }) async {
    if (events.isEmpty) {
      throw Exception('No events to export');
    }

    final fileName = config.customFilename ?? 
                     generateFilename(format, events.length).replaceAll(_getExtension(format), '');
    
    final bytes = await _generateContentBytes(events, format, config);

    return _saveFile(
      fileName: fileName,
      bytes: bytes,
      extension: _getExtension(format).replaceFirst('.', ''),
      mimeType: _getMimeType(format),
    );
  }

  /// Save file using FileSaver with fallback
  Future<String?> _saveFile({
    required String fileName,
    required Uint8List bytes,
    required String extension,
    required MimeType mimeType,
  }) async {
    try {
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: extension,
        mimeType: mimeType,
      );
      
      return '$fileName.$extension';
    } catch (e) {
      // Fallback to app documents directory
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName.$extension');
        await file.writeAsBytes(bytes);
        
        print("Saved to internal storage: ${file.path}");
        return file.path;
      } catch (fallbackError) {
        print('Error saving file: $fallbackError');
        rethrow;
      }
    }
  }

  /// Generate content as bytes (handles both text and binary formats)
  Future<Uint8List> _generateContentBytes(
    List<Event> events,
    ExportFormat format,
    ExportConfig config,
  ) async {
    switch (format) {
      case ExportFormat.csv:
      case ExportFormat.json:
      case ExportFormat.text:
      case ExportFormat.pdf: // Currently text-based PDF
        final content = _generateTextContent(events, format, config);
        return Uint8List.fromList(utf8.encode(content));
      
      case ExportFormat.excel:
        return await _generateExcelBytes(events, config);
    }
  }

  /// Generate text content for text-based formats
  String _generateTextContent(
    List<Event> events,
    ExportFormat format,
    ExportConfig config,
  ) {
    switch (format) {
      case ExportFormat.csv:
        return _generateCSV(events, config);
      case ExportFormat.json:
        return _generateJSON(events, config);
      case ExportFormat.pdf:
        return _generateTextPDF(events, config);
      case ExportFormat.text:
        return _generateText(events, config);
      case ExportFormat.excel:
        throw Exception('Excel should use binary generation');
    }
  }

  String _generateCSV(List<Event> events, ExportConfig config) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    
    // Headers
    final headers = <String>[
      'ID',
      'Event Type',
      'Event Subtype',
      'Location',
      'Country',
    ];
    
    if (config.includeCoordinates) {
      headers.addAll(['Latitude', 'Longitude']);
    }
    if (config.includeSource) headers.add('Source');
    if (config.includeDuration) {
      headers.addAll(['Start Time', 'End Time', 'Duration (hours)']);
    }
    if (config.includeDescription) headers.add('Description');
    if (config.includeStatus) headers.add('Status');
    
    buffer.writeln(headers.map(_escapeCsv).join(','));
    
    // Data rows
    for (final event in events) {
      final row = <String>[
        event.id,
        event.eventType.name.replaceAll('_', ' '),
        event.eventSubtype.name.replaceAll('_', ' '),
        event.townCity.isNotEmpty ? event.townCity : 'N/A',
        event.country.name,
      ];
      
      if (config.includeCoordinates) {
        row.add(event.latitude?.toString() ?? 'N/A');
        row.add(event.longitude?.toString() ?? 'N/A');
      }
      if (config.includeSource) {
        row.add(event.source.isNotEmpty ? event.source : 'N/A');
      }
      if (config.includeDuration) {
        row.add(event.startTime != null ? dateFormat.format(event.startTime!) : 'N/A');
        row.add(event.startTime != null ? dateFormat.format(event.startTime!.add(event.duration)) : 'N/A');
        row.add(event.duration.inHours.toString());
      }
      if (config.includeDescription) {
        row.add(event.description.isNotEmpty ? event.description : 'N/A');
      }
      if (config.includeStatus) row.add(event.status.name);
      
      buffer.writeln(row.map(_escapeCsv).join(','));
    }
    
    return buffer.toString();
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _generateJSON(List<Event> events, ExportConfig config) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    
    final exportData = events.map((event) {
      final data = <String, dynamic>{
        'id': event.id,
        'eventType': event.eventType.name,
        'eventSubtype': event.eventSubtype.name,
        'location': {
          'townCity': event.townCity,
          'stateProvince': event.stateProvince,
          'country': event.country.name,
        },
      };
      
      if (config.includeCoordinates && event.latitude != null && event.longitude != null) {
        data['coordinates'] = {
          'latitude': event.latitude,
          'longitude': event.longitude,
        };
      }
      
      if (config.includeSource) {
        data['source'] = event.source;
      }
      
      if (config.includeDuration) {
        data['time'] = {
          'startTime': event.startTime != null ? dateFormat.format(event.startTime!) : null,
          'endTime': event.startTime != null ? dateFormat.format(event.startTime!.add(event.duration)) : null,
          'durationHours': event.duration.inHours,
          'durationMinutes': event.duration.inMinutes,
        };
      }
      
      if (config.includeDescription) {
        data['description'] = event.description;
      }
      
      if (config.includeStatus) {
        data['status'] = event.status.name;
        data['draft'] = event.draft;
      }
      
      return data;
    }).toList();
    
    final output = {
      'metadata': {
        'exportDate': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'totalEvents': events.length,
        'format': 'json',
        'version': '1.0',
      },
      'events': exportData,
    };
    
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(output);
  }

  /// Generate Excel file as bytes
  Future<Uint8List> _generateExcelBytes(List<Event> events, ExportConfig config) async {
    var excel = Excel.createExcel();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    String sheetName = "Events";
    Sheet sheetObject = excel[sheetName];
    
    // Remove default sheet if it exists
    if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    // Headers
    final headers = [
      TextCellValue('ID'),
      TextCellValue('Event Type'),
      TextCellValue('Event Subtype'),
      TextCellValue('Location'),
      TextCellValue('Country'),
    ];
    
    if (config.includeCoordinates) {
      headers.add(TextCellValue('Latitude'));
      headers.add(TextCellValue('Longitude'));
    }
    if (config.includeSource) headers.add(TextCellValue('Source'));
    if (config.includeDuration) {
      headers.add(TextCellValue('Start Time'));
      headers.add(TextCellValue('End Time'));
      headers.add(TextCellValue('Duration (hours)'));
    }
    if (config.includeDescription) headers.add(TextCellValue('Description'));
    if (config.includeStatus) headers.add(TextCellValue('Status'));

    sheetObject.appendRow(headers);

    // Data rows
    for (var event in events) {
      final row = <CellValue>[
        TextCellValue(event.id),
        TextCellValue(event.eventType.name.replaceAll('_', ' ')),
        TextCellValue(event.eventSubtype.name.replaceAll('_', ' ')),
        TextCellValue(event.townCity.isNotEmpty ? event.townCity : 'N/A'),
        TextCellValue(event.country.name),
      ];
      
      if (config.includeCoordinates) {
        row.add(TextCellValue(event.latitude?.toString() ?? 'N/A'));
        row.add(TextCellValue(event.longitude?.toString() ?? 'N/A'));
      }
      if (config.includeSource) {
        row.add(TextCellValue(event.source.isNotEmpty ? event.source : 'N/A'));
      }
      if (config.includeDuration) {
        row.add(TextCellValue(event.startTime != null ? dateFormat.format(event.startTime!) : 'N/A'));
        row.add(TextCellValue(event.startTime != null ? dateFormat.format(event.startTime!.add(event.duration)) : 'N/A'));
        row.add(TextCellValue(event.duration.inHours.toString()));
      }
      if (config.includeDescription) {
        row.add(TextCellValue(event.description.isNotEmpty ? event.description : 'N/A'));
      }
      if (config.includeStatus) {
        row.add(TextCellValue(event.status.name));
      }

      sheetObject.appendRow(row);
    }

    final excelBytes = excel.encode();
    if (excelBytes == null) {
      throw Exception('Failed to encode Excel file');
    }

    return Uint8List.fromList(excelBytes);
  }

  /// Generate text-based PDF (placeholder - use pdf package for real PDFs)
  String _generateTextPDF(List<Event> events, ExportConfig config) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    final buffer = StringBuffer();
    
    buffer.writeln('=' * 80);
    buffer.writeln('EVENT EXPORT REPORT'.padLeft(50));
    buffer.writeln('=' * 80);
    buffer.writeln();
    buffer.writeln('Generated: ${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('Total Events: ${events.length}');
    buffer.writeln();
    buffer.writeln('=' * 80);
    buffer.writeln();
    
    for (var i = 0; i < events.length; i++) {
      final event = events[i];
      
      buffer.writeln('EVENT ${i + 1} of ${events.length}');
      buffer.writeln('-' * 80);
      buffer.writeln('ID: ${event.id}');
      buffer.writeln('Type: ${event.eventType.name.replaceAll('_', ' ')}');
      buffer.writeln('Subtype: ${event.eventSubtype.name.replaceAll('_', ' ')}');
      
      if (event.townCity.isNotEmpty) {
        buffer.writeln('Location: ${event.townCity}, ${event.stateProvince}, ${event.country.name}');
      }
      
      if (config.includeCoordinates && event.latitude != null) {
        buffer.writeln('Coordinates: ${event.latitude}, ${event.longitude}');
      }
      
      if (config.includeSource && event.source.isNotEmpty) {
        buffer.writeln('Source: ${event.source}');
      }
      
      if (config.includeDuration && event.startTime != null) {
        buffer.writeln('Start Time: ${dateFormat.format(event.startTime!)}');
        buffer.writeln('End Time: ${dateFormat.format(event.startTime!.add(event.duration))}');
        buffer.writeln('Duration: ${event.duration.inHours}h ${event.duration.inMinutes % 60}m');
      }
      
      if (config.includeDescription && event.description.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Description:');
        buffer.writeln(event.description);
      }
      
      if (config.includeStatus) {
        buffer.writeln('Status: ${event.status.name}');
        buffer.writeln('Draft: ${event.draft ? 'Yes' : 'No'}');
      }
      
      buffer.writeln();
      buffer.writeln('=' * 80);
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  String _generateText(List<Event> events, ExportConfig config) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    return events.map((event) {
      final buffer = StringBuffer();
      
      buffer.writeln('Event ID: ${event.id}');
      buffer.writeln('Type: ${event.eventType.name.replaceAll('_', ' ')}');
      buffer.writeln('Subtype: ${event.eventSubtype.name.replaceAll('_', ' ')}');
      
      if (event.townCity.isNotEmpty) {
        buffer.writeln('Location: ${event.townCity}, ${event.country.name}');
      }
      
      if (config.includeCoordinates && event.latitude != null && event.longitude != null) {
        buffer.writeln('Coordinates: ${event.latitude}, ${event.longitude}');
      }
      
      if (config.includeSource && event.source.isNotEmpty) {
        buffer.writeln('Source: ${event.source}');
      }
      
      if (config.includeDuration && event.startTime != null) {
        buffer.writeln('Start Time: ${dateFormat.format(event.startTime!)}');
        buffer.writeln('Duration: ${event.duration.inHours}h ${event.duration.inMinutes % 60}m');
      }
      
      if (config.includeDescription && event.description.isNotEmpty) {
        buffer.writeln('Description: ${event.description}');
      }
      
      if (config.includeStatus) {
        buffer.writeln('Status: ${event.status.name}');
      }
      
      return buffer.toString();
    }).join('\n${'=' * 80}\n\n');
  }

  // Get estimated file size in bytes
  static int estimateFileSize(
    List<Event> events,
    ExportFormat format,
  ) {
    if (events.isEmpty) return 0;
    
    int bytesPerEvent = 0;
    switch (format) {
      case ExportFormat.csv:
        bytesPerEvent = 200;
        break;
      case ExportFormat.json:
        bytesPerEvent = 400;
        break;
      case ExportFormat.excel:
        bytesPerEvent = 300;
        break;
      case ExportFormat.pdf:
        bytesPerEvent = 500;
        break;
      case ExportFormat.text:
        bytesPerEvent = 250;
        break;
    }
    
    return events.length * bytesPerEvent;
  }

  // Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
