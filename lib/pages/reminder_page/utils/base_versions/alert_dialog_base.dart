import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertDialogBase extends ConsumerWidget {

  final String title;
  final String tooltipMsg;
  final Widget content;
  const AlertDialogBase({
    super.key,
    required this.title,
    required this.tooltipMsg,
    required this.content
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      insetPadding: EdgeInsets.all(16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Tooltip(
            message: tooltipMsg,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.info),
              mouseCursor: MouseCursor.defer,
              enableFeedback: false,
            ),
          ),
        ],
      ),
      content: content,
    );
  }
}