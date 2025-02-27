interface class ReminderBase {
  ReminderBase({
    required this.id,
    required this.title,
    required this.dateTime,
  });
  int id;
  String title;
  DateTime dateTime;
}

// Not putting anything else here since I only wanted an
// interface so that I can pass both reminder and no-rush
// through the method calls using a single parameter type

// And if I add more types here, I would just have to add
// @override on each in the other class definitions, so I've
// only added those which I am using on ReminderBase instances
