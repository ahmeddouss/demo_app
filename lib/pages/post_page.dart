import 'package:demo_app/services/chat/post_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../services/chat/image_service.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _postController = TextEditingController();

  File? _selectedImage;
  List<Widget> _userPosts = []; // New variable to store user posts

  @override
  void initState() {
    super.initState();
    fetchUserPosts(); // Fetch user posts when the widget initializes
  }

  Future<void> fetchUserPosts() async {
    List<Widget> posts = await PostService().getPosts();
    setState(() {
      _userPosts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Posts')),
      body: Column(
        children: [
          Expanded(
            child: ListView(children: _userPosts),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _postController,
                    decoration: InputDecoration(labelText: 'Enter your post'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your post';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await PostService()
                          .addPost(_postController.text, _selectedImage);
                      _postController.clear();
                    },
                    child: Text('Add Post'),
                  ),
                  //SizedBox(height: 6),
                  if (_selectedImage != null)
                    Container(
                      child: Image.file(_selectedImage!),
                      width: 4,
                      height: 4,
                    )
                  else
                    SizedBox(),
                  ElevatedButton(
                    onPressed: () async {
                      final image = await StorageMethods().pickImage();
                      if (image != null) {
                        setState(() {
                          _selectedImage = image;
                        });
                      }
                    },
                    child: Text('Pick Image'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
