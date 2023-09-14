import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_app/user_provider.dart';
import 'package:demo_app/model/user.dart' as model;
import 'package:demo_app/services/chat/users_service.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Provider.of<UserProvider>(context).fetchUserData();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          model.UserApp data = userProvider.user!;
          _firstNameController.text = userProvider.user!.firstName;
          _lastNameController.text = userProvider.user!.lastName;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit your profile information:'),
                TextFormField(
                  controller: _firstNameController,
                  onChanged: (value) {
                    //data.firstName = value; // Update the user object
                  },
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextFormField(
                  controller: _lastNameController,
                  onChanged: (value) {
                    //data.lastName = value; // Update the user object
                  },
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                // Add more TextFormField widgets for other fields
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    UserServices()
                        .updateProfile(userProvider.user!.uid, context, data);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
