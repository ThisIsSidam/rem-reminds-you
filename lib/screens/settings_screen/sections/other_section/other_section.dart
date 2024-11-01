import 'package:Rem/widgets/whats_new_dialog/whats_new_dialog.dart';
import 'package:flutter/material.dart';

class OtherSection extends StatelessWidget {
  const OtherSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading:
              Icon(Icons.devices_other_outlined, color: Colors.transparent),
          title: Text(
            "Other",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: 5),
        Column(
          children: [
            _buildWhatsNewTile(context),
          ],
        )
      ],
    );
  }

  Widget _buildWhatsNewTile(BuildContext context) {
    return ExpansionTile(
        leading: Icon(Icons.new_releases_outlined),
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "What's New?",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: WhatsNewDialog.getWhatsNewTileContent(context));
  }
}
