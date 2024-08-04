import 'package:flutter/material.dart';

class FlexPicker extends StatefulWidget {
  final List<Widget>? children;
  final int itemCount;
  final int initialItem;
  final ValueChanged<int> onSelectedItemChanged;
  final String label;
  final int? startValue;
  final double height;
  final double width;
  final double itemExtent;
  final double fontSize;
  final TextStyle? labelStyle;
  final FixedExtentScrollController? controller;
  final bool loop;
  final Color color;

  const FlexPicker({
    Key? key,
    this.children,
    this.itemCount = 0,
    required this.initialItem,
    required this.onSelectedItemChanged,
    this.label = "",
    this.startValue,
    this.height = 150,
    this.width = 70,
    this.itemExtent = 32,
    this.fontSize = 20,
    this.labelStyle,
    this.controller,
    this.loop = true,
    this.color = Colors.blue,
  }) : assert(children != null || itemCount > 0, "Either children or itemCount must be provided"),
       super(key: key);

  @override
  _FlexPickerState createState() => _FlexPickerState();
}

class _FlexPickerState extends State<FlexPicker> {
  late FixedExtentScrollController _scrollController;
  int _selectedItem = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? FixedExtentScrollController(initialItem: widget.initialItem);
    _selectedItem = widget.initialItem;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  int get _effectiveItemCount => widget.children?.length ?? widget.itemCount;

  @override
  Widget build(BuildContext context) {
    final pickerWidget = SizedBox(
      height: widget.height,
      width: widget.width,
      child: _buildVerticalPicker(),
    );

    final labelWidget = Text(
      widget.label,
      style: widget.labelStyle ?? const TextStyle(fontSize: 16),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        pickerWidget,
        labelWidget,
      ],
    );
  }

  Widget _buildVerticalPicker() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _selectedItem = _scrollController.selectedItem % _effectiveItemCount;
          });
        }
        return true;
      },
      child: ListWheelScrollView.useDelegate(
        controller: _scrollController,
        itemExtent: widget.itemExtent,
        perspective: 0.005,
        physics: widget.loop ? null : const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            _selectedItem = index % _effectiveItemCount;
          });
          widget.onSelectedItemChanged(_selectedItem);
        },
        childDelegate: widget.loop
            ? ListWheelChildLoopingListDelegate(children: _generateChildren())
            : ListWheelChildListDelegate(children: _generateChildren()),
      ),
    );
  }

  List<Widget> _generateChildren() {
    if (widget.children != null) {
      return List.generate(_effectiveItemCount, (index) {
        return Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: widget.fontSize,
              color: _selectedItem == index ? widget.color : null,
            ),
            child: widget.children![index],
          ),
        );
      });
    } else {
      return List.generate(_effectiveItemCount, (index) {
        return Center(
          child: Text(
            ((widget.startValue ?? 0) + index).toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: widget.fontSize,
              color: _selectedItem == index ? widget.color : null,
            ),
          ),
        );
      });
    }
  }
}