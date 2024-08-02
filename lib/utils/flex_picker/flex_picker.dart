import 'package:flutter/material.dart';

enum PickerOrientation { vertical, horizontal }

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
  final PickerOrientation orientation;
  final FixedExtentScrollController? controller;
  final bool loop;

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
    this.orientation = PickerOrientation.vertical,
    this.controller,
    this.loop = true,
  }) : assert(children != null || itemCount > 0, "Either children or itemCount must be provided"),
       super(key: key);

  @override
  _FlexPickerState createState() => _FlexPickerState();
}

class _FlexPickerState extends State<FlexPicker> {
  late FixedExtentScrollController _scrollController;
  late PageController _horizontalPageController;
  late int _currentHorizontalPage;
  int _selectedItem = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? FixedExtentScrollController(initialItem: widget.initialItem);
    _selectedItem = widget.initialItem;
    _currentHorizontalPage = widget.initialItem + (widget.loop ? 10000 * _effectiveItemCount : 0);
    _horizontalPageController = PageController(
      initialPage: _currentHorizontalPage,
      viewportFraction: 1 / 5,
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    _horizontalPageController.dispose();
    super.dispose();
  }

  int get _effectiveItemCount => widget.children?.length ?? widget.itemCount;

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
        diameterRatio: 1.2,
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

  Widget _buildHorizontalPicker() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          final currentPage = _horizontalPageController.page!.round();
          if (currentPage != _currentHorizontalPage) {
            setState(() {
              _currentHorizontalPage = currentPage;
              _selectedItem = _currentHorizontalPage % _effectiveItemCount;
              widget.onSelectedItemChanged(_selectedItem);
            });
          }
        }
        return true;
      },
      child: PageView.builder(
        controller: _horizontalPageController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final itemIndex = index % _effectiveItemCount;
          return Center(
            child: _generateChildren()[itemIndex],
          );
        },
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
              color: _selectedItem == index ? Colors.blue : null,
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
              color: _selectedItem == index ? Colors.blue : null,
            ),
          ),
        );
      });
    }
  }
}