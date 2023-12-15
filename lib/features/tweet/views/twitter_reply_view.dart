import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/common/error_page.dart';
import 'package:twitter_clone/common/loading_page.dart';
import 'package:twitter_clone/constants/appwrite_constants.dart';
import 'package:twitter_clone/features/tweet/controller/tweet_controller.dart';
import 'package:twitter_clone/features/tweet/widgets/tweet_card.dart';
import 'package:twitter_clone/models/tweet_model.dart';

class TwitterReplyView extends ConsumerWidget {
  final Tweet tweet;
  const TwitterReplyView({super.key, required this.tweet});

  static route(Tweet tweet) =>
      MaterialPageRoute(builder: (context) => TwitterReplyView(tweet: tweet));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tweet"),
      ),
      body: Column(
        children: [
          TweetCard(tweet: tweet),
          ref.watch(getRepliesToTweetsProvider(tweet)).when(
                data: (tweets) {
                  return ref.watch(getLatestTweetProvider).when(
                        data: (data) {
                          final latestTweet = Tweet.fromMap(data.payload);
                          bool isTweetPresent = false;
                          for (final tweetModel in tweets) {
                            if (tweetModel.id == latestTweet.id) {
                              isTweetPresent = true;
                              break;
                            }
                          }
                          if (!isTweetPresent &&
                              latestTweet.repliedTo == tweet.id) {
                            if (data.events.contains(
                                "databases.*.collections.${AppWriteConstants.tweetsCollection}.documents.*.create")) {
                              tweets.insert(0, Tweet.fromMap(data.payload));
                            } else if (data.events.contains(
                                "databases.*.collections.${AppWriteConstants.tweetsCollection}.documents.*.update")) {
                              //get id of tweet
                              final startingPoint =
                                  data.events[0].lastIndexOf('documents.');
                              final endPoint =
                                  data.events[0].lastIndexOf('.update');

                              final tweetId = data.events[0]
                                  .substring(startingPoint + 10, endPoint);

                              var tweet = tweets
                                  .where((element) => element.id == tweetId)
                                  .first;

                              final tweetIdx = tweets.indexOf(tweet);
                              tweets.removeWhere(
                                  (element) => element.id == tweetId);
                              tweet = Tweet.fromMap(data.payload);
                              tweets.insert(tweetIdx, tweet);
                            }
                          }
                          return Expanded(
                            child: ListView.builder(
                              itemCount: tweets.length,
                              itemBuilder: (BuildContext context, index) {
                                final tweet = tweets[index];
                                return TweetCard(tweet: tweet);
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
                              itemCount: tweets.length,
                              itemBuilder: (BuildContext context, index) {
                                final tweet = tweets[index];
                                return TweetCard(tweet: tweet);
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
        ],
      ),
      bottomNavigationBar: TextField(
        onSubmitted: (value) {
          ref.read(tweetControllerProvider.notifier).shareTweet(
            images: [],
            text: value,
            context: context,
            repliedTo: tweet.id,
          );
        },
        decoration: const InputDecoration(hintText: "Tweet your reply"),
      ),
    );
  }
}
