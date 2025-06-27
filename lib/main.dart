import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'package:islamia/features/home/presentation/pages/home_page.dart';
import 'package:islamia/firebase_options.dart';

void main() async {
  // Make main async
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Islamia',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ProfileScreen(),
    );
  }
}
