import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seismology_volcanology_datasharing_app/utils_services/download_service.dart';
import '../models/event_post_model.dart';
import '../utils_services/responsive_sizes.dart';
import 'download_widget.dart';

class EventDetailsDialog extends StatelessWidget {
  final Event event;

  const EventDetailsDialog({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    final isSmallScreen = ResponsiveSizes.isSmallDevice(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = isSmallScreen ? screenWidth * 0.9 : 500.0;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: isSmallScreen ? screenWidth * 1.2 : 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Event Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveSizes.getHorizontalPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Event type:', event.eventType.name.replaceAll('_', ' ')),
                    _buildDetailRow('Event subtype:', event.eventSubtype.name.replaceAll('_', ' ')),
                    
                    if (event.townCity.isNotEmpty)
                      _buildDetailRow('Location:', '${event.townCity}${event.country != Country.unspecified ? ', ${event.country.name}' : ''}'),
                    
                    if (event.latitude != null && event.longitude != null)
                      _buildDetailRow('Coordinates:', '${event.latitude}, ${event.longitude}'),
                    
                    if (event.source.isNotEmpty)
                      _buildDetailRow('Source:', event.source),
                    
                    if (event.startTime != null)
                      _buildDetailRow('Duration:', '${dateFormat.format(event.startTime!)} - ${dateFormat.format(event.startTime!.add(event.duration))}'),
                    
                    const SizedBox(height: 16),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.description.isNotEmpty 
                            ? event.description 
                            : 'No description available',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons - Responsive layout
                    isSmallScreen
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Share functionality coming soon')),
                                  );
                                },
                                icon: const Icon(Icons.share, size: 18),
                                label: const Text('Share'),
                              ),
                              const SizedBox(width: 12),
                              TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Bookmark functionality coming soon')),
                                  );
                                },
                                icon: const Icon(Icons.bookmark_border, size: 18),
                                label: const Text('Bookmark'),
                              ),
                              const SizedBox(width: 12),
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
                                    final filename = await downloadService.downloadEvents([event], format: format);
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
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Share functionality coming soon')),
                                );
                              },
                              icon: const Icon(Icons.share, size: 18),
                              label: const Text('Share'),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Bookmark functionality coming soon')),
                                );
                              },
                              icon: const Icon(Icons.bookmark_border, size: 18),
                              label: const Text('Bookmark'),
                            ),
                            const SizedBox(width: 16),
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
                                  final filename = await downloadService.downloadEvents([event], format: format);
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
                  
                  const SizedBox(height: 12),
                  
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('More details functionality coming soon')),
                        );
                      },
                      child: const Text(
                          'More details (click)',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      )
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}