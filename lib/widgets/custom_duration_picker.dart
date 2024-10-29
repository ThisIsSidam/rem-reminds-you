import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDurationPicker extends StatefulWidget {
  final void Function(Duration) onDurationChanged;
  final bool allowNegative;
  const CustomDurationPicker(
      {Key? key, required this.onDurationChanged, this.allowNegative = false})
      : super(key: key);

  @override
  State<CustomDurationPicker> createState() => _CustomDurationPickerState();
}

class _CustomDurationPickerState extends State<CustomDurationPicker> {
  late FixedExtentScrollController plusMinusController;
  late FixedExtentScrollController numController;
  late FixedExtentScrollController modeController;

  final List<int> days = List.generate(7, (i) => i + 1);
  final List<int> hours = List.generate(23, (i) => i + 1);
  final List<int> minutes = List.generate(59, (i) => i + 1);

  late List<int> selectedNumList;
  int selectedModeIndex = 1; // Default to hours
  bool isPositive = true; // true for '+', false for '-'

  @override
  void initState() {
    super.initState();
    modeController =
        FixedExtentScrollController(initialItem: selectedModeIndex);
    numController = FixedExtentScrollController(initialItem: 0);
    plusMinusController = FixedExtentScrollController(initialItem: 0);
    selectedNumList = hours; // Default to hours
  }

  void updateSelectedNumList(int modeIndex) {
    setState(() {
      selectedModeIndex = modeIndex;
      if (modeIndex == 0)
        selectedNumList = days;
      else if (modeIndex == 1)
        selectedNumList = hours;
      else
        selectedNumList = minutes;
      numController.jumpToItem(0); // Reset the num picker position
    });
    updateDuration();
  }

  void updateDuration() {
    int index = numController.selectedItem;
    if (index < 0 || index >= selectedNumList.length) {
      return; // Prevent out-of-range access
    }

    int value = selectedNumList[index];
    Duration newDuration;

    switch (selectedModeIndex) {
      case 0:
        newDuration = Duration(days: value);
        break;
      case 1:
        newDuration = Duration(hours: value);
        break;
      case 2:
        newDuration = Duration(minutes: value);
        break;
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
      child: Row(children: [
        if (widget.allowNegative) Expanded(child: plusMinusPicker()),
        Expanded(child: numPicker()),
        Expanded(child: modePicker())
      ]),
    );
  }

  Widget plusMinusPicker() {
    return CupertinoPicker(
        itemExtent: 32,
        scrollController: plusMinusController,
        onSelectedItemChanged: (i) {
          setState(() {
            isPositive = (i == 0);
          });
          updateDuration();
        },
        children: [whiteText("+"), whiteText("-")]);
  }

  Widget numPicker() {
    return CupertinoPicker(
      itemExtent: 32,
      scrollController: numController,
      onSelectedItemChanged: (i) => updateDuration(),
      children: selectedNumList.map((e) => whiteText(e.toString())).toList(),
      looping: true,
    );
  }

  Widget modePicker() {
    return CupertinoPicker(
        itemExtent: 32,
        scrollController: modeController,
        onSelectedItemChanged: updateSelectedNumList,
        children: [
          whiteText("Days"),
          whiteText("Hours"),
          whiteText("Minutes")
        ]);
  }

  Widget whiteText(String str) {
    return Text(str, style: Theme.of(context).textTheme.titleLarge);
  }
}
