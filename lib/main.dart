import 'package:airaapp/app.dart';
import 'package:airaapp/features/auth/data/firebase_auth_repo.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/dailyReminders/data/notification_services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //intialize the notifications
  NotiService().initNotifications();
  final authRepo = FirebaseAuthRepo();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => BlocProvider(
        create: (context) =>
            AuthCubit(authRepo, authRepo: authRepo)..checkauthenticated(),
        child: const MyApp(),
      ), // Wrap your app
    ),
  );
}
