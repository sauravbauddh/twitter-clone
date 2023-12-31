import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

class HashtagView extends ConsumerWidget {
  final String hashtag;
  const HashtagView({
    super.key,
    required this.hashtag,
  });

  static route(String hashtag) => MaterialPageRoute(
        builder: (context) => HashtagView(
          hashtag: hashtag,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hashtag),
      ),
      body: ref.watch(getTweetsByHashtagProvider(hashtag)).when(
            data: (tweets) {
              return ref.watch(getLatestTweetProvider).when(
                    data: (data) {
                      if (data.events.contains(
                          "databases.*.collections.${AppWriteConstants.tweetsCollection}.documents.*.create")) {
                        tweets.insert(0, Tweet.fromMap(data.payload));
                      } else if (data.events.contains(
                          "databases.*.collections.${AppWriteConstants.tweetsCollection}.documents.*.update")) {
                        //get id of tweet
                        final startingPoint =
                            data.events[0].lastIndexOf('documents.');
                        final endPoint = data.events[0].lastIndexOf('.update');

                        final tweetId = data.events[0]
                            .substring(startingPoint + 10, endPoint);

                        var tweet = tweets
                            .where((element) => element.id == tweetId)
                            .first;

                        final tweetIdx = tweets.indexOf(tweet);
                        tweets.removeWhere((element) => element.id == tweetId);
                        tweet = Tweet.fromMap(data.payload);
                        tweets.insert(tweetIdx, tweet);
                      }
                      return ListView.builder(
                        itemCount: tweets.length,
                        itemBuilder: (BuildContext context, index) {
                          final tweet = tweets[index];
                          return TweetCard(tweet: tweet);
                        },
                      );
                    },
                    error: (error, st) => ErrorText(
                      error: error.toString(),
                    ),
                    loading: () {
                      return ListView.builder(
                        itemCount: tweets.length,
                        itemBuilder: (BuildContext context, index) {
                          final tweet = tweets[index];
                          return TweetCard(tweet: tweet);
                        },
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
