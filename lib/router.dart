import 'package:befriend/utilities/samples.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:befriend/views/pages/login_page.dart';
import 'package:befriend/views/pages/camera_page.dart';
import 'package:befriend/views/pages/profile_page.dart';
import 'package:befriend/views/pages/sign_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main.dart';
import 'models/bubble.dart';
import 'models/home.dart';

class MyRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const SelectPage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'homepage',
              pageBuilder: (context, state) {
                return MaterialPage(
                    child: HomePage(
                        home: state.extra as Home? ??
                            Home(
                              user: BubbleSample.connectedUser,
                              connectedHome: true,
                            )));
              },
            ),
            GoRoute(
              path: 'profile', // Define a parameter named "id"
              pageBuilder: (context, state) {
                return MaterialPage(
                    child: ProfilePage(
                        user: state.extra as Bubble? ??
                            BubbleSample.connectedUser));
              },
            ),
            GoRoute(
              path: 'login',
              builder: (BuildContext context, GoRouterState state) {
                return const LoginPage();
              },
            ),
            GoRoute(
              path: 'signup',
              builder: (BuildContext context, GoRouterState state) {
                return const SignUpPage();
              },
            ),
            GoRoute(
              path: 'camera',
              builder: (BuildContext context, GoRouterState state) {
                return const CameraPage();
              },
            ),
          ]),
    ],
  );
}
