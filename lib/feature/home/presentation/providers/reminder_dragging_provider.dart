import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/model/dragged_reminder.dart';

final StateProvider<DraggedReminder?> reminderDraggingProvider =
    StateProvider<DraggedReminder?>((Ref ref) => null);
