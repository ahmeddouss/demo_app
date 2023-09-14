import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/user_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_app/model/user.dart' as model;

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data from Firebase'),
      ),
      body: Column(
        children: [
          Consumer<DocumentSnapshot<Object?>?>(
            builder: (context, userDataSnapshot, child) {
              if (userDataSnapshot == null || !userDataSnapshot.exists) {
                // Handle the case where data is not available or doesn't exist
                return Center(
                  child: Text('User data not available.'),
                );
              } else {
                // Access user data from the snapshot
                var userData = model.UserApp.fromSnap(userDataSnapshot);
                var firstName = userData.firstName;

                return Center(
                  child: Text('Firstname: $firstName from stream builder'),
                );
              }
            },
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.user == null) {
                return Text('Loading');
              } else {
                return Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return Center(
                      child: Text(
                        'Firstname: ${userProvider.user!.firstName} from change notifier',
                      ),
                    );
                  },
                );
              }
            },
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return FloatingActionButton(
                onPressed: () {
                  userProvider.fetchUserData();
                },
                child: Icon(Icons.refresh),
              );
            },
          )
        ],
      ),
    );
  }
}
