import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'initial_screen_provider.g.dart';

@riverpod
class InitialScreenNotifier extends _$InitialScreenNotifier {
  @override
  String? build() {
    return null;
  }

  set setRoute(String newRoute) {
    state = newRoute;
  }
}
