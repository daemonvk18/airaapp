import 'package:airaapp/app.dart';
import 'package:airaapp/features/auth/data/firebase_auth_repo.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

// import 'package:airaapp/app.dart';
// import 'package:airaapp/features/auth/data/firebase_auth_repo.dart';
// import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
// import 'package:airaapp/features/morningNotifications/presentation/services/background_task.dart';
// import 'package:device_preview/device_preview.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:workmanager/workmanager.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final authRepo = FirebaseAuthRepo();

//   // Initialize Workmanager
//   await Workmanager().initialize(
//     callbackDispatcher, // Top-level function
//     isInDebugMode: false,
//   );

//   // Schedule the task (don't call this in debug mode)
//   if (!kDebugMode) {
//     await Workmanager().registerPeriodicTask(
//       "dailyMotivationTask",
//       fetchMotivationTask,
//       frequency: const Duration(hours: 24),
//       constraints: Constraints(
//         networkType: NetworkType.connected,
//       ),
//       initialDelay: _calculateInitialDelay(const TimeOfDay(hour: 9, minute: 0)),
//     );
//   }

//   runApp(
//     DevicePreview(
//       enabled: !kReleaseMode,
//       builder: (context) => BlocProvider(
//         create: (context) =>
//             AuthCubit(authRepo, authRepo: authRepo)..checkauthenticated(),
//         child: const MyApp(),
//       ),
//     ),
//   );
// }

// Duration _calculateInitialDelay(TimeOfDay notificationTime) {
//   final now = DateTime.now();
//   var scheduledTime = DateTime(
//     now.year,
//     now.month,
//     now.day,
//     notificationTime.hour,
//     notificationTime.minute,
//   );

//   if (scheduledTime.isBefore(now)) {
//     scheduledTime = scheduledTime.add(const Duration(days: 1));
//   }

//   return scheduledTime.difference(now);
// }
