import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/extensions/context_ext.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  String? description,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) => _ConfirmationDialog(
      title: title,
      description: description,
      key: ValueKey<String>(title),
    ),
  );
}

class _ConfirmationDialog extends HookWidget {
  const _ConfirmationDialog({required this.title, this.description, super.key});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextEditingController controller = useTextEditingController();

    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Text(
          title,
          style: context.texts.titleMedium?.copyWith(fontWeight: .bold),
          overflow: TextOverflow.visible,
        ),
        content: description == null
            ? null
            : Text(
                description!,
                style: context.texts.bodyMedium,
                overflow: TextOverflow.visible,
              ),
        actions: <Widget>[
          Row(
            spacing: 12,
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: colors.onSurface,
                    side: BorderSide(color: colors.outline),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.local.sheetCancel),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, TextEditingValue value, __) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: context.colors.primary,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        context.local.sheetConfirm,
                        style: context.texts.bodyMedium?.copyWith(
                          color: context.colors.onPrimary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
