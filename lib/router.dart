import 'package:befriend/models/objects/profile.dart';
import 'package:befriend/views/pages/forgot_pass_page.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:befriend/views/pages/login_page.dart';
import 'package:befriend/views/pages/mutual_page.dart';
import 'package:befriend/views/pages/picture_sign_page.dart';
import 'package:befriend/views/pages/profile_page.dart';
import 'package:befriend/views/pages/sign_page.dart';
import 'package:befriend/views/pages/session_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main.dart';
import 'models/objects/home.dart';
import 'models/objects/host.dart';

class MyRouter {
  static const String homepage = 'homepage';
  static const String profile = 'profile';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgot = 'forgot';
  static const String picture = 'picture';
  static const String session = 'session';
  static const String mutual = 'mutual';

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const SelectPage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: homepage,
              pageBuilder: (context, state) {
                return MaterialPage(child: HomePage(home: state.extra as Home));
                //homepage
              },
            ),
            GoRoute(
              path: profile,
              pageBuilder: (BuildContext context, GoRouterState state) {
                return MaterialPage(
                    child: ProfilePage(profile: state.extra as Profile));
              },
            ),
            GoRoute(
              path: login,
              builder: (BuildContext context, GoRouterState state) {
                return const LoginPage();
              },
            ),
            GoRoute(
              path: signup,
              builder: (BuildContext context, GoRouterState state) {
                return const SignUpPage();
              },
            ),
            GoRoute(
              path: forgot,
              builder: (BuildContext context, GoRouterState state) {
                return const ForgotPasswordPage();
              },
            ),
            GoRoute(
              path: picture,
              builder: (BuildContext context, GoRouterState state) {
                return const PictureSignPage();
              },
            ),
            GoRoute(
                path: session,
                builder: (BuildContext context, GoRouterState state) {
                  return SessionPage(host: state.extra as Host);
                }),
            GoRoute(
                path: mutual,
                builder: (BuildContext context, GoRouterState state) {
                  return const MutualPage();
                }),
          ]),
    ],
  );
}
