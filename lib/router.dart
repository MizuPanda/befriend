import 'package:befriend/views/pages/forgot_pass_page.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:befriend/views/pages/login_page.dart';
import 'package:befriend/views/pages/picture_sign_page.dart';
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
                        home: state.extra as Home));
                //homepage
              },
            ),
            GoRoute(
              path: 'profile',
              pageBuilder: (context, state) {
                return MaterialPage(
                    child: ProfilePage(
                        user: state.extra as Bubble));
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
              path: 'forgot',
              builder: (BuildContext context, GoRouterState state) {
                return const ForgotPasswordPage();
              },
            ),
            GoRoute(
              path: 'picture',
              builder: (BuildContext context, GoRouterState state) {
                return const PictureSignPage();
              },
            ),
          ]),
    ],
  );
}
