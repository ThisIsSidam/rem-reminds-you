import 'package:flutter/cupertino.dart';

class DHMSingleDurationPicker extends StatefulWidget {
  const DHMSingleDurationPicker({
    required this.onDurationChanged,
    super.key,
    this.allowNegative = false,
  });
  final void Function(Duration) onDurationChanged;
  final bool allowNegative;

  @override
  State<DHMSingleDurationPicker> createState() =>
      _DHMSingleDurationPickerState();
}

class _DHMSingleDurationPickerState extends State<DHMSingleDurationPicker> {
  late FixedExtentScrollController plusMinusController;
  late FixedExtentScrollController numController;
  late FixedExtentScrollController modeController;

  final List<int> days = List<int>.generate(7, (int i) => i + 1);
  final List<int> hours = List<int>.generate(23, (int i) => i + 1);
  final List<int> minutes = List<int>.generate(59, (int i) => i + 1);

  late List<int> selectedNumList;
  int selectedModeIndex = 1; // Default to hours
  bool isPositive = true; // true for '+', false for '-'

  @override
  void initState() {
    super.initState();
    modeController =
        FixedExtentScrollController(initialItem: selectedModeIndex);
    numController = FixedExtentScrollController();
    plusMinusController = FixedExtentScrollController();
    selectedNumList = hours; // Default to hours
  }

  void updateSelectedNumList(int modeIndex) {
    setState(() {
      selectedModeIndex = modeIndex;
      if (modeIndex == 0) {
        selectedNumList = days;
      } else if (modeIndex == 1) {
        selectedNumList = hours;
      } else {
        selectedNumList = minutes;
      }
      numController.jumpToItem(0); // Reset the num picker position
    });
    updateDuration();
  }

  void updateDuration() {
    final int index = numController.selectedItem;
    if (index < 0 || index >= selectedNumList.length) {
      return; // Prevent out-of-range access
    }

    final int value = selectedNumList[index];
    Duration newDuration;

    switch (selectedModeIndex) {
      case 0:
        newDuration = Duration(days: value);
      case 1:
        newDuration = Duration(hours: value);
      case 2:
        newDuration = Duration(minutes: value);
      default:
        newDuration = Duration.zero;
    }

    if (!isPositive) {
      newDuration = -newDuration;
    }

    widget.onDurationChanged(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        children: <Widget>[
          if (widget.allowNegative) Expanded(child: plusMinusPicker()),
          Expanded(child: numPicker()),
          Expanded(child: modePicker()),
        ],
      ),
    );
  }

  Widget plusMinusPicker() {
    return CupertinoPicker(
      itemExtent: 70,
      scrollController: plusMinusController,
      onSelectedItemChanged: (int i) {
        setState(() {
          isPositive = (i == 0);
        });
        updateDuration();
      },
      children: <Widget>[_buildLabel('+'), _buildLabel('-')],
    );
  }

  Widget numPicker() {
    return CupertinoPicker(
      itemExtent: 70,
      scrollController: numController,
      onSelectedItemChanged: (int i) => updateDuration(),
      looping: true,
      children:
          selectedNumList.map((int e) => _buildLabel(e.toString())).toList(),
    );
  }

  Widget modePicker() {
    return CupertinoPicker(
      itemExtent: 70,
      scrollController: modeController,
      onSelectedItemChanged: updateSelectedNumList,
      children: <Widget>[
        _buildLabel('Days'),
        _buildLabel('Hours'),
        _buildLabel('Minutes'),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Center(
      child: Text(
        text,
      ),
    );
  }
}
