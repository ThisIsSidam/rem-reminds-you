import 'package:Rem/utils/other_utils/flex_picker/flex_picker.dart';
import 'package:flutter/material.dart';

enum FlexDurationPickerMode {
  s, m, h, d, ms, hm, dh, hms
}

class FlexDurationPicker extends StatefulWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onDurationChanged;
  final FlexDurationPickerMode mode;
  final Duration maxDuration;
  final double pickerHeight;
  final double pickerWidth;
  final double itemExtent;
  final double fontSize;
  final TextStyle? labelStyle;
  final Widget? separator;
  final PickerOrientation orientation;

  const FlexDurationPicker({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
    this.mode = FlexDurationPickerMode.hm,
    this.maxDuration = const Duration(days: 365),
    this.pickerHeight = 150,
    this.pickerWidth = 40,
    this.itemExtent = 32,
    this.fontSize = 20,
    this.labelStyle,
    this.separator,
    this.orientation = PickerOrientation.vertical,
  });

  @override
  State<FlexDurationPicker> createState() => _FlexDurationPickerState();
}

class _FlexDurationPickerState extends State<FlexDurationPicker> {
  late int _selectedDays;
  late int _selectedHours;
  late int _selectedMinutes;
  late int _selectedSeconds;

  @override
  void initState() {
    super.initState();
    _initializeDuration();
  }

  void _initializeDuration() {
    _selectedDays = widget.initialDuration.inDays;
    _selectedHours = widget.initialDuration.inHours % 24;
    _selectedMinutes = widget.initialDuration.inMinutes % 60;
    _selectedSeconds = widget.initialDuration.inSeconds % 60;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pickers = [];

    switch (widget.mode) {
      case FlexDurationPickerMode.s:
        pickers.add(_buildSecondPicker());
        break;
      case FlexDurationPickerMode.m:
        pickers.add(_buildMinutePicker());
        break;
      case FlexDurationPickerMode.h:
        pickers.add(_buildHourPicker());
        break;
      case FlexDurationPickerMode.d:
        pickers.add(_buildDayPicker());
        break;
      case FlexDurationPickerMode.ms:
        pickers.addAll([_buildMinutePicker(), _addSeparator(), _buildSecondPicker()]);
        break;
      case FlexDurationPickerMode.hm:
        pickers.addAll([_buildHourPicker(), _addSeparator(), _buildMinutePicker()]);
        break;
      case FlexDurationPickerMode.dh:
        pickers.addAll([_buildDayPicker(), _addSeparator(), _buildHourPicker()]);
        break;
      case FlexDurationPickerMode.hms:
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

  Widget _buildDayPicker() => FlexPicker(
        itemCount: widget.maxDuration.inDays + 1,
        initialItem: _selectedDays,
        onSelectedItemChanged: (value) => _updateDuration(days: value),
        label: 'Day',
        height: widget.pickerHeight,
        width: widget.pickerWidth,
        itemExtent: widget.itemExtent,
        fontSize: widget.fontSize,
        labelStyle: widget.labelStyle,
        orientation: widget.orientation,
      );

  void _updateDuration({int? days, int? hours, int? minutes, int? seconds}) {
    setState(() {
      if (days != null) _selectedDays = days;
      if (hours != null) _selectedHours = hours;
      if (minutes != null) _selectedMinutes = minutes;
      if (seconds != null) _selectedSeconds = seconds;
    });

    final newDuration = Duration(
      days: _selectedDays,
      hours: _selectedHours,
      minutes: _selectedMinutes,
      seconds: _selectedSeconds,
    );

    if (newDuration <= widget.maxDuration) {
      widget.onDurationChanged(newDuration);
    } else {
      // If the new duration exceeds the max duration, reset to max duration
      _initializeDuration();
      widget.onDurationChanged(widget.maxDuration);
    }
  }
}