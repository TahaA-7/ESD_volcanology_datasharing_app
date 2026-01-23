part of '../event_post_wizard.dart';

class _BasicDetailsStepTimeState extends State<_BasicDetailsStepTime> {
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  final TextEditingController _microsecondsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final controller = context.read<EventPostWizardController>();

    _yearsController.text = controller.years ?? '';
    _daysController.text = controller.days ?? '';
    _hoursController.text = controller.hours ?? '';
    _minutesController.text = controller.minutes ?? '';
    _secondsController.text = controller.seconds ?? '';
    _microsecondsController.text = controller.microseconds ?? '';
  }
  @override
  void dispose() {
    _yearsController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    _microsecondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'timerange',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _yearsController, 
          decoration: InputDecoration(
            labelText: 'Years (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isNumeric && value.isLessThan(101)) {
              controller.years = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _daysController, 
          decoration: InputDecoration(
            labelText: 'Days (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(365)) {
              controller.days = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _hoursController, 
          decoration: InputDecoration(
            labelText: 'Hours (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(24)) {
              controller.hours = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _minutesController, 
          decoration: InputDecoration(
            labelText: 'Minutes (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(60)) {
              controller.minutes = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _secondsController, 
          decoration: InputDecoration(
            labelText: 'Seconds (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(60)) {
              controller.seconds = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _microsecondsController, 
          decoration: InputDecoration(
            labelText: 'Microseconds (press enter)',
            filled: true,
            fillColor: Color(0xFF8C8B9E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            if (value.isLessThan(1000000)) {
              controller.microseconds = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        DateTimePickerField(
          label: 'start time',
          value: controller.startTime,
          isError: !controller.isTimeRangeValid,
          onChanged: (dt) {
            controller.startTime = dt;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
        DateTimePickerField(
          label: 'end time',
          value: controller.endTime,
          isError: !controller.isTimeRangeValid,
          onChanged: (dt) {
            controller.endTime = dt;
            controller.notifyListeners();
          },
        ),
      ],
    );
  }
}
