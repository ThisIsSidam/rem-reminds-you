import 'package:Rem/utils/flex_picker/flex_picker.dart';
import 'package:flutter/material.dart';

enum FlexDurationPickerMode {
  s, m, h, d, ms, hm, dh, hms, dhm
}

class FlexDurationPickerController extends ChangeNotifier {
  Duration _duration;
  bool _isNegative;

  FlexDurationPickerController({Duration initialDuration = Duration.zero})
      : _duration = initialDuration.abs(),
        _isNegative = initialDuration.isNegative;

  Duration get duration => _isNegative ? -_duration : _duration;

  set duration(Duration newDuration) {
    if (_duration != newDuration.abs() || _isNegative != newDuration.isNegative) {
      _duration = newDuration.abs();
      _isNegative = newDuration.isNegative;
      notifyListeners();
    }
  }

  void updateDuration(Duration newDuration) {
    duration = newDuration;
  }

  void setSign(bool isNegative) {
    if (_isNegative != isNegative) {
      _isNegative = isNegative;
      notifyListeners();
    }
  }
}

class FlexDurationPicker extends StatefulWidget {
  final FlexDurationPickerController? controller;
  final ValueChanged<Duration>? onDurationChanged;
  final FlexDurationPickerMode mode;
  final Duration maxDuration;
  final double pickerHeight;
  final double pickerWidth;
  final double itemExtent;
  final double fontSize;
  final TextStyle? labelStyle;
  final Widget? separator;
  final Color color;
  final bool allowNegative;

  const FlexDurationPicker({
    super.key,
    this.controller,
    this.onDurationChanged,
    this.mode = FlexDurationPickerMode.hm,
    this.maxDuration = const Duration(days: 365),
    this.pickerHeight = 150,
    this.pickerWidth = 40,
    this.itemExtent = 32,
    this.fontSize = 20,
    this.labelStyle,
    this.separator,
    this.color = Colors.blue,
    this.allowNegative = false,
  }) : assert(controller != null || onDurationChanged != null,
        "Either controller or onDurationChanged must be provided");

  @override
  State<FlexDurationPicker> createState() => _FlexDurationPickerState();
}

class _FlexDurationPickerState extends State<FlexDurationPicker> {
  late FlexDurationPickerController _controller;
  late List<FixedExtentScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FlexDurationPickerController();
    _controller.addListener(_onControllerChanged);
    _initializeScrollControllers();
  }

  void _initializeScrollControllers() {
    _scrollControllers = List.generate(5, (_) => FixedExtentScrollController());
    _updateScrollControllers();
  }

  void _updateScrollControllers() {
    final duration = _controller.duration.abs();
    _scrollControllers[0].jumpToItem(_controller.duration.isNegative ? 1 : 0);
    _scrollControllers[1].jumpToItem(duration.inDays);
    _scrollControllers[2].jumpToItem(duration.inHours % 24);
    _scrollControllers[3].jumpToItem(duration.inMinutes % 60);
    _scrollControllers[4].jumpToItem(duration.inSeconds % 60);
  }

  @override
  void didUpdateWidget(FlexDurationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _controller = widget.controller ?? FlexDurationPickerController();
      _controller.addListener(_onControllerChanged);
      _updateScrollControllers();
    }
  }

  void _onControllerChanged() {
    setState(() {
      _updateScrollControllers();
    });
    widget.onDurationChanged?.call(_controller.duration);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollControllers();
    });

    List<Widget> pickers = [];

    if (widget.allowNegative) {
      pickers.add(_buildSignPicker());
      pickers.add(_addSeparator());
    }

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
      case FlexDurationPickerMode.dhm:
        pickers.addAll([
          _buildDayPicker(),
          _addSeparator(),
          _buildHourPicker(),
          _addSeparator(),
          _buildMinutePicker()
        ]);
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pickers,
    );
  }

  Widget _addSeparator() {
    return (widget.separator ?? const SizedBox(width: 20));
  }

  Widget _buildSignPicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: widget.itemExtent,
          width: widget.itemExtent,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              )),
              backgroundColor: WidgetStatePropertyAll(
                !_controller.duration.isNegative ? widget.color : Colors.grey
              ),
            ),
            onPressed: () {
              _controller.setSign(!_controller.duration.isNegative);
            },
            child: const Text(
              '+',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 8,),
        SizedBox(
          height: widget.itemExtent,
          width: widget.itemExtent,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              )),
              backgroundColor: WidgetStatePropertyAll(
                _controller.duration.isNegative ? widget.color : Colors.grey
              ),
            ),
            onPressed: () {
              _controller.setSign(!_controller.duration.isNegative);
            },
            child: const Text(
              '-',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPicker() => FlexPicker(
        itemCount: 60,
        initialItem: _controller.duration.inSeconds % 60,
        onSelectedItemChanged: (value) => _updateDuration(seconds: value),
        label: 'Sec',
        height: widget.pickerHeight,
        width: widget.pickerWidth,
        itemExtent: widget.itemExtent,
        fontSize: widget.fontSize,
        labelStyle: widget.labelStyle,
        controller: _scrollControllers[4],
        color: widget.color,
      );

  Widget _buildMinutePicker() => FlexPicker(
        itemCount: 60,
        initialItem: _controller.duration.inMinutes % 60,
        onSelectedItemChanged: (value) => _updateDuration(minutes: value),
        label: 'Min',
        height: widget.pickerHeight,
        width: widget.pickerWidth,
        itemExtent: widget.itemExtent,
        fontSize: widget.fontSize,
        labelStyle: widget.labelStyle,
        controller: _scrollControllers[3],
        color: widget.color,
      );

  Widget _buildHourPicker() => FlexPicker(
        itemCount: 24,
        initialItem: _controller.duration.inHours % 24,
        onSelectedItemChanged: (value) => _updateDuration(hours: value),
        label: 'Hr',
        height: widget.pickerHeight,
        width: widget.pickerWidth,
        itemExtent: widget.itemExtent,
        fontSize: widget.fontSize,
        labelStyle: widget.labelStyle,
        controller: _scrollControllers[2],
        color: widget.color,
      );

  Widget _buildDayPicker() => FlexPicker(
        itemCount: widget.maxDuration.inDays + 1,
        initialItem: _controller.duration.inDays,
        onSelectedItemChanged: (value) => _updateDuration(days: value),
        label: 'Day',
        height: widget.pickerHeight,
        width: widget.pickerWidth,
        itemExtent: widget.itemExtent,
        fontSize: widget.fontSize,
        labelStyle: widget.labelStyle,
        controller: _scrollControllers[1],
        color: widget.color,
      );

  void _updateDuration({int? days, int? hours, int? minutes, int? seconds}) {
    var currentDuration = _controller.duration.abs();
    var newDuration = Duration(
      days: days ?? currentDuration.inDays,
      hours: hours ?? currentDuration.inHours % 24,
      minutes: minutes ?? currentDuration.inMinutes % 60,
      seconds: seconds ?? currentDuration.inSeconds % 60,
    );

    // Add one millisecond to reach the exact end of the selected duration
    newDuration += const Duration(milliseconds: 1);

    if (newDuration <= widget.maxDuration) {
      _controller.updateDuration(_controller.duration.isNegative ? -newDuration : newDuration);
    } else {
      // If the new duration exceeds the max duration, reset to max duration
      _controller.updateDuration(_controller.duration.isNegative ? -widget.maxDuration : widget.maxDuration);
      _updateScrollControllers();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}