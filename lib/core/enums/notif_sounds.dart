enum NotificationSound {
  bell('res_bell');

  const NotificationSound(this.name);

  final String name;

  static NotificationSound get defaultSound => bell;
}
