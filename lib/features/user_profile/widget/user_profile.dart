import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/constants/asset_constants.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/features/user_profile/view/edit_profile_view.dart';
import 'package:twitter_clone/features/user_profile/widget/follow_count.dart';
import 'package:twitter_clone/models/user_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

import '../controller/user_profile_controller.dart';

class UserProfile extends ConsumerWidget {
  final UserModel userModel;
  const UserProfile({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const Loader() // Replace with your Loader widget
        : Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, isInnerBoxScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: userModel.bannerPic.isEmpty
                              ? Container(
                                  color: Pallete.blueColor,
                                )
                              : Image.network(
                                  userModel.bannerPic,
                                  fit: BoxFit.fitWidth,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: userModel.profilePic.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userModel.profilePic),
                                    radius: 40,
                                  )
                                : const CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(AssetsConstants.userIcon),
                                    radius: 40,
                                  ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.bottomRight,
                          child: OutlinedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              side: const BorderSide(color: Pallete.whiteColor),
                            ),
                            onPressed: () {
                              if (currentUser.uid == userModel.uid) {
                                Navigator.push(
                                    context, EditProfileView.route());
                              } else {
                                ref
                                    .read(
                                        userProfileControllerProvider.notifier)
                                    .followUser(
                                      user: userModel,
                                      context: context,
                                      currentUser: currentUser,
                                    );
                              }
                            },
                            child: Text(
                              currentUser.uid != userModel.uid
                                  ? currentUser.following
                                          .contains(userModel.uid)
                                      ? "Unfollow"
                                      : "Follow"
                                  : "Edit Profile",
                              style: const TextStyle(color: Pallete.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Row(
                            children: [
                              Text(
                                userModel.name,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (userModel.isTwitterBlue)
                                Padding(
                                  padding: const EdgeInsets.only(left: 3.0),
                                  child: SvgPicture.asset(
                                      AssetsConstants.verifiedIcon),
                                )
                            ],
                          ),
                          Text(
                            "@${userModel.name}",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Pallete.greyColor,
                            ),
                          ),
                          Text(
                            userModel.bio,
                            style: const TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              FollowCount(
                                  count: userModel.followers.length,
                                  text: "Followers"),
                              const SizedBox(
                                width: 15,
                              ),
                              FollowCount(
                                  count: userModel.following.length,
                                  text: "Following"),
                            ],
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          const Divider(
                            color: Pallete.whiteColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: ref.watch(getUserTweetsProvider(userModel.uid)).when(
                    data: (tweets) {
                      return ListView.builder(
                        itemCount: tweets.length,
                        itemBuilder: (BuildContext context, index) {
                          final tweet = tweets[index];
                          return TweetCard(tweet: tweet);
                        },
                      );
                    },
                    error: (error, st) => ErrorText(error: error.toString()),
                    loading: () => const Loader(),
                  ),
            ),
          );
  }
}
