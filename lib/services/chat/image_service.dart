import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PostService extends ChangeNotifier{
 
 
  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }

    return null;
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