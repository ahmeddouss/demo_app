import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_app/model/user.dart' as model;

class UserServices extends ChangeNotifier {
  Future<void> updateProfile(
      String userId, context, model.UserApp editedUserData) async {
    // Update the user's profile data in Firestore
    Map<String, dynamic> editedUser = editedUserData as Map<String, dynamic>;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(editedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context); // Navigate back to the previous page
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await users.doc(uid).get();
    if (!snapshot.exists) {
      throw Exception('User not found.');
    }
    final userData = snapshot.data() as Map<String, dynamic>;
    return userData;
  }

  Future<model.UserApp> getUserDetails() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await users.doc(uid).get();
    if (!snap.exists) {
      throw Exception('User not found.');
    }

    return model.UserApp.fromSnap(snap);
  }
}
