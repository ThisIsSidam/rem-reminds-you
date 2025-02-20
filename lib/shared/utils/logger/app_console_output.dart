import 'package:logger/logger.dart';

/// Same as [ConsoleOutput] class of [Logger]
/// Only diff is that it adds restriction and
/// only prints warning and above level logs.
class AppConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (event.level.index >= Level.warning.index) {
      // ignore: avoid_print
      event.lines.forEach(print);
    }
  }
}
