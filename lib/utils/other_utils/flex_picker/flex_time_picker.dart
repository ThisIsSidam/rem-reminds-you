import 'package:Rem/utils/other_utils/flex_picker/flex_picker.dart';
import 'package:flutter/material.dart';

enum FlexDateTimePickerMode {
  s, m, h, ms, hm, hms
}

class FlexDateTimePicker extends StatefulWidget {
  final DateTime initalTime;
  final ValueChanged<DateTime> onDateTimeChanged;
  final FlexDateTimePickerMode mode;
  final double pickerHeight;
  final double pickerWidth;
  final double itemExtent;
  final double fontSize;
  final TextStyle? labelStyle;
  final Widget? separator;
  final PickerOrientation orientation;

  const FlexDateTimePicker({
    super.key,
    required this.initalTime,
    required this.onDateTimeChanged,
    this.mode = FlexDateTimePickerMode.hm,
    this.pickerHeight = 150,
    this.pickerWidth = 40,
    this.itemExtent = 32,
    this.fontSize = 20,
    this.labelStyle,
    this.separator,
    this.orientation = PickerOrientation.vertical,
  });

  @override
  State<FlexDateTimePicker> createState() => _FlexDateTimePickerState();
}

class _FlexDateTimePickerState extends State<FlexDateTimePicker> {
  late int _selectedHours;
  late int _selectedMinutes;
  late int _selectedSeconds;

  @override
  void initState() {
    super.initState();
    _initializeDuration();
  }

  void _initializeDuration() {
    _selectedHours = widget.initalTime.hour;
    _selectedMinutes = widget.initalTime.minute;
    _selectedSeconds = widget.initalTime.second;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pickers = [];

    switch (widget.mode) {
      case FlexDateTimePickerMode.s:
        pickers.add(_buildSecondPicker());
        break;
      case FlexDateTimePickerMode.m:
        pickers.add(_buildMinutePicker());
        break;
      case FlexDateTimePickerMode.h:
        pickers.add(_buildHourPicker());
        break;
      case FlexDateTimePickerMode.ms:
        pickers.addAll([_buildMinutePicker(), _addSeparator(), _buildSecondPicker()]);
        break;
      case FlexDateTimePickerMode.hm:
        pickers.addAll([_buildHourPicker(), _addSeparator(), _buildMinutePicker()]);
        break;
      case FlexDateTimePickerMode.hms:
        pickers.addAll([
          _buildHourPicker(),
          _addSeparator(),
          _buildMinutePicker(),
          _addSeparator(),
          _buildSecondPicker()
        ]);
        break;
    }

    return widget.orientation == PickerOrientation.vertical
      ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: pickers,
        )
      : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: pickers,
        );
  }

  Widget _addSeparator() {
    return widget.orientation == PickerOrientation.vertical
        ? (widget.separator ?? const SizedBox(width: 20))
        : (widget.separator ?? const SizedBox(height: 20));
  }

  Widget _buildSecondPicker() => FlexPicker(
    itemCount: 60,
    initialItem: _selectedSeconds,
    onSelectedItemChanged: (value) => _updateDuration(seconds: value),
    label: 'Sec',
    height: widget.pickerHeight,
    width: widget.pickerWidth,
    itemExtent: widget.itemExtent,
    fontSize: widget.fontSize,
    labelStyle: widget.labelStyle,
    orientation: widget.orientation,
  );

  Widget _buildMinutePicker() => FlexPicker(
    itemCount: 60,
    initialItem: _selectedMinutes,
    onSelectedItemChanged: (value) => _updateDuration(minutes: value),
    label: 'Min',
    height: widget.pickerHeight,
    width: widget.pickerWidth,
    itemExtent: widget.itemExtent,
    fontSize: widget.fontSize,
    labelStyle: widget.labelStyle,
    orientation: widget.orientation,
  );

  Widget _buildHourPicker() => FlexPicker(
    itemCount: 24,
    initialItem: _selectedHours,
    onSelectedItemChanged: (value) => _updateDuration(hours: value),
    label: 'Hr',
    height: widget.pickerHeight,
    width: widget.pickerWidth,
    itemExtent: widget.itemExtent,
    fontSize: widget.fontSize,
    labelStyle: widget.labelStyle,
    orientation: widget.orientation,
  );

  void _updateDuration({
    int? hours, int? minutes, int? seconds}) {
    setState(() {
      if (hours != null) _selectedHours = hours;
      if (minutes != null) _selectedMinutes = minutes;
      if (seconds != null) _selectedSeconds = seconds;
    });

    final newDuration = DateTime(
      widget.initalTime.year,
      widget.initalTime.month,
      widget.initalTime.day,
      _selectedHours,
      _selectedMinutes,
      _selectedSeconds,
    );

    widget.onDateTimeChanged(newDuration);
  }
}