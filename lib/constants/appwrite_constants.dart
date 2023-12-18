class AppWriteConstants {
  static const String databaseId = "657723ba84e1d49f1662";
  static const String projectId = "6570e7fcdff693442e89";
  static const String endpoint = "http://192.168.1.3:80/v1";
  static const String usersCollection = "657723cd1a1c80dd02d6";
  static const String tweetsCollection = "65774d71c162d8809072";
  static const String imagesBucket = "657755c0196b9152e8f7";
  static var notificationsCollection = "657f71971c21099f6a27";

  static String imageUrl(String imageId) =>
      "$endpoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin";
}
