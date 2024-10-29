import 'package:flutter/material.dart';
import 'package:Rem/consts/const_colors.dart';

class SaveCloseButtons extends StatelessWidget {
  final Function() onTapSave;
  final Function()? onTapClose;

  const SaveCloseButtons({super.key, required this.onTapSave, this.onTapClose});

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
                onTapClose == null
                    ? () {
                        Navigator.pop(context);
                      }
                    : onTapClose!,
                ConstColors.lightGrey),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 3,
            child:
                bottomRowButton(context, "Save", onTapSave, ConstColors.blue),
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
        style: Theme.of(context)
            .elevatedButtonTheme
            .style!
            .copyWith(backgroundColor: WidgetStatePropertyAll(color)),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onPressed: onTap,
      ),
    );
  }
}
