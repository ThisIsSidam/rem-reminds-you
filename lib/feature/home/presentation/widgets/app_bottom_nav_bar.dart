import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../app/constants/app_images.dart';
import '../../../../core/extensions/context_ext.dart';

/// An individual item of the [AppBottomNavBar].
/// Supports [AppImages] and [IconData] for icon.
///
/// For [AppImages], pair of fields, [svgIcon] and
/// [selectedSvgIcon] should be provided.
///
/// For [IconData], pair of fields, [icon] and [selectedIcon]
/// should be provided.
class BottomNavItem {
  BottomNavItem({
    required this.label,
    this.svgIcon,
    this.selectedSvgIcon,
    this.icon,
    this.selectedIcon,
    this.iconSize,
  }) : assert(
         (svgIcon != null || selectedSvgIcon != null) ||
             (icon != null && selectedIcon != null),
         'Either svgIcon pair or icon pair should be provided',
       );

  // Fields for using svg files
  final AppSvgs? svgIcon;
  final AppSvgs? selectedSvgIcon;
  final IconData? icon;
  final IconData? selectedIcon;
  final String label;

  /// By default, icons use the size provided in the [AppBottomNavBar] widget.
  /// This value can be used to provide sizes specific to this nav item.
  final double? iconSize;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
    this.isFloating = false,
    this.margin = EdgeInsets.zero,
    this.height = 70,
    this.iconSize = 20,
    this.fontSize = 12,
    this.showLabel = true,
  });

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  /// Whether the bottom nav bar is a floating one (with rounded corners)
  /// or a flat one (bevelled corners).
  final bool isFloating;

  final EdgeInsets margin;

  final double height;
  final double iconSize;
  final double fontSize;

  /// Whether to show the label with the icon
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding =
        (MediaQuery.widthOf(context) / items.length) * 0.08;

    final BottomNavigationBarThemeData navTheme =
        context.theme.bottomNavigationBarTheme;

    return Container(
      margin: margin,
      padding: EdgeInsets.only(top: 4, bottom: context.bottomPadding),
      decoration: BoxDecoration(
        color: context.colors.inversePrimary.withValues(alpha: 0.10),
        borderRadius: isFloating ? BorderRadius.circular(50) : null,
        border: isFloating
            ? Border.all(
                color: context.colors.inversePrimary.withValues(alpha: 0.25),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(items.length, (int index) {
          final bool isSelected = index == selectedIndex;
          final BottomNavItem item = items[index];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(36),
              onTap: () => onItemSelected(index),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: horizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primaryContainer : null,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: showLabel
                    ? _buildItemWithLabel(item, navTheme, isSelected)
                    : _buildIcon(item, navTheme, isSelected),
              ),
            ),
          );
        }),
      ),
    );
  }

  Column _buildItemWithLabel(
    BottomNavItem item,
    BottomNavigationBarThemeData navTheme,
    bool isSelected,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildIcon(item, navTheme, isSelected),
        const SizedBox(height: 4),
        Text(
          item.label,
          style: TextStyle(
            fontSize: fontSize,
            color: isSelected
                ? navTheme.selectedItemColor
                : navTheme.unselectedItemColor,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(
    BottomNavItem item,
    BottomNavigationBarThemeData navTheme,
    bool isSelected,
  ) {
    final Color? color = (isSelected
        ? navTheme.selectedItemColor
        : navTheme.unselectedItemColor);
    if (item.icon != null && item.selectedIcon != null) {
      return Icon(
        isSelected ? item.selectedIcon : item.icon,
        color: color,
        size: item.iconSize ?? iconSize,
      );
    } else if (item.svgIcon != null && item.selectedSvgIcon != null) {
      return SvgPicture.asset(
        (isSelected ? item.selectedSvgIcon! : item.svgIcon!).path,
        height: item.iconSize ?? iconSize,
        width: item.iconSize ?? iconSize,
        colorFilter: ColorFilter.mode(color ?? Colors.black, BlendMode.srcIn),
      );
    } else {
      throw 'Either svgIcons or icons is null';
    }
  }
}
