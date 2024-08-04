import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/utils/flex_picker/flex_duration_picker.dart';
import 'package:flutter/material.dart';

class QuickTimeTableDurationPicker extends StatefulWidget {
  final Duration duration;
  final void Function(Duration) onDurationChanged;
  QuickTimeTableDurationPicker({
    super.key,
    required this.duration,
    required this.onDurationChanged
  });

  @override
  State<QuickTimeTableDurationPicker> createState() => _QuickTimeTableDurationPickerState();
}

class _QuickTimeTableDurationPickerState extends State<QuickTimeTableDurationPicker> {

  late FlexDurationPickerMode selectedMode;
  FlexDurationPickerController durationController = FlexDurationPickerController();
  final negController = FixedExtentScrollController();
  late bool isNegative;

  @override
  void initState() {
    selectedMode = getMode();
    isNegative = widget.duration.isNegative;
    negController.jumpToItem(isNegative ? 1 : 0);
    durationController = FlexDurationPickerController(initialDuration: widget.duration);
    super.initState();
  }

  
  @override
  void didUpdateWidget(QuickTimeTableDurationPicker oldWidget) {
    negController.jumpToItem(isNegative ? 1 : 0);
    durationController = FlexDurationPickerController(initialDuration: widget.duration);
    super.didUpdateWidget(oldWidget);
  }

  FlexDurationPickerMode getMode() {
    final inMinutes = widget.duration.inMinutes;

    if (inMinutes >= 1440 &&inMinutes % 1440 == 0) return FlexDurationPickerMode.d;
    else if (inMinutes >= 60 && inMinutes % 60 == 0) return FlexDurationPickerMode.h;
    else return FlexDurationPickerMode.m;
  }

  void callOnDurationChanged(Duration dur) {
    if (isNegative){
      widget.onDurationChanged(-dur);
    } else {
      widget.onDurationChanged(dur);
    }
  }

  void onNegationValueChanged(int i) {
    final previouslyNegative = isNegative;
    if (i == 0) {
      isNegative = false;
    } else isNegative = true;
    if (previouslyNegative != isNegative) {
      callOnDurationChanged(durationController.duration);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              getModeButton(FlexDurationPickerMode.d),
              SizedBox(width: 8,),
              getModeButton(FlexDurationPickerMode.h),
              SizedBox(width: 8,),
              getModeButton(FlexDurationPickerMode.m),
            ]
          ),
          FlexDurationPicker(
            controller: durationController,
            mode: selectedMode,
            onDurationChanged: callOnDurationChanged,
            allowNegative: true,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(),
        ],
      )
    );
  }

  Widget getModeButton(FlexDurationPickerMode mode, ) {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedMode = mode;
          });
        }, 
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            mode == selectedMode
            ? Theme.of(context).primaryColor
            : ConstColors.lightGrey
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
            )
          ),
        ),
        child: Text(
          mode == FlexDurationPickerMode.d ? "Days" : mode == FlexDurationPickerMode.h ? "Hours" : "Minutes",
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ),
    );
  }
}