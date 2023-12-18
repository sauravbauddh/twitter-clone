enum NotificationType { like, reply, follow, retweet }

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.like:
        return 'like';
      case NotificationType.reply:
        return 'reply';
      case NotificationType.follow:
        return 'follow';
      case NotificationType.retweet:
        return 'retweet';
    }
  }

  static NotificationType fromValue(String value) {
    switch (value) {
      case 'like':
        return NotificationType.like;
      case 'reply':
        return NotificationType.reply;
      case 'follow':
        return NotificationType.follow;
      case 'retweet':
        return NotificationType.retweet;
      default:
        throw Exception('Unknown notification type: $value');
    }
  }
}
