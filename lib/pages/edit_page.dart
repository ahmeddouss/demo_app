import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> initialUserData;

  EditProfilePage({
    required this.userId,
    required this.initialUserData,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Map<String, dynamic> editedUserData;

  @override
  void initState() {
    super.initState();
    // Initialize the editedUserData with the initialUserData
    editedUserData = Map.from(widget.initialUserData);
  }

  void _updateProfile() async {
    // Update the user's profile data in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update(editedUserData);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit your profile information:'),
            TextFormField(
              initialValue: editedUserData['first_name'],
              onChanged: (value) {
                setState(() {
                  editedUserData['first_name'] = value;
                });
              },
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              initialValue: editedUserData['last_name'],
              onChanged: (value) {
                setState(() {
                  editedUserData['last_name'] = value;
                });
              },
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            // Add more TextFormField widgets for other fields
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
