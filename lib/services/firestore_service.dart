import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:postgram/models/post_model.dart';
import 'package:postgram/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload Post
  Future<String> uploadPost(String caption, Uint8List file, String uid,
      String username, String profImage) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageService().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();
      PostModel post = PostModel(
        caption: caption,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      await _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Like Post
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Post Comment
  Future<void> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      } else {
        print('text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Follow User
  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data() as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Update Study Hours
  Future<void> updateStudyHours(String uid, double hours) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'studyHours': FieldValue.increment(hours),
        'points': FieldValue.increment((hours * 10).toInt()), // 10 points per hour
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // Send Chat Message
  Future<void> sendMessage(String receiverId, String text, String senderId) async {
    try {
      if (text.isNotEmpty) {
        String chatId = _getChatId(senderId, receiverId);
        
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'senderId': senderId,
          'receiverId': receiverId,
          'text': text,
          'timestamp': DateTime.now(),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Get Chat Messages
  Stream<QuerySnapshot> getMessages(String currentUserId, String otherUserId) {
    String chatId = _getChatId(currentUserId, otherUserId);
    
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Helper method to generate unique chat ID
  String _getChatId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return users.join('_');
  }
}
