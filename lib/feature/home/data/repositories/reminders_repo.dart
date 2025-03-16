import 'package:objectbox/objectbox.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/entities/no_rush_entitiy/no_rush_entity.dart';
import '../../../../core/data/entities/reminder_entitiy/reminder_entity.dart';
import '../../../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/providers/global_providers.dart';

part 'generated/reminders_repo.g.dart';

@riverpod
class RemindersRepository extends _$RemindersRepository {
  late Box<ReminderEntity> _box;

  @override
  List<ReminderEntity> build() {
    final Store store = ref.watch(objectboxStoreProvider);
    _box = store.box<ReminderEntity>();
    _startListeners();
    return _box.query().build().find();
  }

  void _startListeners() {
    _box
        .query()
        .watch(triggerImmediately: true)
        .map((Query<ReminderEntity> v) => v.find())
        .listen((List<ReminderEntity> v) => state = v);
  }

  int saveReminder(ReminderEntity entity) {
    return _box.put(entity);
  }

  ReminderModel? getReminder(int id) {
    return _box.get(id)?.toModel;
  }

  bool removeReminder(int id) {
    return _box.remove(id);
  }

  String getBackup() => '';
  bool restoreBackup(String json) => true;
}

@riverpod
class NoRushRemindersRepository extends _$NoRushRemindersRepository {
  late Box<NoRushReminderEntity> _box;

  @override
  List<NoRushReminderEntity> build() {
    final Store store = ref.watch(objectboxStoreProvider);
    _box = store.box<NoRushReminderEntity>();
    _startListeners();
    return _box.query().build().find();
  }

  void _startListeners() {
    _box
        .query()
        .watch(triggerImmediately: true)
        .map((Query<NoRushReminderEntity> v) => v.find())
        .listen((List<NoRushReminderEntity> v) => state = v);
  }

  int saveReminder(NoRushReminderEntity entity) {
    return _box.put(entity);
  }

  NoRushReminderModel? getReminder(int id) {
    return _box.get(id)?.toModel;
  }

  bool removeReminder(int id) {
    return _box.remove(id);
  }

  String getBackup() => '';
  bool restoreBackup(String json) => true;
}
// class RemindersDatabaseController {
//   static final Box<ReminderModel> _box = Hive.box<ReminderModel>(
//     HiveBoxNames.reminders.name,
//   );

//   static Map<int, ReminderModel> getReminders() {
//     if (!_box.isOpen) {
//       Future<void>(() {
//         Hive.openBox<ReminderModel>(HiveBoxNames.reminders.name);
//       });
//     }

//     return Map<int, ReminderModel>.fromEntries(
//       _box.keys.map(
//         (dynamic key) =>
//             MapEntry<int, ReminderModel>(key as int, _box.get(key)!),
//       ),
//     );
//   }

//   static Future<void> removeReminder(int id) async {
//     await _box.delete(id);
//   }

//   static Future<void> saveReminder(int id, ReminderModel reminder) async {
//     _box.put(id, reminder);
//   }

//   static Future<void> updateReminders(
//     Map<int, ReminderModel> reminders,
//   ) async {
//     for (final MapEntry<int, ReminderModel> entry in reminders.entries) {
//       _box.put(entry.key, entry.value);
//     }
//   }

//   static Future<void> removeAllReminders() async {
//     await _box.clear();
//   }

//   static Future<String> getBackup() async {
//     final Map<int, ReminderModel> reminders = getReminders();
//     final Map<String, dynamic> backupData = <String, dynamic>{
//       'reminders': reminders.map(
//         (int id, ReminderModel reminder) =>
//             MapEntry<String, Map<String, String?>>(
//           id.toString(),
//           reminder.toJson(),
//         ),
//       ),
//       'timestamp': DateTime.now().toIso8601String(),
//       'version': '1.0',
//     };
//     return jsonEncode(backupData);
//   }

//   static Future<void> restoreBackup(String jsonData) async {
//     try {
//       final Map<String, dynamic> backupData =
//           jsonDecode(jsonData) as Map<String, dynamic>;
//       final Map<String, dynamic> remindersData =
//           backupData['reminders'] as Map<String, dynamic>;

//       final Map<int, ReminderModel> reminders = <int, ReminderModel>{};
//       remindersData.forEach((String key, dynamic value) {
//         final int id = int.parse(key);
//         reminders[id] = ReminderModel.fromJson(
//           Map<String, String?>.from(value as Map<dynamic, dynamic>),
//         );
//       });

//       await removeAllReminders();
//       await updateReminders(reminders);
//     } catch (e) {
//       throw Exception('Failed to restore backup: $e');
//     }
//   }
// }
