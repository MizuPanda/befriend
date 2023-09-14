import 'package:befriend/providers/camera_provider.dart';
import 'package:befriend/router.dart';
import 'package:befriend/utilities/samples.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:befriend/views/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  BubbleSample.initialize();
  await CameraProvider.availableCamera();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: MyRouter.router.routerDelegate,
      routeInformationParser: MyRouter.router.routeInformationParser,
      routeInformationProvider: MyRouter.router.routeInformationProvider,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser != null) {
      return HomePage(
          home: Home(user: BubbleSample.connectedUser, connectedHome: true));
    } else {
      return const LoginPage();
    }
  }
}
