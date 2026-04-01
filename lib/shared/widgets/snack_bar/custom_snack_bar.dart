import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static void showToast({
    required String msg,
    String? description,
    ToastificationType? type,
    ToastificationStyle? style,
    VoidCallback? onTap,
  }) {
    int tapCount = 0; // To stop the action from being initiated twice
    toastification.show(
      alignment: Alignment.topCenter,
      style: style,
      showProgressBar: false,
      type: type,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(msg),
      closeOnClick: true,
      description: description != null ? Text(description) : null,
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

  static Future<void> openUrl(String url) async {
    try {
      if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
    } catch (_) {
      AppUtils.showToast(msg: 'Could not launch url');
    }
  }
}
