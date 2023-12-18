import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/storage_api.dart';
import 'package:twitter_clone/apis/tweet_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/enums/notification_type_enum.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/notifications/controller/notification_controller.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/models/user_model.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>(
  (ref) {
    return UserProfileController(
      tweetAPI: ref.watch(tweetAPIProvider),
      storageAPI: ref.watch(storageAPIProvider),
      userAPI: ref.watch(userAPIProvider),
      notificationController:
          ref.watch(notificationControllerProvider.notifier),
    );
  },
);

final getUserTweetsProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
      ref.watch(userProfileControllerProvider.notifier);
  return userProfileController.getUserTweets(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final StorageAPI _storageAPI;
  final UserAPI _userAPI;
  final NotificationController _notificationController;

  UserProfileController(
      {required TweetAPI tweetAPI,
      required StorageAPI storageAPI,
      required NotificationController notificationController,
      required UserAPI userAPI})
      : _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _userAPI = userAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getUserTweets(String uid) async {
    final tweets = await _tweetAPI.getUserTweets(uid);
    return tweets.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  Future<void> updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required File? bannerFile,
    required File? profileFile,
  }) async {
    state = true;
    if (bannerFile != null) {
      final bannerURL = await _storageAPI.uploadImages([bannerFile]);
      print(bannerURL[0]);
      userModel = userModel.copyWith(bannerPic: bannerURL[0]);
    }
    if (profileFile != null) {
      final profileURL = await _storageAPI.uploadImages([profileFile]);
      print(profileURL[0]);
      userModel = userModel.copyWith(profilePic: profileURL[0]);
    }
    final res = await _userAPI.updateUserData(userModel);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Navigator.pop(context),
    );
  }

  Future<void> followUser(
      {required UserModel user,
      required BuildContext context,
      required UserModel currentUser}) async {
    //already following the user
    if (currentUser.following.contains(user.uid)) {
      user.followers.remove(currentUser.uid);
      currentUser.following.remove(user.uid);
    } else {
      user.followers.add(currentUser.uid);
      currentUser.following.add(user.uid);
    }
    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(following: currentUser.following);
    final res = await _userAPI.followUser(user);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        final res2 = await _userAPI.addToFollowing(currentUser);
        res2.fold(
          (l) => showSnackBar(context, l.message),
          (r) => _notificationController.createNotification(
              text: "${currentUser.name} followed you!",
              postId: "",
              notificationType: NotificationType.follow,
              uid: user.uid),
        );
      },
    );
  }
}