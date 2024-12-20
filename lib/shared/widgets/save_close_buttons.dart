import 'package:flutter/material.dart';

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
            child: SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton(
                  child: Text(
                    'Close',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                  onPressed: onTapClose == null
                      ? () {
                          Navigator.pop(context);
                        }
                      : onTapClose!,
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer)),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 50,
              width: 100,
              child: ElevatedButton(
                child: Text(
                  'Save',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                onPressed: onTapSave,
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
