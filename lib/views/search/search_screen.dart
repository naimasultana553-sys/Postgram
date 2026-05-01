import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgram/services/firestore_service.dart';
import 'package:postgram/utils/theme.dart';
import 'package:postgram/views/profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextField(
          controller: searchController,
          style: const TextStyle(color: primaryColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: '🔍  Search people...',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              isShowUsers = value.isNotEmpty;
            });
          },
        ),
      ),
      body: isShowUsers
          ? _buildUserList()
          : _buildPostsGrid(),
    );
  }

  Widget _buildUserList() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchController.text)
          .where('username', isLessThan: '${searchController.text}z')
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No users found', style: TextStyle(color: Colors.grey[500])),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            // Don't show yourself
            if (doc['uid'] == currentUserId) return const SizedBox.shrink();
            return _UserListTile(
              uid: doc['uid'],
              username: doc['username'],
              photoUrl: doc['photoUrl'] ?? '',
              bio: doc['bio'] ?? '',
              currentUserId: currentUserId,
              followers: List<String>.from(doc['followers'] ?? []),
            );
          },
        );
      },
    );
  }

  Widget _buildPostsGrid() {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('posts').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if ((snapshot.data! as dynamic).docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.explore_outlined, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 12),
                Text('Search for people to follow', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }
        return GridView.builder(
          itemCount: (snapshot.data! as dynamic).docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            var doc = (snapshot.data! as dynamic).docs[index];
            return Image.network(doc['postUrl'], fit: BoxFit.cover);
          },
        );
      },
    );
  }
}

class _UserListTile extends StatefulWidget {
  final String uid;
  final String username;
  final String photoUrl;
  final String bio;
  final String currentUserId;
  final List<String> followers;

  const _UserListTile({
    required this.uid,
    required this.username,
    required this.photoUrl,
    required this.bio,
    required this.currentUserId,
    required this.followers,
  });

  @override
  State<_UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<_UserListTile> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.followers.contains(widget.currentUserId);
  }

  void _toggleFollow() async {
    await FirestoreService().followUser(widget.currentUserId, widget.uid);
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.uid)),
      ),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey[850],
        backgroundImage: widget.photoUrl.isNotEmpty
            ? NetworkImage(widget.photoUrl)
            : const NetworkImage('https://i.stack.imgur.com/l60Hf.png'),
      ),
      title: Text(
        widget.username,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: widget.bio.isNotEmpty
          ? Text(
              widget.bio,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            )
          : null,
      trailing: GestureDetector(
        onTap: _toggleFollow,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: _isFollowing ? Colors.transparent : blueColor,
            borderRadius: BorderRadius.circular(8),
            border: _isFollowing ? Border.all(color: Colors.grey[700]!) : null,
          ),
          child: Text(
            _isFollowing ? 'Following' : 'Follow',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: _isFollowing ? Colors.grey[300] : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
