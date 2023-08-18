import 'package:demo_app/pages/dashboard.dart';

import 'package:demo_app/pages/sign_page.dart';
import 'package:demo_app/pages/users_page.dart';
import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => Dashboard(),
        '/user': (context) => UserListPage(),
        '/sign': (context) => RegistrationPage(),
      },
    );
  }
}
