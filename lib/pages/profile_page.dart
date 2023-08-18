import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_app/pages/edit_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late String userId; // Initialize with the user's ID
  late String profileImageUrl = ''; // Initialize with an empty string

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading indicator while fetching data
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('User not found.');
        }

        // Retrieve user data from the snapshot
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final profileImageUrl = userData['profile_image_url'];
        return Scaffold(
          appBar: AppBar(title: Text('My Profile')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffD6D6D6),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(profileImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                    'Name: ${userData['first_name']} ${userData['last_name']}'),
                Text('Email: ${userData['email']}'),
                Text('Phone: ${userData['phone_number']}'),
                Text('Job: ${userData['job']}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          userId: uid,
                          initialUserData: userData,
                        ),
                      ),
                    );
                  },
                  child: Text('Edit Profile'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void main() {
    runApp(MaterialApp(home: ProfilePage()));
  }
}
