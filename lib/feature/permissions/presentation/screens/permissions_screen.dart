import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/constants/app_images.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../../app_startup/presentation/providers/app_startup_provider.dart';
import '../../domain/app_permi_handler.dart';
import '../providers/permission_status_provider.dart';
import '../widgets/permission_bottom_actions.dart';

/// Each value represents a page in the permission screen.
/// Their order is NOT RANDOM, DO NOT CHANGE.
enum PermissionPage { notification, alarm, battery }

/// A screen for showing which permissions app requires and for what.
/// Has elements to request such permissions.
class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late final ValueNotifier<PermissionPage> _currentPage;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _currentPage = ValueNotifier<PermissionPage>(PermissionPage.notification);
    super.initState();
  }

  /// Invalidates the [appStartupProvider], causing it to
  /// reassess situation. If permissions are present, it would
  /// open [HomeScreen] then..
  void _goToHome() => Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoute.splash.name,
    (Route<dynamic> route) => false,
  );

  /// Moves the [_pageController] to next permission page.
  void _goToPage(PermissionPage page) {
    _currentPage.value = page;
    _pageController.animateToPage(
      page.index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppLogger.i('LifecycleState resumed | Rebuilding permissions screen');

      // If not already on the current page as in state in _currentPage,
      // jump to it.
      if (_pageController.page == _currentPage.value.index) {
        _pageController.jumpToPage(_currentPage.value.index);
      }
      ref.invalidate(permissionProvider);
    }
  }

  /// Whether the required permission is granted for the page.
  Future<bool> _isRequiredPermissionGrantedForPage(PermissionPage page) {
    switch (page) {
      case PermissionPage.notification:
        return AwesomeNotifications().isNotificationAllowed();
      case PermissionPage.alarm:
        return AppPermissionHandler.checkAlarmPermission();
      case PermissionPage.battery:
        return Future<bool>.value(true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.i('Build permissions screen');
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (int page) async {
                  final PermissionPage previous = _currentPage.value;
                  final PermissionPage next = PermissionPage.values[page];

                  // Prevent swiping forward unless the current required
                  // permission is granted.
                  if (page > previous.index) {
                    final bool hasPermission =
                        await _isRequiredPermissionGrantedForPage(previous);
                    if (!hasPermission) {
                      await _pageController.animateToPage(
                        previous.index,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                      return;
                    }
                  }

                  _currentPage.value = next;
                },
                children: <Widget>[
                  _buildNotificationSection(context),
                  _buildAlarmPermissionSection(context),
                  _buildBatterySection(context),
                ],
              ),
            ),
            _buildPageIndicator(),
            const SizedBox(height: 16),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return ValueListenableBuilder<PermissionPage>(
      valueListenable: _currentPage,
      builder: (_, PermissionPage currentPage, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(PermissionPage.values.length, (
            int i,
          ) {
            final double size = i == currentPage.index ? 12 : 8;
            return Container(
              width: size,
              height: size,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == currentPage.index ? Colors.white : Colors.grey,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    final double bottomPadding = 8 + MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 0, 32, bottomPadding),
      child: ValueListenableBuilder<PermissionPage>(
        valueListenable: _currentPage,
        builder:
            (BuildContext context, PermissionPage currentPage, Widget? child) {
              return PermissionBottomActions(
                key: ValueKey<String>('permission-$currentPage-bottom-section'),
                currentPage: currentPage,
                onContinue: () {
                  switch (currentPage) {
                    case PermissionPage.notification:
                      _goToPage(PermissionPage.alarm);
                    case PermissionPage.alarm:
                      _goToPage(PermissionPage.battery);
                    case PermissionPage.battery:
                      _goToHome();
                  }
                },
              );
            },
      ),
    );
  }

  Padding _buildNotificationSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            AppSvgs.notification.path,
            height: 150,
            width: 150,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: context.local.permissionNotificationTitle,
                  style: context.texts.titleMedium,
                ),
                TextSpan(
                  text: context.local.permissionRequired,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Text(
            context.local.permissionNotificationDescription,
            style: context.texts.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAlarmPermissionSection(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(AppSvgs.alarmClock.path, height: 150, width: 150),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: context.local.permissionAlarmTitle,
                    style: context.texts.titleMedium,
                  ),
                  TextSpan(
                    text: context.local.permissionRequired,
                    style: context.texts.bodySmall!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              context.local.permissionAlarmDescription,
              style: context.texts.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBatterySection(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              AppSvgs.batteryWarning.path,
              height: 150,
              width: 150,
            ),
            Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: context.local.permissionBatteryTitle,
                    style: context.texts.titleMedium,
                  ),
                  TextSpan(
                    text: context.local.permissionRecommended,
                    style: context.texts.bodySmall!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              context.local.permissionBatteryDescription,
              style: context.texts.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
