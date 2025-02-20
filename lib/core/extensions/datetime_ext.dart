import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get dt {
    final DateFormat format = DateFormat('yyyy-MM-dd-HH:mm:ss');
    return format.format(this);
  }
}
