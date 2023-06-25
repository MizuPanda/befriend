import 'package:befriend/utilities/samples.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:befriend/views/pages/profile_cam_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  BubbleSample.initialize();
  await ProfileCameraPage.availableCamera();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(
        user: BubbleSample.connectedUser,
        connectedHome: true,
      ),
    );
  }
}
