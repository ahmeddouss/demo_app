import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/post_item.dart';
import 'image_service.dart';

class PostService extends ChangeNotifier {
  Future<void> addPost(String? content, File? selectedImage) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      String url = await StorageMethods()
          .uploadImageToStorage('post_images', selectedImage);

      await FirebaseFirestore.instance.collection('posts').add({
        'user_id': userId,
        'content': content,
        'image_url': url,
      });
    }
  }

  Future<List<Widget>> getPosts() async {
    List<Widget> users = [];
    CollectionReference postsCollection =
        FirebaseFirestore.instance.collection('posts');
    // Fetch data from Firestore and get a snapshot
    await postsCollection.get().then((snapshot) {
      final posts = snapshot.docs;

      for (var post in posts) {
        users.add(PostItem(post: post));
      }
    });

    return users;
  }
}
