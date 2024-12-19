import 'package:flutter/material.dart';
import 'package:hediety_project/screens/HomeScreen.dart';
import 'package:hediety_project/screens/loginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
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
        '/signup': (context) => SignUpScreen(),
        '/login' : (context) => LoginScreen(),
        '/home': (context) => HomeScreen(), // Define your home screen
      },
    );
  }
}