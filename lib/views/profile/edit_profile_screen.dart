import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:postgram/services/auth_service.dart';
import 'package:postgram/services/storage_service.dart';
import 'package:postgram/utils/theme.dart';
import 'package:postgram/utils/utils.dart';
import 'package:postgram/views/auth/login_screen.dart';
import 'package:postgram/widgets/text_field_input.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  bool _isLoading = false;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userData['username']);
    _bioController = TextEditingController(text: widget.userData['bio']);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String photoUrl = widget.userData['photoUrl'];
      
      // If user selected a new image, upload to Imgur
      if (_image != null) {
        photoUrl = await StorageService()
            .uploadImageToStorage('profilePics', _image!, false);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'username': _usernameController.text,
        'bio': _bioController.text,
        'photoUrl': photoUrl,
      });

      if (context.mounted) {
        showSnackBar('Profile updated successfully!', context);
        Navigator.pop(context, true); // Return true to indicate profile was updated
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(e.toString(), context);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Edit Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Stack(
                children: [
                  _image != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : CircleAvatar(
                          radius: 64,
                          backgroundImage: widget.userData['photoUrl'] != null &&
                                  widget.userData['photoUrl'].toString().isNotEmpty
                              ? NetworkImage(widget.userData['photoUrl'])
                              : const NetworkImage(
                                      'https://i.stack.imgur.com/l60Hf.png')
                                  as ImageProvider,
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo, color: blueColor),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: 'Enter your username',
                textInputType: TextInputType.text,
                textEditingController: _usernameController,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: 'Enter your bio',
                textInputType: TextInputType.text,
                textEditingController: _bioController,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: updateProfile,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    color: blueColor,
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
