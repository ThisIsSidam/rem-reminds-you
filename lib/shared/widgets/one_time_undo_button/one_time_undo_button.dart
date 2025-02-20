import 'package:flutter/material.dart';

/// Creates a [TextButton] with 'Undo' text in primary color.
/// The button performs [onPressed] action.
/// The button runs only once.
///
/// Is used because in [HomeScreenLists], the correct context is not being
/// sent and hence the [ScaffoldMessenger.of(context).hideCurrentSnackBar()]
/// is not working. This is a temporary solution for not letting the button
/// being pressed multiple times.
class OneTimeUndoButton extends StatefulWidget {
  const OneTimeUndoButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  State<OneTimeUndoButton> createState() => _OneTimeUndoButtonState();
}

class _OneTimeUndoButtonState extends State<OneTimeUndoButton> {
  bool hasBeenPressed = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: hasBeenPressed
          ? null
          : () {
              setState(() {
                hasBeenPressed = true;
                widget.onPressed();
              });
            },
      child: Text(
        'Undo',
        style: TextStyle(
          fontSize: 16,
          color: hasBeenPressed
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
