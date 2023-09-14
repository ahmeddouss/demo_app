import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'image_service.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String job,
    File? selectedImage,
  }) async {
    try {
      final authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = authResult.user;
      if (user != null) {
        if (selectedImage != null) {
          // Monitor the upload process

          final url = await StorageMethods()
              .uploadImageToStorage('profile_images', selectedImage);

          // Store additional user information in Firestore or Realtime Database
          final userDocument = _firestore.collection('users').doc(user.uid);
          await userDocument.set({
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'phone_number': phoneNumber,
            'job': job,
            'uid': user.uid,
            'profile_image_url': url, // Store the download URL of the image
          });
          loginUser(email: email, password: password);
          // Navigate to another page or display a success message
        }
      }
    } catch (e) {
      // Handle registration errors, show a message, etc.
      print('Registration error: $e');
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
