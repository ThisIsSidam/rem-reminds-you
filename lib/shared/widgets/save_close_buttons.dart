import 'package:flutter/material.dart';

import '../../core/extensions/context_ext.dart';

class SaveCloseButtons extends StatelessWidget {
  const SaveCloseButtons({required this.onTapSave, super.key, this.onTapClose});
  final void Function() onTapSave;
  final void Function()? onTapClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton(
                onPressed: onTapClose == null
                    ? () => Navigator.pop(context)
                    : onTapClose!,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondaryContainer,
                ),
                child: const Icon(Icons.close),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton(
                onPressed: onTapSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryContainer,
                ),
                child: Text(
                  'Save',
                  style: context.texts.bodyLarge!.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
