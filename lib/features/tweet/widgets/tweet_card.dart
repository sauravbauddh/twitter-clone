import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/constants/asset_constants.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/view/twitter_reply_view.dart';
import 'package:twitter_clone/features/tweet/widgets/carousel_image.dart';
import 'package:twitter_clone/features/tweet/widgets/hastag_text.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_icon_button.dart';
import 'package:twitter_clone/features/user_profile/view/user_profile_view.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

class TweetCard extends ConsumerWidget {
  final Tweet tweet;
  const TweetCard({super.key, required this.tweet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? const SizedBox()
        : ref.watch(userDetailsProvider(tweet.uid)).when(
            data: (user) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, TwitterReplyView.route(tweet));
                },
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                UserProfileView.route(user),
                              );
                            },
                            child: user.profilePic.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.profilePic),
                                    radius: 35,
                                  )
                                : const CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      AssetsConstants.userIcon,
                                    ),
                                    radius: 35,
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //retweeted
                              if (tweet.retweetedBy.isNotEmpty)
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      AssetsConstants.retweetIcon,
                                      color: Pallete.greyColor,
                                      height: 20,
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      "${tweet.retweetedBy} retweeted",
                                      style: const TextStyle(
                                          color: Pallete.greyColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: user.isTwitterBlue ? 1 : 5),
                                    child: Text(
                                      user.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19),
                                    ),
                                  ),
                                  if (user.isTwitterBlue)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 5.0),
                                      child: SvgPicture.asset(
                                        AssetsConstants.verifiedIcon,
                                      ),
                                    ),
                                  Text(
                                    '@${user.name} . ${timeago.format(tweet.tweetedAt, locale: 'en_short')}',
                                    style: const TextStyle(
                                        fontSize: 17, color: Pallete.greyColor),
                                  ),
                                ],
                              ),
                              //replied to
                              if (tweet.repliedTo.isNotEmpty) ...[
                                ref
                                    .watch(
                                        getTweetByIdProvider(tweet.repliedTo))
                                    .when(
                                        data: (repliedToTweet) {
                                          final replyingToUser = ref
                                              .watch(userDetailsProvider(
                                                  repliedToTweet.uid))
                                              .value;
                                          return RichText(
                                            text: TextSpan(
                                              text: "Replying to ",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Pallete.greyColor,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "@${replyingToUser?.name}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Pallete.blueColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        error: (error, st) {
                                          return ErrorText(
                                              error: error.toString());
                                        },
                                        loading: () => const SizedBox())
                              ],
                              HashTagText(text: tweet.text),
                              if (tweet.tweetType == TweetType.image)
                                CarouselImage(imgLinks: tweet.imageLinks),
                              if (tweet.link.isNotEmpty) ...[
                                const SizedBox(
                                  height: 4,
                                ),
                                AnyLinkPreview(
                                  link: "https://${tweet.link}",
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                ),
                              ],
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 10, right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TweetIconButton(
                                      pathName: AssetsConstants.viewsIcon,
                                      text: (tweet.commentIds.length +
                                              tweet.reshareCount +
                                              tweet.likes.length)
                                          .toString(),
                                      onTap: () {},
                                    ),
                                    TweetIconButton(
                                      pathName: AssetsConstants.commentIcon,
                                      text:
                                          (tweet.commentIds.length).toString(),
                                      onTap: () {},
                                    ),
                                    TweetIconButton(
                                      pathName: AssetsConstants.retweetIcon,
                                      text: (tweet.reshareCount).toString(),
                                      onTap: () {
                                        ref
                                            .read(tweetControllerProvider
                                                .notifier)
                                            .reshareTweet(
                                                tweet, currentUser, context);
                                      },
                                    ),
                                    LikeButton(
                                      size: 25,
                                      onTap: (isLiked) async {
                                        ref
                                            .read(tweetControllerProvider
                                                .notifier)
                                            .likeTweet(tweet, currentUser);
                                        return !isLiked;
                                      },
                                      isLiked:
                                          tweet.likes.contains(currentUser.uid),
                                      likeBuilder: (isLiked) {
                                        return isLiked
                                            ? SvgPicture.asset(
                                                AssetsConstants.likeFilledIcon,
                                                color: Pallete.redColor,
                                              )
                                            : SvgPicture.asset(
                                                AssetsConstants
                                                    .likeOutlinedIcon,
                                                color: Pallete.greyColor,
                                              );
                                      },
                                      likeCount: tweet.likes.length,
                                      countBuilder: (likeCount, isLiked, text) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                                color: isLiked
                                                    ? Pallete.redColor
                                                    : Pallete.whiteColor,
                                                fontSize: 16),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.share,
                                        color: Pallete.greyColor,
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 1,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Pallete.greyColor,
                    ),
                  ],
                ),
              );
            },
            error: (Object error, StackTrace stackTrace) {
              return ErrorPage(error: error.toString());
            },
            loading: () {
              return const Loader();
            },
          );
  }
}
