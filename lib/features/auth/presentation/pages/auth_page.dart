import 'package:airaapp/features/auth/presentation/pages/login_page.dart';
import 'package:airaapp/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  //toggle function
  void toogle() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: () {
          toogle();
        },
      );
    } else {
      return RegisterPage(
        onTap: () {
          toogle();
        },
      );
    }
  }
}
