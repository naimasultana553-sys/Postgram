import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:postgram/utils/theme.dart';
import 'package:postgram/views/chat/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Messages'),
        centerTitle: false,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: (snapshot.data! as dynamic).docs.length,
            itemBuilder: (context, index) {
              var userSnap = (snapshot.data! as dynamic).docs[index];

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: userSnap['uid'],
                        receiverName: userSnap['username'],
                        receiverProfilePic: userSnap['photoUrl'] ?? '',
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: userSnap['photoUrl'] != null &&
                            userSnap['photoUrl'].isNotEmpty
                        ? NetworkImage(userSnap['photoUrl'])
                        : const NetworkImage(
                                'https://i.stack.imgur.com/l60Hf.png')
                            as ImageProvider,
                    radius: 24,
                  ),
                  title: Text(
                    userSnap['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    userSnap['bio'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chat_bubble_outline, size: 20),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
