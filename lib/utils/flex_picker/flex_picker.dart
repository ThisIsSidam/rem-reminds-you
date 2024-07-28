import 'package:flutter/material.dart';

enum PickerOrientation { vertical, horizontal }

class FlexPicker extends StatefulWidget {
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
  final PickerOrientation orientation;

  const FlexPicker({
    Key? key,
    required this.itemCount,
    required this.initialItem,
    required this.onSelectedItemChanged,
    required this.label,
    this.startValue,
    this.height = 150,
    this.width = 70,
    this.itemExtent = 32,
    this.fontSize = 20,
    this.labelStyle,
    this.orientation = PickerOrientation.vertical,
  }) : super(key: key);

  @override
  _FlexPickerState createState() => _FlexPickerState();
}

class _FlexPickerState extends State<FlexPicker> {
  late int _selectedItem;
  late FixedExtentScrollController _verticalScrollController;
  late PageController _horizontalPageController;
  late int _currentHorizontalPage;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem;
    _verticalScrollController = FixedExtentScrollController(initialItem: widget.initialItem);
    _currentHorizontalPage = widget.initialItem + 10000 * widget.itemCount;
    _horizontalPageController = PageController(
      initialPage: _currentHorizontalPage,
      viewportFraction: 1 / 5,
    );
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pickerWidget = SizedBox(
      height: widget.orientation == PickerOrientation.vertical ? widget.height : widget.width,
      width: widget.orientation == PickerOrientation.vertical ? widget.width : widget.height,
      child: widget.orientation == PickerOrientation.vertical
          ? _buildVerticalPicker()
          : _buildHorizontalPicker(),
    );

    final labelWidget = Text(
      widget.label,
      style: widget.labelStyle ?? const TextStyle(fontSize: 16),
    );

    if (widget.orientation == PickerOrientation.vertical) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          pickerWidget,
          labelWidget,
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          pickerWidget,
          labelWidget,
        ],
      );
    }
  }

  Widget _buildVerticalPicker() {
    return ListWheelScrollView.useDelegate(
      controller: _verticalScrollController,
      itemExtent: widget.itemExtent,
      perspective: 0.005,
      diameterRatio: 1.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedItem = index;
        });
        widget.onSelectedItemChanged(index);
      },
      childDelegate: ListWheelChildLoopingListDelegate(
        children: List<Widget>.generate(
          widget.itemCount,
          (index) => Center(
            child: Text(
              ((widget.startValue ?? 0) + index % widget.itemCount).toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: widget.fontSize,
                color: _selectedItem == index ? Colors.blue : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalPicker() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          final currentPage = _horizontalPageController.page!.round();
          if (currentPage != _currentHorizontalPage) {
            setState(() {
              _currentHorizontalPage = currentPage;
              _selectedItem = _currentHorizontalPage % widget.itemCount;
            });
            widget.onSelectedItemChanged(_selectedItem);
          }
        }
        return true;
      },
      child: PageView.builder(
        controller: _horizontalPageController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final itemIndex = index % widget.itemCount;
          return Center(
            child: Text(
              ((widget.startValue ?? 0) + itemIndex).toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: widget.fontSize,
                color: _currentHorizontalPage % widget.itemCount == itemIndex ? Colors.blue : null,
              ),
            ),
          );
        },
      ),
    );
  }
}