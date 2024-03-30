import 'package:flutter/material.dart';
import 'package:nagger/consts/const_colors.dart';
import 'package:nagger/utils/other_utils/snack_bar.dart';

/// The 'Normal' and 'Routine Reminders' buttons placed exactly below
/// the app bar in reminderPage.
class SectionButtons extends StatefulWidget {
  const SectionButtons({
    super.key,
  });

  @override
  State<SectionButtons> createState() => _SectionButtonsState();
}

enum SectionType {Normal, Infinite}

class _SectionButtonsState extends State<SectionButtons> {
  SectionType _currentSection = SectionType.Normal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16, left: 16, right: 16
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: sectionButton("Normal", SectionType.Normal)
          ),
          SizedBox(width: 10,),
          Expanded(
            child: sectionButton("Routine Reminders", SectionType.Infinite)
          )
        ],
      ),
    );
  }

  Widget sectionButton(String label, SectionType type) {
    return GestureDetector(
      onTap: () {
        if (type == SectionType.Infinite)
        {
          showSnackBar(context, "Coming soon!");
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: type == _currentSection 
            ? Theme.of(context).primaryColor 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: type == _currentSection ? Colors.transparent : ConstColors.lightGrey,
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: Colors.white
          ),
       ),
      )
    );
  }
}