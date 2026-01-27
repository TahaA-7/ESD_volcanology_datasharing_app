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

    _yearsController.text = controller.durationTime.years ?? '';
    _daysController.text = controller.durationTime.days ?? '';
    _hoursController.text = controller.durationTime.hours ?? '';
    _minutesController.text = controller.durationTime.minutes ?? '';
    _secondsController.text = controller.durationTime.seconds ?? '';
    _microsecondsController.text = controller.durationTime.microseconds ?? '';
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
              controller.durationTime.years = value;
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
              controller.durationTime.days = value;
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
              controller.durationTime.hours = value;
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
              controller.durationTime.minutes = value;
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
              controller.durationTime.seconds = value;
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
              controller.durationTime.microseconds = value;
              controller.notifyListeners();
            }
          },
        ),
        const SizedBox(height: 8),
        DateTimePickerField(
          label: 'start time',
          value: controller.durationTime.startTime,
          isError: TimeRangeValidator().validate(controller),  // test whether this works as expected
          onChanged: (dt) {
            controller.durationTime.startTime = dt;
            controller.notifyListeners();
          },
        ),
        const SizedBox(height: 8),
        DateTimePickerField(
          label: 'end time',
          value: controller.durationTime.endTime,
          isError: TimeRangeValidator().validate(controller),  // test whether this works as expected
          onChanged: (dt) {
            controller.durationTime.endTime = dt;
            controller.notifyListeners();
          },
        ),
      ],
    );
  }
}
