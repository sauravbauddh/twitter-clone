enum TweetType {
  text,
  image,
}

extension TweetTypeExtension on TweetType {
  String get value {
    switch (this) {
      case TweetType.text:
        return 'text';
      case TweetType.image:
        return 'image';
    }
  }

  static TweetType fromValue(String value) {
    switch (value) {
      case 'text':
        return TweetType.text;
      case 'image':
        return TweetType.image;
      default:
        throw Exception('Unknown tweet type: $value');
    }
  }
}
