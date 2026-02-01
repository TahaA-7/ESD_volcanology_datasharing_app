import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_post_model.dart';
import '../utils_services/api_data_fetcher.dart';
import '../utils_services/download_service.dart';

class ReportGeneratorWizard extends StatefulWidget {
  const ReportGeneratorWizard({super.key});

  @override
  State<ReportGeneratorWizard> createState() => _ReportGeneratorWizardState();
}

class _ReportGeneratorWizardState extends State<ReportGeneratorWizard> {
  final ReportGenerator _reportGenerator = ReportGenerator();
  
  int _currentStep = 0;
  List<Event> _fetchedEvents = [];
  Set<int> _selectedEventIndices = {};
  bool _isLoading = false;

  // Fetch parameters
  DateTime? _startTime;
  double _minMagnitude = 2.0;
  bool _asDraft = true;

  // Export options
  bool _includeCoordinates = true;
  bool _includeDuration = true;
  bool _includeDescription = true;
  bool _includeSource = true;
  bool _includeStatus = false;

  late TextEditingController _filenameController;

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
    _filenameController.text = 'seismic_report_$dateStr';
  }

  List<Event> get _selectedEvents =>
      _selectedEventIndices.map((i) => _fetchedEvents[i]).toList();

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final events = await _reportGenerator.fetchAndPreview(
        startTime: _startTime,
        minMagnitude: _minMagnitude,
      );

      setState(() {
        _fetchedEvents = events;
        _selectedEventIndices = Set.from(List.generate(events.length, (i) => i));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching events: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportReport() async {
    if (_selectedEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one event'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_filenameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a filename'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = ExportConfig(
        includeCoordinates: _includeCoordinates,
        includeDuration: _includeDuration,
        includeDescription: _includeDescription,
        includeSource: _includeSource,
        includeStatus: _includeStatus,
        customFilename: _filenameController.text.trim(),
      );

      final downloadService = DownloadService();
      final savedPath = await downloadService.downloadEvents(
        _selectedEvents,
        format: ExportFormat.pdf,
        config: config,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Report saved: $savedPath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save report'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Fetch Parameters',
      'Select Events',
      'Export Options',
      'Review & Save',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF6B6B9C),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Generate Report',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(titles.length, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF6B6B9C)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      titles[index],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildFetchParametersStep();
      case 1:
        return _buildSelectEventsStep();
      case 2:
        return _buildExportOptionsStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildFetchParametersStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fetch Parameters',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Text('Start Time (Optional)'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _startTime ?? DateTime.now().subtract(const Duration(days: 1)),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _startTime = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _startTime != null
                  ? DateFormat('yyyy-MM-dd').format(_startTime!)
                  : 'Last 24 hours',
              style: TextStyle(
                color: _startTime != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Minimum Magnitude'),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '2.0',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) {
            final mag = double.tryParse(value);
            if (mag != null) {
              _minMagnitude = mag;
            }
          },
          controller: TextEditingController(text: _minMagnitude.toString()),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _asDraft,
          onChanged: (value) {
            setState(() {
              _asDraft = value ?? true;
            });
          },
          title: const Text('Save events as drafts'),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _fetchEvents,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_download),
            label: Text(_isLoading ? 'Fetching...' : 'Fetch Events'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectEventsStep() {
    if (_fetchedEvents.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Events',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'No events fetched yet.\nGo back to fetch parameters step.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_selectedEventIndices.length}/${_fetchedEvents.length} selected',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedEventIndices =
                      Set.from(List.generate(_fetchedEvents.length, (i) => i));
                });
              },
              child: const Text('Select All'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedEventIndices.clear();
                });
              },
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _fetchedEvents.length,
          itemBuilder: (context, index) {
            final event = _fetchedEvents[index];
            final isSelected = _selectedEventIndices.contains(index);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedEventIndices.add(index);
                    } else {
                      _selectedEventIndices.remove(index);
                    }
                  });
                },
                title: Text(
                  '${event.eventType.name} - ${event.startTime?.toString().split('.')[0] ?? 'No date'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.latitude != null && event.longitude != null)
                      Text('Lat: ${event.latitude}, Lon: ${event.longitude}'),
                    if (event.description.isNotEmpty)
                      Text(event.description,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExportOptionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Export Options',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Text(
          'Include Fields',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _buildCheckbox('Coordinates', _includeCoordinates, (value) {
              setState(() {
                _includeCoordinates = value ?? true;
              });
            }),
            _buildCheckbox('Duration', _includeDuration, (value) {
              setState(() {
                _includeDuration = value ?? true;
              });
            }),
            _buildCheckbox('Description', _includeDescription, (value) {
              setState(() {
                _includeDescription = value ?? true;
              });
            }),
            _buildCheckbox('Source', _includeSource, (value) {
              setState(() {
                _includeSource = value ?? true;
              });
            }),
            _buildCheckbox('Status', _includeStatus, (value) {
              setState(() {
                _includeStatus = value ?? false;
              });
            }),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Filename',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _filenameController,
                decoration: InputDecoration(
                  hintText: 'Enter filename',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '.pdf',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PDF format provides a professional report with all selected events.',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review & Save',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow('Events Selected', '${_selectedEvents.length}'),
              _buildReviewRow('Format', 'PDF'),
              _buildReviewRow('Filename', '${_filenameController.text}.pdf'),
              const Divider(height: 16),
              const Text(
                'Included Fields:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              if (_includeCoordinates) const Text('• Coordinates (Latitude/Longitude)'),
              if (_includeDuration) const Text('• Duration'),
              if (_includeDescription) const Text('• Description'),
              if (_includeSource) const Text('• Source'),
              if (_includeStatus) const Text('• Status'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ready to generate your report',
                  style: TextStyle(color: Colors.green.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return SizedBox(
      width: 150,
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
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('Back'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_currentStep < 3) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          _exportReport();
                        }
                      },
                child: Text(
                  _currentStep == 3
                      ? _isLoading
                          ? 'Generating...'
                          : 'Generate & Save'
                      : 'Next',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
