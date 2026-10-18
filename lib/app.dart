// import 'package:airaapp/core/api_constants.dart';
// import 'package:airaapp/core/network_service.dart';
// import 'package:airaapp/data/colors.dart';
// import 'package:airaapp/features/auth/data/firebase_auth_repo.dart';
// import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
// import 'package:airaapp/features/auth/presentation/auth_states/authstate.dart';
// import 'package:airaapp/features/auth/presentation/pages/auth_page.dart';
// import 'package:airaapp/features/chat/data/data_chat_repo.dart';
// import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
// import 'package:airaapp/features/dailyReminders/data/reminder_repo_impl.dart';
// import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_bloc.dart';
// import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
// import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
// import 'package:airaapp/features/home/presentation/home_bloc/home_bloc.dart';
// import 'package:airaapp/features/home/presentation/pages/home_page.dart';
// import 'package:airaapp/features/introsession/data/introsessionImpl.dart';
// import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessioncubit.dart';
// import 'package:airaapp/features/introsession/presentation/pages/introsessionchatpage.dart';
// import 'package:airaapp/features/mentalGrowth/data/sentiment_repo_impl.dart';
// import 'package:airaapp/features/mentalGrowth/presentation/bloc/sentiment_bloc.dart';
// import 'package:airaapp/features/myStory/data/story_impl.dart';
// import 'package:airaapp/features/myStory/presentation/bloc/story_bloc.dart';
// import 'package:airaapp/features/profile/data/profile_repo.impl.dart';
// import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
// import 'package:airaapp/features/visionBoard/data/visionBoard_impl.dart';
// import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_bloc.dart';
// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
//   final NetworkService _networkService = NetworkService();

//   // Initialize all repositories
//   // ignore: unused_field
//   late final FirebaseAuthRepo _authRepo;
//   late final ChatRepoImpl _chatRepo;
//   late final DataChatHistoryRepo _chatHistoryRepo;
//   late final ProfileRepoImpl _profileRepo;
//   late final IntrosessionImpl _introRepo;
//   late final ReminderRepositoryImpl _reminderRepo;
//   late final VisionBoardImpl _visionBoardImpl;
//   late final StoryRepositoryImpl _storyRepositoryImpl;
//   late final SentimentRepositoryImpl _sentimentRepositoryImpl;

//   bool _showSplash = true;

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//     print("✅ initState() is running");
//     Future.delayed(const Duration(seconds: 4), () {
//       setState(() => _showSplash = false);
//     });
//   }

//   Future<void> _initialize() async {
//     _authRepo = FirebaseAuthRepo();
//     _chatRepo = ChatRepoImpl();
//     _chatHistoryRepo = DataChatHistoryRepo();
//     _profileRepo = ProfileRepoImpl();
//     _introRepo = IntrosessionImpl();
//     _reminderRepo = ReminderRepositoryImpl();
//     _visionBoardImpl = VisionBoardImpl();
//     _storyRepositoryImpl = StoryRepositoryImpl();
//     _sentimentRepositoryImpl = SentimentRepositoryImpl();

//     await _checkAndRefreshToken(); // Ensure this is awaited
//   }

//   Future<void> _checkAndRefreshToken() async {
//     final refreshToken = await _secureStorage.read(key: 'refresh_token');
//     if (refreshToken == null) {
//       if (mounted) {
//         // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
//         context.read<AuthCubit>().emit(Unauthenticated());
//       }
//       return;
//     }

//     try {
//       final response = await _networkService.postRequest(
//         ApiConstants.refreshTokenEndpoint,
//         {'refresh_token': refreshToken},
//       );

//       if (response.isNotEmpty && response.containsKey('access_token')) {
//         await _secureStorage.write(
//           key: 'session_token',
//           value: response['access_token'],
//         );
//         if (mounted) {
//           context.read<AuthCubit>().checkauthenticated();
//         }
//       } else {
//         await _clearTokens();
//       }
//     } catch (e) {
//       await _clearTokens();
//     }
//   }

//   Future<void> _clearTokens() async {
//     await _secureStorage.delete(key: 'refresh_token');
//     await _secureStorage.delete(key: 'session_token');
//     if (mounted) {
//       // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
//       context.read<AuthCubit>().emit(Unauthenticated());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//             create: (context) => AuthCubit(_authRepo, authRepo: _authRepo)
//               ..checkauthenticated()),
//         BlocProvider(create: (context) => HomeBloc()),
//         BlocProvider(
//             create: (context) => ChatBloc(_chatRepo,
//                 repository: _chatRepo, chatHistoryRepo: _chatHistoryRepo)),
//         BlocProvider(
//             create: (context) =>
//                 ChatHistoryBloc(_chatHistoryRepo, chatrepo: _chatHistoryRepo)),
//         BlocProvider(
//             create: (context) =>
//                 ProfileBloc(_profileRepo, profileRepo: _profileRepo)),
//         BlocProvider(
//             create: (context) =>
//                 IntroSessionBloc(_introRepo, introRepo: _introRepo)),
//         BlocProvider(
//             create: (context) =>
//                 ReminderBloc(reminderRepository: _reminderRepo)),
//         BlocProvider(
//             create: (context) => VisionBoardBloc(repository: _visionBoardImpl)),
//         BlocProvider(
//             create: (context) =>
//                 StoryBloc(storyRepository: _storyRepositoryImpl)),
//         BlocProvider(
//             create: (context) =>
//                 SentimentBloc(sentimentRepository: _sentimentRepositoryImpl))
//       ],
//       child: MaterialApp(
//         // ignore: deprecated_member_use
//         useInheritedMediaQuery: true,
//         locale: DevicePreview.locale(context),
//         builder: DevicePreview.appBuilder,
//         debugShowCheckedModeBanner: false,
//         home: _showSplash
//             ? Scaffold(
//                 body: Container(
//                   height: MediaQuery.of(context).size.height,
//                   width: MediaQuery.of(context).size.width,
//                   decoration: BoxDecoration(
//                       color: Appcolors.mainbgColor,
//                       image: DecorationImage(
//                           fit: BoxFit.cover,
//                           colorFilter: ColorFilter.mode(
//                             Colors.black.withOpacity(0.2),
//                             BlendMode.dstATop,
//                           ),
//                           image: AssetImage(
//                             'lib/data/assets/bgimage.jpeg',
//                           ))),
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Lottie.asset(
//                           'lib/data/assets/lottie/fire.json',
//                           width: MediaQuery.of(context).size.height * 0.1,
//                           height: MediaQuery.of(context).size.height * 0.1,
//                           fit: BoxFit.contain,
//                         ),
//                         //add the loading text here
//                         Text(
//                           'Loading...',
//                           style: GoogleFonts.poppins(
//                               textStyle: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: Appcolors.textFiledtextColor,
//                                   fontSize: MediaQuery.of(context).size.height *
//                                       0.02)),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             : BlocBuilder<AuthCubit, AuthState>(
//                 builder: (context, authState) {
//                   if (authState is Unauthenticated) {
//                     return AuthPage();
//                   }
//                   if (authState is Authenticated) {
//                     return authState.needsIntroSession
//                         ? const IntroChatPage()
//                         : const HomePage();
//                   }
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }

import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/core/network_service.dart';
import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/auth/data/firebase_auth_repo.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/auth/presentation/auth_states/authstate.dart';
import 'package:airaapp/features/auth/presentation/pages/auth_page.dart';
import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/dailyReminders/data/reminder_repo_impl.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_bloc.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:airaapp/features/home/presentation/pages/home_page.dart';
import 'package:airaapp/features/introsession/data/introsessionImpl.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessioncubit.dart';
import 'package:airaapp/features/introsession/presentation/pages/introsessionchatpage.dart';
import 'package:airaapp/features/mentalGrowth/data/sentiment_repo_impl.dart';
import 'package:airaapp/features/mentalGrowth/presentation/bloc/sentiment_bloc.dart';
import 'package:airaapp/features/myStory/data/story_impl.dart';
import 'package:airaapp/features/myStory/presentation/bloc/story_bloc.dart';
import 'package:airaapp/features/profile/data/profile_repo.impl.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/visionBoard/data/visionBoard_impl.dart';
import 'package:airaapp/features/visionBoard/presentation/bloc/visiongoal_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();
  final NetworkService _network = NetworkService();

  late final FirebaseAuthRepo _authRepo;
  late final ChatRepoImpl _chatRepo;
  late final DataChatHistoryRepo _historyRepo;
  late final ProfileRepoImpl _profileRepo;
  late final IntrosessionImpl _introRepo;
  late final ReminderRepositoryImpl _reminderRepo;
  late final VisionBoardImpl _visionRepo;
  late final StoryRepositoryImpl _storyRepo;
  late final SentimentRepositoryImpl _sentimentRepo;

  bool _isLoading = true;
  bool _initializationComplete = false;

  @override
  void initState() {
    super.initState();
    _setupApplication();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _setupApplication() async {
    _authRepo = FirebaseAuthRepo();
    _chatRepo = ChatRepoImpl();
    _historyRepo = DataChatHistoryRepo();
    _profileRepo = ProfileRepoImpl();
    _introRepo = IntrosessionImpl();
    _reminderRepo = ReminderRepositoryImpl();
    _visionRepo = VisionBoardImpl();
    _storyRepo = StoryRepositoryImpl();
    _sentimentRepo = SentimentRepositoryImpl();

    try {
      await _refreshSession();
    } finally {
      if (mounted) {
        setState(() {
          _initializationComplete = true;
        });
      }
    }
  }

  Future<void> _refreshSession() async {
    try {
      final storedRefreshToken =
          await _storage.read(key: 'refresh_token');

      if (storedRefreshToken == null ||
          storedRefreshToken.trim().isEmpty) {
        _setUnauthenticated();
        return;
      }

      final result = await _network.postRequest(
        ApiConstants.refreshTokenEndpoint,
        {'refresh_token': storedRefreshToken},
      );

      final newAccessToken = result['access_token'];

      if (result.isNotEmpty &&
          newAccessToken is String &&
          newAccessToken.isNotEmpty) {
        await _storage.write(
          key: 'session_token',
          value: newAccessToken,
        );

        if (mounted) {
          context.read<AuthCubit>().checkauthenticated();
        }
      } else {
        await _removeSession();
      }
    } catch (error, stackTrace) {
      debugPrint('Session refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      await _removeSession();
    }
  }

  void _setUnauthenticated() {
    if (!mounted) return;

    context.read<AuthCubit>().emit(Unauthenticated());
  }

  Future<void> _removeSession() async {
    try {
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'session_token');
    } catch (error) {
      debugPrint('Failed to clear stored session: $error');
    }

    _setUnauthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            _authRepo,
            authRepo: _authRepo,
          )..checkauthenticated(),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(
            _chatRepo,
            repository: _chatRepo,
            chatHistoryRepo: _historyRepo,
          ),
        ),
        BlocProvider<ChatHistoryBloc>(
          create: (_) => ChatHistoryBloc(
            _historyRepo,
            chatrepo: _historyRepo,
          ),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            _profileRepo,
            profileRepo: _profileRepo,
          ),
        ),
        BlocProvider<IntroSessionBloc>(
          create: (_) => IntroSessionBloc(
            _introRepo,
            introRepo: _introRepo,
          ),
        ),
        BlocProvider<ReminderBloc>(
          create: (_) => ReminderBloc(
            reminderRepository: _reminderRepo,
          ),
        ),
        BlocProvider<VisionBoardBloc>(
          create: (_) => VisionBoardBloc(
            repository: _visionRepo,
          ),
        ),
        BlocProvider<StoryBloc>(
          create: (_) => StoryBloc(
            storyRepository: _storyRepo,
          ),
        ),
        BlocProvider<SentimentBloc>(
          create: (_) => SentimentBloc(
            sentimentRepository: _sentimentRepo,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Appcolors.mainbgColor,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: _isLoading || !_initializationComplete
            ? _buildSplashScreen(context)
            : _buildMainScreen(),
      ),
    );
  }

  Widget _buildSplashScreen(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Appcolors.mainbgColor,
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        decoration: BoxDecoration(
          color: Appcolors.mainbgColor,
          image: DecorationImage(
            image: const AssetImage(
              'lib/data/assets/bgimage.jpeg',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.25),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'lib/data/assets/lottie/fire.json',
                width: screenSize.height * 0.12,
                height: screenSize.height * 0.12,
                fit: BoxFit.contain,
                repeat: true,
              ),
              const SizedBox(height: 18),
              Text(
                'Preparing your experience...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: screenSize.height * 0.019,
                  fontWeight: FontWeight.w600,
                  color: Appcolors.textFiledtextColor,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.white24,
                  color: Appcolors.textFiledtextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Unauthenticated) {
          return AuthPage();
        }

        if (state is Authenticated) {
          if (state.needsIntroSession) {
            return const IntroChatPage();
          }

          return const HomePage();
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
