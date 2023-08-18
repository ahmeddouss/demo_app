import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //final ImagePicker _imagePicker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _jobController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? selectedImage;
  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _jobController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
                onTap: () {
                  getImage(ImageSource.camera);
                },
                child: selectedImage == null
                    ? Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffD6D6D6),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      )
                    : Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          image:
                              DecorationImage(image: FileImage(selectedImage!)),
                          shape: BoxShape.circle,
                          color: Color(0xffD6D6D6),
                        ),
                        child: Icon(Icons.camera_alt_outlined, size: 40),
                      )),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _jobController,
              decoration: InputDecoration(labelText: 'Job'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _registerUser();
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
