// import 'dart:ffi';
library event_post_wizard;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
// import '../utils_services/event_builder.dart';

import '../models/event_post_model.dart';
import '../controllers/event_post_wizard_controller.dart';
import '../utils_services/event_drafter_submitter.dart';
import '../utils_services/stringformatter_validator.dart';
import '../widgets/date_time_picker_field.dart';
import '../widgets/dropdowns.dart';
import '../widgets/buttons.dart';

// part 'event_post_wizard_state/basic_details_step_event_state.dart';
part 'event_post_wizard_state/basic_details_step_location_state.dart';
part 'event_post_wizard_state/basic_details_step_time_state.dart';
part 'event_post_wizard_state/event_type_details_step_state.dart';
part 'event_post_wizard_state/extra_details_step_state.dart';

part '../utils_services/event_preview.dart';



class EventPostWizardScreen extends StatefulWidget {
  const EventPostWizardScreen({super.key});

  @override
  State<EventPostWizardScreen> createState() => _EventPostWizardScreenState();
}

class _EventPostWizardScreenState extends State<EventPostWizardScreen> {
  final List<String> _stepTitles = [
    '1 - basic details: event type',
    '1 - basic details: location',
    '1 - basic details: time range',
    '2 - event type details',
    '3 - extra details',
    '4 - upload',
  ];

  // void _saveDraft() {
  //   final controller = context.read<EventPostWizardController>();
  //   if (controller.canBuildEvent) {
  //     controller.saveDraft();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Draft saved!')),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please fill in required fields')),
  //     );
  //   }
  // }

  Future<void> _saveDraft() async {
    final controller = context.read<EventPostWizardController>();
    if (!controller.canBuildEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    try {
      final event = controller.buildEventDuration();
      // Call submission service
      await EventSubmissionService().submit(event, draft: true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved successfully!')),
      );
      controller.reset();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _submitEvent() async {
    final controller = context.read<EventPostWizardController>();
    if (!controller.canBuildEvent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    try {
      final event = controller.buildEventDuration();
      // Call submission service
      await EventSubmissionService().submit(event);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event posted successfully!')),
      );
      controller.reset();
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _nothing() {}

  void _continue() {
    final controller = context.read<EventPostWizardController>();
    if (controller.currentStep < _stepTitles.length - 1) {
      controller.nextStep();
    } else {
      _submitEvent();
    }
  }

  void _goBack() {
    final controller = context.read<EventPostWizardController>();
    if (controller.currentStep > 0) {
      controller.previousStep();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4DC),
      body: Column(
        children: [
          // Top navigation bar
          Container(
            color: const Color(0xFFD4CFC4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // align to the right
                children: [
                  // Back button (styled)
                  InkWell(
                    onTap: _goBack,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'back <',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Draft/Post buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlineButton(
                  label: 'Draft',
                  icon: Icons.description_outlined,
                  onTap: _saveDraft,
                ),
                const SizedBox(width: 8),
                FilledButton_(
                  label: 'Post',
                  icon: Icons.add,
                  onTap: _nothing,
                ),
              ],
            ),
          ),

          // Step headers
          Container(
            color: const Color(0xFFD4CFC4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: List.generate(_stepTitles.length, (index) {
                final isActive = index == controller.currentStep;
                return Expanded(
                  child: Center(
                    child: Text(
                      _stepTitles[index],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(controller),
            ),
          ),

          // Bottom next button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: _continue,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'next >',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(EventPostWizardController controller) {
    switch (controller.currentStep) {
      case 0:
        return _BasicDetailsStepEvent();
      case 1:
        return _BasicDetailsStepLocation();
      case 2:
        return _BasicDetailsStepTime();
      case 3:
        return _EventTypeDetailsStep();
      case 4: 
        return _ExtraDetailsStep();
      case 5:
        return _UploadStep();
      default:
        return const SizedBox();
    }
  }
}

class _BasicDetailsStepEvent extends StatelessWidget {
  const _BasicDetailsStepEvent();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'event type and subtype',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        EventTypeDropdown(
          value: controller.eventType,
          onChanged: (type) {
            controller.eventType = type;
            controller.eventSubtype = null;
            controller.notifyListeners();
          },
        ),

        const SizedBox(height: 8),

        EventSubtypeDropdown(
          eventType: controller.eventType,
          value: controller.eventSubtype,
          onChanged: (subtype) {
            controller.eventSubtype = subtype;
            controller.notifyListeners();
          },
        ),
      ],
    );
  }
}

class _BasicDetailsStepTime extends StatefulWidget {
  const _BasicDetailsStepTime();

  @override State<_BasicDetailsStepTime> createState() => _BasicDetailsStepTimeState();
}



class _BasicDetailsStepLocation extends StatefulWidget {
  const _BasicDetailsStepLocation();

  @override
  State<_BasicDetailsStepLocation> createState() => _BasicDetailsStepLocationState();
}



class _EventTypeDetailsStep extends StatefulWidget {
  const _EventTypeDetailsStep();

  @override
  State<_EventTypeDetailsStep> createState() => _EventTypeDetailsStepState();
}



class _ExtraDetailsStep extends StatefulWidget {
  const _ExtraDetailsStep();

  @override
  State<_ExtraDetailsStep> createState() => _ExtraDetailsStepState();
}



class _UploadStep extends StatelessWidget {
  const _UploadStep();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preview & Upload',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Event Preview Card
        if (controller.canBuildEvent)
          EventPreviewCard(
            event: controller.buildEventDuration(),
          )
        else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Unable to build preview. Please complete required fields.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Media upload section
        const Text(
          'Upload Media (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            try {
              // TODO: Implement media picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Not implemented yet')),
              );
            }
            catch (e) {return;}
          },
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add Photos/Videos'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ],
    );
  }
}
