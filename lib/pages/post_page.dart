import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

import '../services/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PostPage(),
    );
  }
}

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _postController = TextEditingController();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Posts')),
      body: Column(
        children: [
          Expanded(
            child: PostsList(),
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
                      if (_formKey.currentState!.validate()) {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId != null) {
                          await _addPost(_postController.text, userId);
                          _postController.clear();
                          setState(() {
                            _selectedImage = null;
                          });
                        }
                      }
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
                      final image = await pickImage();
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

  Future<void> _addPost(String content, String userId) async {
    final postReference =
        await FirebaseFirestore.instance.collection('posts').add({
      'user_id': userId,
      'content': content,
    });

    if (_selectedImage != null) {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('post_images/${postReference.id}');
      await storageReference.putFile(_selectedImage!);
      final downloadUrl = await storageReference.getDownloadURL();
      await postReference.update({'image_url': downloadUrl});
    }
  }
}

class PostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final userId = post['user_id'];
            final postContent = post['content'];

            final String? imageUrl = post['image_url'];

            return ListTile(
              title: Text('User ID: $userId'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(postContent),
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Image?.network(
                        imageUrl) // Display image if URL exists and is not empty
                  else
                    SizedBox(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
