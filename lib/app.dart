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
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final NetworkService _networkService = NetworkService();

  // Initialize all repositories
  // ignore: unused_field
  late final FirebaseAuthRepo _authRepo;
  late final ChatRepoImpl _chatRepo;
  late final DataChatHistoryRepo _chatHistoryRepo;
  late final ProfileRepoImpl _profileRepo;
  late final IntrosessionImpl _introRepo;
  late final ReminderRepositoryImpl _reminderRepo;
  late final VisionBoardImpl _visionBoardImpl;
  late final StoryRepositoryImpl _storyRepositoryImpl;
  late final SentimentRepositoryImpl _sentimentRepositoryImpl;

  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initialize();
    print("✅ initState() is running");
    Future.delayed(const Duration(seconds: 4), () {
      setState(() => _showSplash = false);
    });
  }

  Future<void> _initialize() async {
    _authRepo = FirebaseAuthRepo();
    _chatRepo = ChatRepoImpl();
    _chatHistoryRepo = DataChatHistoryRepo();
    _profileRepo = ProfileRepoImpl();
    _introRepo = IntrosessionImpl();
    _reminderRepo = ReminderRepositoryImpl();
    _visionBoardImpl = VisionBoardImpl();
    _storyRepositoryImpl = StoryRepositoryImpl();
    _sentimentRepositoryImpl = SentimentRepositoryImpl();

    await _checkAndRefreshToken(); // Ensure this is awaited
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => AuthCubit(_authRepo, authRepo: _authRepo)
              ..checkauthenticated()),
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
        BlocProvider(
            create: (context) =>
                ReminderBloc(reminderRepository: _reminderRepo)),
        BlocProvider(
            create: (context) => VisionBoardBloc(repository: _visionBoardImpl)),
        BlocProvider(
            create: (context) =>
                StoryBloc(storyRepository: _storyRepositoryImpl)),
        BlocProvider(
            create: (context) =>
                SentimentBloc(sentimentRepository: _sentimentRepositoryImpl))
      ],
      child: MaterialApp(
        // ignore: deprecated_member_use
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        home: _showSplash
            ? Scaffold(
                body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Appcolors.mainbgColor,
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.2),
                            BlendMode.dstATop,
                          ),
                          image: AssetImage(
                            'lib/data/assets/bgimage.jpeg',
                          ))),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'lib/data/assets/lottie/fire.json',
                          width: MediaQuery.of(context).size.height * 0.1,
                          height: MediaQuery.of(context).size.height * 0.1,
                          fit: BoxFit.contain,
                        ),
                        //add the loading text here
                        Text(
                          'Loading...',
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Appcolors.textFiledtextColor,
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.02)),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  if (authState is Unauthenticated) {
                    return AuthPage();
                  }
                  if (authState is Authenticated) {
                    return authState.needsIntroSession
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
