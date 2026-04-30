import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:postgram/services/firestore_service.dart';
import 'package:postgram/services/ai_service.dart';
import 'package:postgram/utils/theme.dart';
import 'package:postgram/utils/utils.dart';
import 'package:postgram/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? _file;
  bool isLoading = false;
  bool isAIGenerating = false;
  final TextEditingController _descriptionController = TextEditingController();
  List<String> aiSuggestions = [];

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    try {
      String res = await FirestoreService().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        profImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar('Posted!', context);
        }
        clearImage();
      } else {
        if (context.mounted) {
          showSnackBar(res, context);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(err.toString(), context);
      }
    }
  }

  void generateAICaptions() async {
    if (_file == null) return;
    setState(() {
      isAIGenerating = true;
      aiSuggestions = [];
    });
    
    List<String> suggestions = await AIService().generateCaptions(_file!);
    
    setState(() {
      aiSuggestions = suggestions;
      isAIGenerating = false;
    });
  }

  void selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _file = null;
      _descriptionController.clear();
      aiSuggestions = [];
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserViewModel userProvider = Provider.of<UserViewModel>(context);

    return _file == null
        ? Center(
            child: IconButton(
              icon: const Icon(Icons.upload, size: 50, color: blueColor),
              onPressed: () => selectImage(context),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: const Text('Post to'),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => postImage(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                )
              ],
            ),
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        userProvider.getUser.photoUrl,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Write a caption...",
                            border: InputBorder.none),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45.0,
                      width: 45.0,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                            image: MemoryImage(_file!),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                // AI Caption Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "AI Caption Suggestions",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          isAIGenerating 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : IconButton(
                                icon: const Icon(Icons.auto_awesome, color: Colors.amber),
                                onPressed: generateAICaptions,
                              ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (aiSuggestions.isNotEmpty)
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: aiSuggestions.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _descriptionController.text = aiSuggestions[index];
                                },
                                child: Container(
                                  width: 200,
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    aiSuggestions[index],
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else if (!isAIGenerating)
                        const Text(
                          "Tap the magic wand to generate captions!",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
