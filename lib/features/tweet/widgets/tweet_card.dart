import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twitter_clone/common/common.dart';
import 'package:twitter_clone/constants/asset_constants.dart';
import 'package:twitter_clone/core/enums/tweet_type_enum.dart';
import 'package:twitter_clone/features/auth/controller/auth_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/carousel_image.dart';
import 'package:twitter_clone/features/tweet/widgets/hastag_text.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_icon_button.dart';
import 'package:twitter_clone/models/tweet_model.dart';
import 'package:twitter_clone/theme/pallete.dart';

class TweetCard extends ConsumerWidget {
  final Tweet tweet;
  const TweetCard({super.key, required this.tweet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userDetailsProvider(tweet.uid)).when(
      data: (user) {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePic),
                    radius: 35,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //retweeted
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 5),
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 19),
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
                      HashTagText(text: tweet.text),
                      if (tweet.tweetType == TweetType.image)
                        CarouselImage(imgLinks: tweet.imageLinks),
                      if (tweet.link.isNotEmpty) ...[
                        const SizedBox(
                          height: 4,
                        ),
                        AnyLinkPreview(
                          link: "https://${tweet.link}",
                          displayDirection: UIDirection.uiDirectionHorizontal,
                        ),
                      ],
                      Container(
                        margin: const EdgeInsets.only(top: 10, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              text: (tweet.commentIds.length).toString(),
                              onTap: () {},
                            ),
                            TweetIconButton(
                              pathName: AssetsConstants.retweetIcon,
                              text: (tweet.reshareCount).toString(),
                              onTap: () {},
                            ),
                            TweetIconButton(
                              pathName: AssetsConstants.likeOutlinedIcon,
                              text: (tweet.likes.length).toString(),
                              onTap: () {},
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
