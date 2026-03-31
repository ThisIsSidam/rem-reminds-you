import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/extensions/context_ext.dart';

class SettingTile extends ConsumerWidget {
  const SettingTile({
    required this.title,
    required this.leading,
    this.onTap,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final IconData leading;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: Icon(leading, color: context.colors.primary),
      trailing: trailing,
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }
}
