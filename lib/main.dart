// ignore_for_file: prefer_final_fields, library_private_types_in_public_api, prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/georoutes_provider.dart';
import 'package:demo_app/pages/dashboard.dart';
import 'package:demo_app/pages/sign_page.dart';
import 'package:demo_app/pages/users_page.dart';
import 'package:demo_app/stream_provider.dart';
import 'package:demo_app/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:demo_app/steam_location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => GeoRoutesProvider()),
        StreamProvider<DocumentSnapshot<Object?>?>(
          create: (context) => StreammProvider().userData,
          initialData: null,
        ),
        StreamProvider<Position?>(
            create: (context) => StreamLocationProvider().positionStream,
            initialData: Position(
              latitude: 36.805483,
              longitude: 10.239920,
              timestamp: null,
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
            ))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => Dashboard(),
          '/user': (context) => UserListPage(),
          '/sign': (context) => RegistrationPage(),
        },
      ),
    );
  }
}
