import 'package:flutter/material.dart';
import 'package:Rem/consts/const_colors.dart';

class SaveCloseButtons extends StatelessWidget {

  final Function() saveButton;

  const SaveCloseButtons({
    super.key,
    required this.saveButton
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: bottomRowButton(
              context,
              "Close",
              () {
                Navigator.pop(context);
              }, 
              ConstColors.lightGrey
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 3,
            child: bottomRowButton(
              context,
              "Save",
              saveButton,
              ConstColors.blue
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomRowButton(
    BuildContext context,
    String label, 
    void Function() onTap, 
    Color color,
  ) {
    return SizedBox(
      height: 50,
      width: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
          )
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onPressed: onTap,
      ),
    );
  }
}