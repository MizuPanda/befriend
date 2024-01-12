import 'package:befriend/models/objects/profile.dart';
import 'package:befriend/views/pages/forgot_pass_page.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:befriend/views/pages/login_page.dart';
import 'package:befriend/views/pages/picture_sign_page.dart';
import 'package:befriend/views/pages/profile_page.dart';
import 'package:befriend/views/pages/sign_page.dart';
import 'package:befriend/views/widgets/home/picture/picture_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main.dart';
import 'models/objects/home.dart';
import 'models/objects/host.dart';

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
                return MaterialPage(child: HomePage(home: state.extra as Home));
                //homepage
              },
            ),
            GoRoute(
              path: 'profile',
              pageBuilder: (BuildContext context, GoRouterState state) {
                return MaterialPage(
                    child: ProfilePage(profile: state.extra as Profile));
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
            GoRoute(
                path:  'session',
              builder: (BuildContext context, GoRouterState state) {
                  return PictureSession(host: state.extra as Host);
              }
            )
          ]),
    ],
  );
}
