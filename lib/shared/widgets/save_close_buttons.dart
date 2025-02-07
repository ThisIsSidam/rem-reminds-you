import 'package:flutter/material.dart';

class SaveCloseButtons extends StatelessWidget {
  const SaveCloseButtons({required this.onTapSave, super.key, this.onTapClose});
  final void Function() onTapSave;
  final void Function()? onTapClose;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton(
                onPressed: onTapClose == null
                    ? () {
                        Navigator.pop(context);
                      }
                    : onTapClose!,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Text(
                  'Close',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton(
                onPressed: onTapSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Text(
                  'Save',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
