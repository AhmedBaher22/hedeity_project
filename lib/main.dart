import 'package:flutter/material.dart';
import 'package:hediety_project/screens/HomeScreen.dart';
import 'package:hediety_project/screens/create_event_screen.dart';
import 'package:hediety_project/screens/create_gift_screen.dart';
import 'package:hediety_project/screens/events_screen.dart';
import 'package:hediety_project/screens/friend_profile_screen.dart';
import 'package:hediety_project/screens/gift_details.dart';
import 'package:hediety_project/screens/gifts_screen.dart';
import 'package:hediety_project/screens/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hediety_project/screens/profile_screen.dart';
import 'package:hediety_project/screens/signUpScreen.dart';

import 'firebase_options.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/events': (context) => EventsScreen(),
        '/create_event': (context) => CreateEventScreen(),
        '/profile': (context) => ProfileScreen(),
        '/gifts': (context) => GiftsScreen(),
        '/friend': (context) => FriendProfileScreen(),
        '/gift_details': (context) => GiftDetailsScreen(),
        '/create_gift': (context) => CreateGiftScreen(),
      },
    );
  }
}