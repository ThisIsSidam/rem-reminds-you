@pragma('vm:entry-point')
int generatedNotificationId(int id) {
  final int minutesSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 60000;
  final String minutes = minutesSinceEpoch.toString();
  final int len = minutes.length;
  return int.parse(id.toString() + minutes.substring(len - 6));
}
