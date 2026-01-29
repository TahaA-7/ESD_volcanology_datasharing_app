part of '../event_post_wizard.dart';

class _ExtraDetailsStepState extends State<_ExtraDetailsStep> {
  final TextEditingController _sourceController = TextEditingController();

  final TextEditingController _descriptionBoxController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final controller = context.read<EventPostWizardController>();
    
    _sourceController.text = controller.extraDetails.source ?? '';
    _descriptionBoxController.text = controller.extraDetails.description ?? '';
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _descriptionBoxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'extra details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        EventPostStatusSelectionDropdown(
          value: controller.extraDetails.eventPostStatus,
          onChanged: (EventPostStatus? value) {
            controller.extraDetails.eventPostStatus = value ?? EventPostStatus.unspecified;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _sourceController, 
          decoration: InputDecoration(
            labelText: 'Source (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            controller.extraDetails.source = value;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionBoxController,
          decoration: InputDecoration(
            labelText: 'Description (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            controller.extraDetails.description = value;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
