import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:befriend/providers/material_provider.dart';
import 'package:befriend/router.dart';
import 'package:befriend/utilities/secrets.dart';
import 'package:befriend/utilities/themes.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:befriend/views/pages/login_page.dart';
import 'package:befriend/views/widgets/shimmers/loading_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/objects/home.dart';
import 'models/data/user_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // await ConsentManager.debugReset();

  final params = ConsentRequestParameters(
      // consentDebugSettings: Secrets.consentDebugSettings
      );
  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      // The consent information state was updated.
      // You are now ready to check if a form is available.
    },
    (FormError error) {
      // Handle the error
    },
  );

  // Should call these functions only if consent has been given.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    MobileAds.instance.initialize();
  }

  final RequestConfiguration configuration;

  // Set up test devices
  if (kDebugMode) {
    configuration = RequestConfiguration(testDeviceIds: <String>[
      Secrets.requestConfigurationDeviceID
    ]); // Replace with your actual device ID

    await MobileAds.instance.updateRequestConfiguration(configuration);
  } else {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

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

  debugPrint('(Main): Finished initiating main()');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MaterialProvider _provider = MaterialProvider();

  @override
  void initState() {
    _provider.initProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _provider,
        builder: (BuildContext context, Widget? child) {
          return Consumer<MaterialProvider>(builder: (BuildContext context,
              MaterialProvider materialProvider, Widget? child) {
            return MaterialApp.router(
              routerDelegate: MyRouter.router.routerDelegate,
              routeInformationParser: MyRouter.router.routeInformationParser,
              routeInformationProvider:
                  MyRouter.router.routeInformationProvider,
              theme: Themes.lightTheme,
              darkTheme: Themes.darkTheme,
              themeMode: materialProvider.themeMode,
            );
          });
        });
  }
}

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  late final Future<Home> _futureHome;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureHome = UserManager.userHome();
  }

  @override
  Widget build(BuildContext context) {
    // return const PictureSignPage();
    // return const LoadingScreen();
    if (FirebaseAuth.instance.currentUser != null) {
      return FutureBuilder(
        future: _futureHome,
        builder: (BuildContext context, AsyncSnapshot<Home> snapshot) {
          if (!snapshot.hasData) {
            return const LoadingScreen();
          }

          ConsentManager.setTagForChildrenAds(snapshot.data!.user.birthYear);

          return HomePage(home: snapshot.data!);
        },
      );
    } else {
      return const LoginPage();
    }
  }
}
