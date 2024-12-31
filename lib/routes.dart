import 'package:flutter/material.dart';
import 'package:ryanawe/main.dart';
import 'package:ryanawe/screens/home_screen.dart';
import 'package:ryanawe/screens/login_screen.dart';
import 'package:ryanawe/screens/sign_up_screen.dart';

Route onGeneratedRoute(RouteSettings settings) {
  return MaterialPageRoute(builder: (context) {
    switch (settings.name) {
      case '/auth_wrapper':
        return const AuthWrapper();
      case '/login_screen':
        return const LoginScreen();

      case '/sign_up_screen':
        return const SignUpScreen();

      case '/home_screen':
        return const HomeScreen();

      default:
        return const AuthWrapper();
    }
  });
}
