import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/pages/sign_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:demo_app/user_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  void initState() {
    super.initState();
  }

  String? _errorMessage; // Add a variable to store the error message

  final _formkey = GlobalKey<FormState>();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();

  @override
  void dispose() {
    _emailcontroller.dispose();

    _passwordcontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Login To Myyy Account'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailcontroller,
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _passwordcontroller,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return ElevatedButton(
                    child: Text('Login'),
                    onPressed: () async {
                      try {
                        final UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                          email: _emailcontroller.text,
                          password: _passwordcontroller.text,
                        );

                        await _updateOnlineStatus(
                            userCredential.user!.uid, true);
                        userProvider.fetchUserData();
                        Navigator.of(context).pushReplacementNamed('/home');
                      } on FirebaseAuthException catch (e) {
                        print('Failed with error code: ${e.code}');
                        print(e.message);
                        setState(() {
                          _errorMessage = e.message ??
                              "An error occurred"; // Assign a default value if e.message is null
                        });
                      }
                    },
                  );
                },
              ),

              SizedBox(
                height: 15,
              ),
              Text(
                _errorMessage ?? "",
                style: TextStyle(color: Colors.red),
              ), // Display the error message below the login button
              Row(
                children: [
                  Text("Don't have an account"),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RegistrationPage()), // Replace `SecondScreen()` with the widget of your second screen
                        );
                      },
                      child: Text('Sing up'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateOnlineStatus(String uid, bool isOnline) async {
    try {
      await users.doc(uid).update({
        'isOnline': isOnline,
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}
