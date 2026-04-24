import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/login_screen.dart';
import 'views/login_screen.dart' show MainShell;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final savedUserId = prefs.getString('userId');

  runApp(MyApp(savedUserId: savedUserId));
}

class MyApp extends StatelessWidget {
  final String? savedUserId;

  const MyApp({super.key, this.savedUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: savedUserId != null
          ? MainShell(userId: savedUserId!)
          : const LoginScreen(),
    );
  }
}