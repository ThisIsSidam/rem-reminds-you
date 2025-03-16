import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'generated/global_providers.g.dart';

// SharedPreferences provider
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((Ref<SharedPreferences> ref) {
  throw UnimplementedError();
});

@riverpod
Store objectboxStore(Ref ref) {
  throw UnimplementedError('Objectbox store has not been created yet!');
}
