import 'package:Rem/provider/text_scale_notifier.dart';
import 'package:Rem/screens/settings_screen/widgets/user_preferences_section/setting_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPreferenceSection extends StatelessWidget {
  const UserPreferenceSection({
    super.key,
    required this.refreshPage
  });

  final void Function() refreshPage;

  @override
  Widget build(BuildContext context) {

    final settingTiles = SettingTiles(
      context: context,
      refreshPage: refreshPage
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Preferences",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white
            ),
          ),
          SizedBox(height: 5),
          Column(
            children: [
              SizedBox(height: 10),
              settingTiles.getTitleParsingOption(),
              SizedBox(height: 10),
              settingTiles.getSlideToLeftActionsSetting(),
              SizedBox(height: 10,),
              settingTiles.getSlideToRightActionsSetting(),
              SizedBox(height: 10),
              _buildTextScaleSetting(context),
              SizedBox(height: 20,),
            ],
          )
        ],
      ), 
    );
  }

  Widget _buildTextScaleSetting(BuildContext context) {
    return ListTile(
      title: Text(
        'Text Scale',
        style: Theme.of(context).textTheme.titleSmall
      ),
      subtitle: Row(
        children: [
          Text('A', style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
            child: Consumer(
              builder: (context, ref, chid) {
                final textScaleNotifier = ref.watch(textScaleProvider);
                return StatefulBuilder(
                  builder: (context, setState) {
                    final List<double> _scaleValues = [
                      0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4
                    ];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_scaleValues.length, (index) => 
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                debugPrint("setStaet Called");
                                textScaleNotifier.changeTextScale(_scaleValues[index]);
                              });
                            },
                            child: SizedBox(
                              width: 8 * _scaleValues[index],
                              height: 8 * _scaleValues[index],
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: textScaleNotifier.textScale == _scaleValues[index]
                                    ? Theme.of(context).primaryColor 
                                    : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      )
                    );
                  }
                );
              }
            ),
          ),
          const SizedBox(width: 10),
          Text('A', style: TextStyle(color: Colors.white, fontSize: 24)),
        ],
      ),
    );
  }
}