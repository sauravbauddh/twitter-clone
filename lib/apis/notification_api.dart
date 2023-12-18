import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/providers.dart';
import 'package:twitter_clone/models/notification_model.dart';

abstract class INotificationAPI {
  FutureEitherVoid createNotification(Notification notification);
  Future<List<Document>> getNotifications(String uid);
  Stream<RealtimeMessage> getLatestNotifications();
}

final notificationAPIProvider = Provider((ref) {
  return NotificationAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtimeNotification: ref.watch(appwriteRealtimeProviderForNotifications),
  );
});

class NotificationAPI implements INotificationAPI {
  final Databases _db;
  final Realtime _realtimeNotification;

  NotificationAPI({required Databases db, required realtimeNotification})
      : _db = db,
        _realtimeNotification = realtimeNotification;

  @override
  FutureEitherVoid createNotification(Notification notification) async {
    try {
      await _db.createDocument(
          databaseId: AppWriteConstants.databaseId,
          collectionId: AppWriteConstants.notificationsCollection,
          documentId: ID.unique(),
          data: notification.toMap());
      return right(null);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? "Unexpected error occurred", st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getNotifications(String uid) async {
    final docs = await _db.listDocuments(
      databaseId: AppWriteConstants.databaseId,
      collectionId: AppWriteConstants.notificationsCollection,
      queries: [
        Query.equal("uid", uid),
      ],
    );
    return docs.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestNotifications() {
    return _realtimeNotification.subscribe(
      [
        "databases.${AppWriteConstants.databaseId}.collections.${AppWriteConstants.tweetsCollection}.documents"
      ],
    ).stream;
  }
}
