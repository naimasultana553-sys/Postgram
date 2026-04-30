import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String uid;
  final String username;
  final String profImage;
  final String caption;
  final String postUrl;
  final DateTime datePublished;
  final List likes;

  PostModel({
    required this.postId,
    required this.uid,
    required this.username,
    required this.profImage,
    required this.caption,
    required this.postUrl,
    required this.datePublished,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        "postId": postId,
        "uid": uid,
        "username": username,
        "profImage": profImage,
        "caption": caption,
        "postUrl": postUrl,
        "datePublished": datePublished,
        "likes": likes,
      };

  static PostModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return PostModel(
      postId: snapshot["postId"] ?? "",
      uid: snapshot["uid"] ?? "",
      username: snapshot["username"] ?? "",
      profImage: snapshot["profImage"] ?? "",
      caption: snapshot["caption"] ?? "",
      postUrl: snapshot["postUrl"] ?? "",
      datePublished: (snapshot["datePublished"] as Timestamp).toDate(),
      likes: snapshot["likes"] ?? [],
    );
  }
}
