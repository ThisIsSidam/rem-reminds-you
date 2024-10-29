import 'package:Rem/widgets/whats_new_dialog/whats_new_dialog.dart';
import 'package:flutter/material.dart';

class OtherSection extends StatelessWidget {
  const OtherSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Other",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.white),
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              _buildWhatsNewTile(context),
              SizedBox(height: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWhatsNewTile(BuildContext context) {
    return ExpansionTile(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "What's New?",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        children: WhatsNewDialog.getWhatsNewTileContent(context));
  }
}
