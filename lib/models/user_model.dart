import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String photoUrl;
  final String bio;
  final List followers;
  final List following;
  final double studyHours;
  final int points;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.bio,
    required this.followers,
    required this.following,
    this.studyHours = 0.0,
    this.points = 0,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "username": username,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following,
        "studyHours": studyHours,
        "points": points,
      };

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
      uid: snapshot["uid"] ?? "",
      username: snapshot["username"] ?? "",
      email: snapshot["email"] ?? "",
      photoUrl: snapshot["photoUrl"] ?? "",
      bio: snapshot["bio"] ?? "",
      followers: snapshot["followers"] ?? [],
      following: snapshot["following"] ?? [],
      studyHours: (snapshot["studyHours"] ?? 0).toDouble(),
      points: snapshot["points"] ?? 0,
    );
  }
}
