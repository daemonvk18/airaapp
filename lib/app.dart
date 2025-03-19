import 'package:airaapp/features/auth/data/firebase_auth_repo.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/auth/presentation/auth_states/authstate.dart';
import 'package:airaapp/features/auth/presentation/pages/auth_page.dart';
import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:airaapp/features/home/presentation/pages/home_page.dart';
import 'package:airaapp/features/profile/data/profile_repo.impl.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  final firebaseauthrepo = FirebaseAuthRepo();
  final chatrepo = ChatRepoImpl();
  final chatHistoryrepo = DataChatHistoryRepo();
  final profilerepo = ProfileRepoImpl();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                AuthCubit(authRepo: firebaseauthrepo)..checkauthenticated()),
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(create: (context) => ChatBloc(chatrepo: chatrepo)),
        BlocProvider(
            create: (context) => ChatHistoryBloc(
                  chatrepo: chatHistoryrepo,
                )),
        BlocProvider(create: (context) => ProfileBloc(profileRepo: profilerepo))
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<AuthCubit, AuthState>(builder: (context, authstate) {
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
        }),
      ),
    );
  }
}
