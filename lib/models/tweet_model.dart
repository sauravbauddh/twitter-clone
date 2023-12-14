import 'package:twitter_clone/core/enums/tweet_type_enum.dart';

class Tweet {
  final String text;
  final List<String> hashtags;
  final String link;
  final List<String> imageLinks;
  final String uid;
  final TweetType tweetType;
  final DateTime tweetedAt;
  final List<String> likes;
  final List<String> commentIds;
  final String id;
  final int reshareCount;
  final String retweetedBy; // New property

  Tweet({
    required this.text,
    required this.hashtags,
    required this.link,
    required this.imageLinks,
    required this.uid,
    required this.tweetType,
    required this.tweetedAt,
    required this.likes,
    required this.commentIds,
    required this.id,
    required this.reshareCount,
    required this.retweetedBy, // New property
  });

  factory Tweet.fromMap(Map<String, dynamic> map) {
    return Tweet(
      text: map['text'] as String,
      hashtags: List<String>.from(map['hashtags'] as List<dynamic>),
      link: map['link'] as String,
      imageLinks: List<String>.from(map['imageLinks'] as List<dynamic>),
      uid: map['uid'] as String,
      tweetType: TweetTypeExtension.fromValue(map['tweetType'] as String),
      tweetedAt: DateTime.fromMillisecondsSinceEpoch(map['tweetedAt'] as int),
      likes: List<String>.from(map['likes'] as List<dynamic>),
      commentIds: List<String>.from(map['commentIds'] as List<dynamic>),
      id: map['\$id'] as String,
      reshareCount: map['reshareCount'] as int,
      retweetedBy: map['retweetedBy'] as String, // New property
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'hashtags': hashtags,
      'link': link,
      'imageLinks': imageLinks,
      'uid': uid,
      'tweetType': tweetType.value,
      'tweetedAt': tweetedAt.millisecondsSinceEpoch,
      'likes': likes,
      'commentIds': commentIds,
      'reshareCount': reshareCount,
      'retweetedBy': retweetedBy, // New property
    };
  }

  Tweet copyWith({
    String? text,
    List<String>? hashtags,
    String? link,
    List<String>? imageLinks,
    String? uid,
    TweetType? tweetType,
    DateTime? tweetedAt,
    List<String>? likes,
    List<String>? commentIds,
    String? id,
    int? reshareCount,
    String? retweetedBy, // Include the new property here
  }) {
    return Tweet(
      text: text ?? this.text,
      hashtags: hashtags ?? this.hashtags,
      link: link ?? this.link,
      imageLinks: imageLinks ?? this.imageLinks,
      uid: uid ?? this.uid,
      tweetType: tweetType ?? this.tweetType,
      tweetedAt: tweetedAt ?? this.tweetedAt,
      likes: likes ?? this.likes,
      commentIds: commentIds ?? this.commentIds,
      id: id ?? this.id,
      reshareCount: reshareCount ?? this.reshareCount,
      retweetedBy: retweetedBy ?? this.retweetedBy, // Set the new property here
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tweet &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          hashtags == other.hashtags &&
          link == other.link &&
          imageLinks == other.imageLinks &&
          uid == other.uid &&
          tweetType == other.tweetType &&
          tweetedAt == other.tweetedAt &&
          likes == other.likes &&
          commentIds == other.commentIds &&
          id == other.id &&
          reshareCount == other.reshareCount &&
          retweetedBy ==
              other.retweetedBy); // Include comparison for new property

  @override
  int get hashCode =>
      text.hashCode ^
      hashtags.hashCode ^
      link.hashCode ^
      imageLinks.hashCode ^
      uid.hashCode ^
      tweetType.hashCode ^
      tweetedAt.hashCode ^
      likes.hashCode ^
      commentIds.hashCode ^
      id.hashCode ^
      reshareCount.hashCode ^
      retweetedBy.hashCode; // Include hashing for new property

  @override
  String toString() {
    return 'Tweet{ text: $text, hashtags: $hashtags, link: $link, imageLinks: $imageLinks, uid: $uid, tweetType: $tweetType, tweetedAt: $tweetedAt, likes: $likes, commentIds: $commentIds, id: $id, reshareCount: $reshareCount, retweetedBy: $retweetedBy }'; // Include new property in toString()
  }
}
