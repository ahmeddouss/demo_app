import 'package:demo_app/services/chat/users_service.dart';
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
  late Future<Map<String, dynamic>> userDataFuture;

  @override
  void initState() {
    super.initState();
    userDataFuture = UserServices().getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Profile')),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Loading indicator while data is being fetched
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return Text('No user data available.');
            } else {
              final userData = snapshot.data!;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      // ... your container widget
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
                          builder: (context) => EditProfilePage(),
                        ),
                      );
                    },
                    child: Text('Edit Profile'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ProfilePage()));
}
