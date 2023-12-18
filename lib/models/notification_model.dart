import 'package:twitter_clone/core/enums/notification_type_enum.dart';

class Notification {
  final String text;
  final String postId;
  final String id;
  final String uid;
  final NotificationType notificationType;

  Notification({
    required this.text,
    required this.postId,
    required this.id,
    required this.uid,
    required this.notificationType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          postId == other.postId &&
          id == other.id &&
          uid == other.uid &&
          notificationType == other.notificationType);

  @override
  int get hashCode =>
      text.hashCode ^
      postId.hashCode ^
      id.hashCode ^
      uid.hashCode ^
      notificationType.hashCode;

  @override
  String toString() {
    return 'Notification{ text: $text, postId: $postId, id: $id, uid: $uid, notificationType: $notificationType,}';
  }

  Notification copyWith({
    String? text,
    String? postId,
    String? id,
    String? uid,
    NotificationType? notificationType,
  }) {
    return Notification(
      text: text ?? this.text,
      postId: postId ?? this.postId,
      id: id ?? this.id,
      uid: uid ?? this.uid,
      notificationType: notificationType ?? this.notificationType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'postId': postId,
      'uid': uid,
      'notificationType': notificationType.value, // Convert to string
    };
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      text: map['text'].toString(),
      postId: map['postId'].toString(),
      id: map['\$id'].toString(),
      uid: map['uid'].toString(),
      notificationType: NotificationTypeExtension.fromValue(
          map['notificationType'] as String),
    );
  }
}
