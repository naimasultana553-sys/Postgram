import 'package:flutter/material.dart';
import 'package:postgram/utils/theme.dart';
import 'package:postgram/views/feed/feed_screen.dart';
import 'package:postgram/views/search/search_screen.dart';
import 'package:postgram/views/upload/upload_screen.dart';
import 'package:postgram/views/productivity/productivity_screen.dart';
import 'package:postgram/views/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:postgram/viewmodels/user_viewmodel.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    addData();
  }

  addData() async {
    UserViewModel _userViewModel = Provider.of(context, listen: false);
    await _userViewModel.refreshUser();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const UploadScreen(),
          const ProductivityScreen(),
          ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: mobileBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.grey[900]!, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, Icons.home_outlined, 0),
            _navItem(Icons.search, Icons.search_outlined, 1),
            _navItem(Icons.add_box, Icons.add_box_outlined, 2),
            _navItem(Icons.timer, Icons.timer_outlined, 3),
            _navItem(Icons.person, Icons.person_outlined, 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData activeIcon, IconData inactiveIcon, int index) {
    bool isActive = _page == index;
    return IconButton(
      onPressed: () => navigationTapped(index),
      icon: Icon(
        isActive ? activeIcon : inactiveIcon,
        color: isActive ? primaryColor : secondaryColor,
        size: 28,
      ),
    );
  }
}
