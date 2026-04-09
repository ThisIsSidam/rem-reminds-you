import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/extensions/context_ext.dart';

void showToast(
  BuildContext context, {
  required String msg,
  String? description,
  ToastificationType? type,
  ToastificationStyle? style,
  VoidCallback? onTap,
}) {
  int tapCount = 0; // To stop the action from being initiated twice
  toastification.show(
    context: context,
    alignment: Alignment.topCenter,
    style: style ?? ToastificationStyle.flat,
    showProgressBar: false,
    type: type ?? ToastificationType.info,
    autoCloseDuration: const Duration(seconds: 3),
    title: Text(msg, style: context.texts.titleSmall),
    closeOnClick: true,
    description: description != null
        ? Text(description, style: context.texts.bodySmall)
        : null,
    backgroundColor: context.colors.surfaceContainerHigh,
    foregroundColor: context.colors.onSurface,
    borderSide: BorderSide(color: context.colors.onSurface.withAlpha(150)),
    primaryColor: type == ToastificationType.error
        ? context.colors.error
        : context.colors.primary,
    callbacks: ToastificationCallbacks(
      onTap: (ToastificationItem item) {
        if (tapCount == 0) {
          onTap?.call();
          toastification.dismissById(item.id);
          tapCount++;
        }
      },
    ),
  );
}

Future<void> openUrl(BuildContext context, String url) async {
  try {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  } catch (_) {
    if (!context.mounted) return;
    showToast(context, msg: 'Could not launch url');
  }
}
