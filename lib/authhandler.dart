import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/auth/presentation/auth_states/authstate.dart';
import 'package:airaapp/features/auth/presentation/pages/auth_page.dart';
import 'package:airaapp/features/home/presentation/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthHandler extends StatelessWidget {
  const AuthHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(builder: (context, authstate) {
      //return the widget based on the bloc state
      print(authstate);
      //if not authneticated
      if (authstate is Unauthenticated) {
        return AuthPage();
      }
      //if authenticated --> (home page)
      if (authstate is Authenticated) {
        return HomePage();
      } else {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
    }, listener: (context, authstate) {
      // does stuff based on the bloc state
      if (authstate is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authstate.message.toString())));
      }
    });
  }
}
