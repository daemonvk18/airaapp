import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
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
import 'package:airaapp/features/introsession/data/introsessionImpl.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessioncubit.dart';
import 'package:airaapp/features/introsession/presentation/pages/introsessionchatpage.dart';
import 'package:airaapp/features/profile/data/profile_repo.impl.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final NetworkService _networkService = NetworkService();
  bool _showIntroSession = false;

  // Initialize all repositories
  // ignore: unused_field
  late final FirebaseAuthRepo _authRepo;
  late final ChatRepoImpl _chatRepo;
  late final DataChatHistoryRepo _chatHistoryRepo;
  late final ProfileRepoImpl _profileRepo;
  late final IntrosessionImpl _introRepo;

  @override
  void initState() {
    super.initState();
    _initialize();
    print("✅ initState() is running");
  }

  Future<void> _initialize() async {
    _authRepo = FirebaseAuthRepo();
    _chatRepo = ChatRepoImpl();
    _chatHistoryRepo = DataChatHistoryRepo();
    _profileRepo = ProfileRepoImpl();
    _introRepo = IntrosessionImpl();

    await _checkAndRefreshToken();
    await _checkIfIntroSessionNeeded(); // Ensure this is awaited
  }

  Future<void> _checkAndRefreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) {
      if (mounted) {
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        context.read<AuthCubit>().emit(Unauthenticated());
      }
      return;
    }

    try {
      final response = await _networkService.postRequest(
        ApiConstants.refreshTokenEndpoint,
        {'refresh_token': refreshToken},
      );

      if (response.isNotEmpty && response.containsKey('access_token')) {
        await _secureStorage.write(
          key: 'session_token',
          value: response['access_token'],
        );
        if (mounted) {
          context.read<AuthCubit>().checkauthenticated();
        }
      } else {
        await _clearTokens();
      }
    } catch (e) {
      await _clearTokens();
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'session_token');
    if (mounted) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      context.read<AuthCubit>().emit(Unauthenticated());
    }
  }

  Future<void> _checkIfIntroSessionNeeded() async {
    print('checking if intro session needed');
    final token = await _secureStorage.read(key: 'emailid');
    final introCompleted =
        await _secureStorage.read(key: '${token}intro_completed');
    print('my introcompleted $introCompleted');
    if (introCompleted == null || introCompleted != 'true') {
      setState(() {
        _showIntroSession = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(
            create: (context) => ChatBloc(_chatRepo,
                repository: _chatRepo, chatHistoryRepo: _chatHistoryRepo)),
        BlocProvider(
            create: (context) =>
                ChatHistoryBloc(_chatHistoryRepo, chatrepo: _chatHistoryRepo)),
        BlocProvider(
            create: (context) =>
                ProfileBloc(_profileRepo, profileRepo: _profileRepo)),
        BlocProvider(
            create: (context) =>
                IntroSessionBloc(_introRepo, introRepo: _introRepo)),
      ],
      child: MaterialApp(
        // ignore: deprecated_member_use
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            if (authState is Unauthenticated) {
              return AuthPage();
            }
            if (authState is Authenticated) {
              return _showIntroSession
                  ? const IntroChatPage()
                  : const HomePage();
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
