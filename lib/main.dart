import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_cloud_led/TempC.dart';

import 'package:flutter_application_cloud_led/home_page.dart';
import 'package:flutter_application_cloud_led/noti.dart';
import 'firebase_options.dart'; // Import the generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotiService().initNotification();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Use generated Firebase config
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firestore',
      home: TempC(),
    );
  }
}
