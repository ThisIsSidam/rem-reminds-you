import 'package:flutter/material.dart';

import '../../../../core/extensions/context_ext.dart';

Future<void> showWhatsNewSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 5,
    context: context,
    constraints: BoxConstraints(maxHeight: MediaQuery.heightOf(context) * 0.9),
    builder: (BuildContext context) => const WhatsNewSheet(),
  );
}

class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.new_releases_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              context.local.settingsWhatsNew,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildFeatureTile(
                    theme,
                    icon: Icons.view_agenda_outlined,
                    title: 'Introducing Agenda',
                    description:
                        'Plan your daily tasks of the dasy beforehand! '
                        'A persistent interactive notification will keep you '
                        'on track. Simply complete one and move on to the next '
                        'until there are none left',
                  ),
                  _buildFeatureTile(
                    theme,
                    icon: Icons.drag_indicator,
                    title: 'Effortless Reordering',
                    description:
                        'Long-press any reminder tile to drag and drop it '
                        'across sections, effortlessly shifting its scheduled '
                        'time.',
                  ),
                  _buildFeatureTile(
                    theme,
                    icon: Icons.language,
                    title: '¡Hola! Spanish Support',
                    description:
                        'The app now supports Spanish alongside English. '
                        'Translations were provided by AI, so if you spot '
                        'any odd phrasing or wish for another to be added, '
                        'feel free to contribute improvements on our GitHub '
                        'repository!',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.secondary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
