import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../router/app_routes.dart';

part 'generated/initial_screen_provider.g.dart';

@riverpod
class InitialRoute extends _$InitialRoute {
  @override
  AppRoute? build() {
    return null;
  }

  set setRoute(AppRoute newRoute) {
    state = newRoute;
  }
}
