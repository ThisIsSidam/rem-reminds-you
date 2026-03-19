import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/dragged_reminder.dart';

final StateProvider<DraggedReminder?> reminderDraggingProvider =
    StateProvider<DraggedReminder?>((Ref<DraggedReminder?> ref) => null);
