import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/event_post_model.dart';
import '../utils_services/download_service.dart';

enum DownloadFormat {
  csv,
  json,
  excel,
  pdf,
}

extension DownloadFormatExtension on DownloadFormat {
  String get label {
    switch (this) {
      case DownloadFormat.csv:
        return 'CSV';
      case DownloadFormat.json:
        return 'JSON';
      case DownloadFormat.excel:
        return 'Excel (XLSX)';
      case DownloadFormat.pdf:
        return 'PDF Report';
    }
  }

  String get fileExtension {
    switch (this) {
      case DownloadFormat.csv:
        return '.csv';
      case DownloadFormat.json:
        return '.json';
      case DownloadFormat.excel:
        return '.xlsx';
      case DownloadFormat.pdf:
        return '.pdf';
    }
  }

  IconData get icon {
    switch (this) {
      case DownloadFormat.csv:
        return Icons.table_chart;
      case DownloadFormat.json:
        return Icons.code;
      case DownloadFormat.excel:
        return Icons.grid_on;
      case DownloadFormat.pdf:
        return Icons.picture_as_pdf;
    }
  }
}

class DownloadWidget extends StatefulWidget {
  final List<Event>? events;
  final VoidCallback? onClose;

  const DownloadWidget({
    super.key,
    this.events,
    this.onClose,
  });

  @override
  State<DownloadWidget> createState() => _DownloadWidgetState();
}

class _DownloadWidgetState extends State<DownloadWidget> {
  late TextEditingController _filenameController;
  
  DownloadFormat _selectedFormat = DownloadFormat.csv;
  bool _includeCoordinates = true;
  bool _includeDuration = true;
  bool _includeDescription = true;
  bool _includeSource = true;
  bool _includeStatus = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _filenameController = TextEditingController();
    _generateDefaultFilename();
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  void _generateDefaultFilename() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd_HHmmss').format(now);
    final eventCount = widget.events?.length ?? 0;
    _filenameController.text = 'events_export_${eventCount}_$dateStr';
  }

  List<Event> get _events => widget.events ?? [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventSummary(),
                    const SizedBox(height: 24),
                    _buildFormatSelector(),
                    const SizedBox(height: 24),
                    _buildFieldSelector(),
                    const SizedBox(height: 24),
                    _buildFilenameInput(),
                    const SizedBox(height: 24),
                    _buildFormatInfo(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF6B6B9C),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.download,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Export Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to export ${_events.length} event${_events.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue.shade900,
                  ),
                ),
                if (_events.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getEventTypeBreakdown(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTypeBreakdown() {
    if (_events.isEmpty) return '';
    
    final typeCount = <EventType, int>{};
    for (final event in _events) {
      typeCount[event.eventType] = (typeCount[event.eventType] ?? 0) + 1;
    }
    
    final sorted = typeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top3 = sorted.take(3).map((e) => 
      '${e.key.name.replaceAll('_', ' ')}: ${e.value}'
    ).join(', ');
    
    return top3;
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Format',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: DownloadFormat.values.map((format) {
            final isSelected = _selectedFormat == format;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedFormat = format;
                  _generateDefaultFilename();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B6B9C) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6B6B9C) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      format.icon,
                      color: isSelected ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      format.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFieldSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Include Fields',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _includeCoordinates = true;
                  _includeDuration = true;
                  _includeDescription = true;
                  _includeSource = true;
                  _includeStatus = true;
                });
              },
              child: const Text('Select All', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _includeCoordinates = false;
                  _includeDuration = false;
                  _includeDescription = false;
                  _includeSource = false;
                  _includeStatus = false;
                });
              },
              child: const Text('Deselect All', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Basic fields (ID, Type, Location, Time) are always included',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildCheckbox('Coordinates', _includeCoordinates, (value) {
              setState(() => _includeCoordinates = value ?? false);
            }),
            _buildCheckbox('Duration', _includeDuration, (value) {
              setState(() => _includeDuration = value ?? false);
            }),
            _buildCheckbox('Description', _includeDescription, (value) {
              setState(() => _includeDescription = value ?? false);
            }),
            _buildCheckbox('Source', _includeSource, (value) {
              setState(() => _includeSource = value ?? false);
            }),
            _buildCheckbox('Status', _includeStatus, (value) {
              setState(() => _includeStatus = value ?? false);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return SizedBox(
      width: 140,
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Text(label, style: const TextStyle(fontSize: 13)),
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildFilenameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filename',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _filenameController,
                decoration: InputDecoration(
                  hintText: 'Enter filename',
                  suffixText: _selectedFormat.fileExtension,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _generateDefaultFilename,
              icon: const Icon(Icons.refresh),
              tooltip: 'Generate default filename',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatInfo() {
    String info = '';
    switch (_selectedFormat) {
      case DownloadFormat.csv:
        info = 'csv - ideal for spreadsheet applications (e.g. Excel or Google Sheets)';
        break;
      case DownloadFormat.json:
        info = 'json - preferrable for programmers';
        break;
      case DownloadFormat.excel:
        info = 'Excel - Ideal for data analysis and presentation.';
        break;
      case DownloadFormat.pdf:
        info = 'PDF - Best for sharing and archival purposes.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'File size: ${_estimateFileSize()}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isDownloading ? null : _handleDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B6B9C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: _isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(_isDownloading ? 'Preparing...' : 'Download'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _estimateFileSize() {
    if (_events.isEmpty) return '~0 KB';

    final bytes = DownloadService.estimateFileSize(
      _events,
      toServiceFormat(_selectedFormat),
    );

    return '~${DownloadService.formatFileSize(bytes)}';
  }

  Future<void> _handleDownload() async {
    if (_events.isEmpty) {
      _showMessage('No events to export', isError: true);
      return;
    }

    if (_filenameController.text.trim().isEmpty) {
      _showMessage('Please enter a filename', isError: true);
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Convert DownloadFormat enum to service enum
      final serviceFormat = toServiceFormat(_selectedFormat);
      
      // Create export config
      final config = ExportConfig(
        includeCoordinates: _includeCoordinates,
        includeDuration: _includeDuration,
        includeDescription: _includeDescription,
        includeSource: _includeSource,
        includeStatus: _includeStatus,
        customFilename: _filenameController.text.trim(),
      );
      
      // Download using service
      final DownloadService downloadService = DownloadService();
      final savedPath = await downloadService.downloadEvents(
        _events,
        format: serviceFormat,
        config: config,
      );
      
      if (savedPath != null) {
        _showMessage('File saved: $savedPath');
        
        // Close dialog after successful download
        Future.delayed(const Duration(seconds: 2), () {
          if (widget.onClose != null) {
            widget.onClose!();
          } else {
            Navigator.of(context).pop();
          }
        });
      } else {
        _showMessage('Failed to save file', isError: true);
      }
      
    } catch (e) {
      _showMessage('Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  ExportFormat toServiceFormat(DownloadFormat format) {
    switch (format) {
      case DownloadFormat.csv:
        return ExportFormat.csv;
      case DownloadFormat.json:
        return ExportFormat.json;
      case DownloadFormat.excel:
        return ExportFormat.excel;
      case DownloadFormat.pdf:
        return ExportFormat.pdf;
    }
  }
}
