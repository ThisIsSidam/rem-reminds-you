import 'package:flutter/material.dart';

import '../utils/app_utils.dart';

/// Global method to show [NumInputSheet].
Future<T?> showNumInputSheet<T extends num>(
  BuildContext context, {
  T? value,
  String? hintText,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    shape: const BeveledRectangleBorder(),
    builder: (_) => NumInputSheet<T>(initial: value, hintText: hintText),
  );
}

/// A sheet to enter a [num] type value. Currently supports int and doubles.
class NumInputSheet<T extends num> extends StatefulWidget {
  const NumInputSheet({super.key, this.initial, this.hintText});
  final T? initial;
  final String? hintText;

  @override
  State<NumInputSheet<T>> createState() => _NumInputSheetState<T>();
}

class _NumInputSheetState<T extends num> extends State<NumInputSheet<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: switch (T) {
        double => widget.initial?.toStringAsFixed(2),
        _ => widget.initial?.toString(),
      },
    );
  }

  void onSubmit(BuildContext context) {
    if (T == int) {
      final int? val = int.tryParse(_controller.text);
      Navigator.pop(context, val);
    } else if (T == double) {
      final double? val = double.tryParse(_controller.text);
      Navigator.pop(context, val);
    } else {
      showToast(context, msg: 'Failed to submit!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        4,
        16,
        4 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        onSubmitted: (_) => onSubmit(context),
        decoration: InputDecoration(
          fillColor: Colors.transparent,
          border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          hintText: widget.hintText ?? 'Enter..',
          suffixIcon: IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => onSubmit(context),
          ),
        ),
      ),
    );
  }
}
