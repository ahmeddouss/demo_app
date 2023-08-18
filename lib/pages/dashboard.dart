import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/pages/post_page.dart';
import 'package:demo_app/pages/profile_page.dart';
import 'package:demo_app/pages/users_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'calender_page.dart';
import 'maps_page.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(
    BuildContext context,
  ) {
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Loading indicator while fetching data
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
            appBar: AppBar(
              title: Text('Dashboard'),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await _updateOnlineStatus(uid, false, users);
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text('Log Out'),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(onPressed: () {}),
            drawer: customDrawer(context, profileImageUrl,
                userData), // Pass context and profileImageUrl
            body: const Text(
                'List of task for work or list of livraison') // Replace this with your actual body content
            );
      },
    );
  }
}

Future<void> _updateOnlineStatus(
    String uid, bool isOnline, CollectionReference users) async {
  try {
    await users.doc(uid).update({
      'isOnline': isOnline,
    });
  } catch (e) {
    print('Error updating online status: $e');
  }
}

Widget customDrawer(BuildContext context, profileImageUrl, userData) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(),
              ),
            );
          },
          child: UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            accountName:
                Text('${userData['first_name']} ${userData['last_name']}'),
            accountEmail: Text('${userData['email']}'),
            currentAccountPicture: Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
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
          ),
        ),

        ListTile(
          leading: Icon(Icons.chat),
          title: Text('Users'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserListPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.podcasts),
          title: Text('Posts'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.calendar_month),
          title: Text('Clender'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.map),
          title: const Text('Maps'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapsPage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () {},
        ),
        // Add more ListTiles for other buttons
      ],
    ),
  );
}
