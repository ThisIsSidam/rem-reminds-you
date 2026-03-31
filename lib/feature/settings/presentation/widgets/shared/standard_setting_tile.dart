import 'package:flutter/material.dart';

import '../../../../../../core/extensions/context_ext.dart';

class StandardSettingTile extends StatelessWidget {
  const StandardSettingTile({
    required this.leading,
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.contentPadding,
    this.onTap,
  });

  final IconData leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(leading, color: context.colors.primary),
      title: Text(title, style: context.texts.titleMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: context.texts.bodySmall)
          : null,
      trailing: trailing,
      contentPadding: contentPadding,
      onTap: onTap,
    );
  }
}
