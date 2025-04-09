// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';

import '../../utils/logger/global_logger.dart';

class WhatsNewDialog extends StatelessWidget {
  const WhatsNewDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    gLogger.i("Showing what's new dialog");
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: ListTile(
          leading: const Icon(Icons.new_releases_outlined),
          title: Text(
            "What's New",
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 12,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  'Fixed the issue where reminder notifications for recurring reminders were not working.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.music_note, size: 12),
                title: Text(
                  'Note: If in case you are not getting the new notification sound added, try reinstalling the app. The backup & restore can help you in that.',
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
