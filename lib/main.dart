import 'package:befriend/router.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:befriend/views/pages/login_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/objects/home.dart';
import 'models/data/user_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Safety Net provider
      // 3. Play Integrity provider
      androidProvider: AndroidProvider.debug,
      // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Device Check provider
      // 3. App Attest provider
      // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
      appleProvider: AppleProvider.debug,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //return const MaterialApp(home: PictureSignPage());
    return MaterialApp.router(
        routerDelegate: MyRouter.router.routerDelegate,
        routeInformationParser: MyRouter.router.routeInformationParser,
        routeInformationProvider: MyRouter.router.routeInformationProvider,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ));
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
      //USE FUTURE BUILDER, IF NOT CONNECTED SHOW APP ANIMATION (LIKE WHEN OPENING INSTAGRAM)
      //WHEN READY, SHOW HOME PAGE
      return FutureBuilder(
        future: UserManager.userHome(),
        builder: (BuildContext context, AsyncSnapshot<Home> snapshot) {
          if (snapshot.data == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return HomePage(home: snapshot.data!);
        },
      );
    } else {
      return const LoginPage();
    }
  }
}
