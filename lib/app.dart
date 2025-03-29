import 'package:airaapp/authhandler.dart';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/features/auth/data/firebase_auth_repo.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/auth/presentation/auth_states/authstate.dart';
import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:airaapp/features/profile/data/profile_repo.impl.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final firebaseauthrepo = FirebaseAuthRepo();

  final chatrepo = ChatRepoImpl();

  final chatHistoryrepo = DataChatHistoryRepo();

  final profilerepo = ProfileRepoImpl();

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final _networkService = NetworkService();

  /// **🔹 Check and Refresh Token Before Authentication**
  Future<void> _checkAndRefreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');

    if (refreshToken != null) {
      try {
        final response = await _networkService.postRequest(
          ApiConstants.refreshTokenEndpoint,
          {'refresh_token': refreshToken},
        );

        if (response.isNotEmpty && response.containsKey('access_token')) {
          // Store new access token
          await _secureStorage.write(
              key: 'session_token', value: response['access_token']);

          // Trigger authentication check again
          if (mounted) {
            context.read<AuthCubit>().checkauthenticated();
          }
        } else {
          // If refresh token is invalid, force logout
          await _secureStorage.delete(key: 'refresh_token');
          await _secureStorage.delete(key: 'user_token');
          if (mounted) {
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            context.read<AuthCubit>().emit(Unauthenticated());
          }
        }
      } catch (e) {
        // Handle refresh token failure
        await _secureStorage.delete(key: 'refresh_token');
        await _secureStorage.delete(key: 'user_token');
        if (mounted) {
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          context.read<AuthCubit>().emit(Unauthenticated());
        }
      }
    } else {
      // No refresh token, go to login
      if (mounted) {
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        context.read<AuthCubit>().emit(Unauthenticated());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAndRefreshToken();
  }

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
          home: AuthHandler()
          //BlocConsumer<AuthCubit, AuthState>(builder: (context, authstate) {
          //   //return the widget based on the bloc state
          //   print(authstate);
          //   //if not authneticated
          //   if (authstate is Unauthenticated) {
          //     return AuthPage();
          //   }
          //   //if authenticated --> (home page)
          //   if (authstate is Authenticated) {
          //     return HomePage();
          //   } else {
          //     return Scaffold(
          //       body: Center(
          //         child: CircularProgressIndicator(),
          //       ),
          //     );
          //   }
          // }, listener: (context, authstate) {
          //   // does stuff based on the bloc state
          //   if (authstate is AuthError) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(content: Text(authstate.message.toString())));
          //   }
          // }),
          ),
    );
  }
}
