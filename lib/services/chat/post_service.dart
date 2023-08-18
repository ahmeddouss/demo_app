import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostService extends ChangeNotifier {
  Future<void> _registerUser() async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      final authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = authResult.user;
      if (user != null) {
        if (selectedImage != null) {
          final Reference storageRef =
              _storage.ref().child('profile_images/$email');

          // Upload the image to Firebase Storage
          final UploadTask uploadTask = storageRef.putFile(selectedImage!);

          // Monitor the upload process
          await uploadTask.whenComplete(() async {
            final url = await storageRef.getDownloadURL();

            // Store additional user information in Firestore or Realtime Database
            final userDocument = _firestore.collection('users').doc(user.uid);
            await userDocument.set({
              'first_name': _firstNameController.text,
              'last_name': _lastNameController.text,
              'email': email,
              'phone_number': _phoneNumberController.text,
              'job': _jobController.text,
              'profile_image_url': url, // Store the download URL of the image
            });

            // Navigate to another page or display a success message
          });
        } else {
          // No profile image provided
          print('No profile image selected.');
        }
      }
    } catch (e) {
      // Handle registration errors, show a message, etc.
      print('Registration error: $e');
    }
  }
}

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
    final storageReference =
        FirebaseStorage.instance.ref().child('post_images/${postReference.id}');
    await storageReference.putFile(_selectedImage!);
    final downloadUrl = await storageReference.getDownloadURL();
    await postReference.update({'image_url': downloadUrl});
  }
}

Widget _buildUserList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text('loading..');
      }

      return ListView(
        children: snapshot.data!.docs
            .map<Widget>((doc) => _buildUserListItem(context, doc))
            .toList(),
      );
    },
  );
}

Widget _buildUserListItem(BuildContext context, DocumentSnapshot document) {
  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
  if (FirebaseAuth.instance.currentUser!.email != data['email']) {
    return ListTile(
      title: Text(data['email']),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: data['email'],
                receiverUserID: data['uid'],
              ),
            ));
      },
    );
  } else {
    return Container();
  }
}
