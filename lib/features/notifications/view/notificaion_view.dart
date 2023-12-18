import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/features/notifications/widget/notification_tile.dart';
import 'package:twitter_clone/models/notification_model.dart' as model;

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationsProvider(currentUser.uid)).when(
                data: (notifications) {
                  return ref.watch(getLatestNotificationProvider).when(
                        data: (notification) {
                          if (notification.events.contains(
                              "databases.*.collections.${AppWriteConstants.notificationsCollection}.documents.*.create")) {
                            final latestNotification =
                                model.Notification.fromMap(
                                    notification.payload);

                            if (latestNotification.uid == currentUser.uid) {
                              notifications.insert(
                                0,
                                model.Notification.fromMap(
                                    notification.payload),
                              );
                              print(notifications);
                            }
                          }
                          return Expanded(
                            child: ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (BuildContext context, index) {
                                final notification = notifications[index];
                                return NotificationTile(
                                    notification: notification);
                              },
                            ),
                          );
                        },
                        error: (error, st) => ErrorText(
                          error: error.toString(),
                        ),
                        loading: () {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (BuildContext context, index) {
                                final notification = notifications[index];
                                return NotificationTile(
                                    notification: notification);
                              },
                            ),
                          );
                        },
                      );
                },
                error: (error, st) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              ),
    );
  }
}
