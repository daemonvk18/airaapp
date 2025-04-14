import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/dailyReminders/data/notification_services.dart';
import 'package:airaapp/features/dailyReminders/presentation/pages/remiderpage.dart';
import 'package:airaapp/features/mentalGrowth/presentation/pages/mentalGrowthpage.dart';
import 'package:airaapp/features/myStory/presentation/pages/mystorypage.dart';
import 'package:airaapp/features/profile/domain/model/profile.dart';
import 'package:airaapp/features/profile/presentation/components/profile_page_buttons.dart';
import 'package:airaapp/features/profile/presentation/components/profileeditdialog.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_events.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:airaapp/features/visionBoard/presentation/pages/visionboardpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final bool showBackbutton;
  const ProfilePage({super.key, this.showBackbutton = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  void onSave(
      String name, String email, String password, String profilePicture) {
    debugPrint(
      "📝 Updating Profile: Name=$name, Email=$email, Photo=$profilePicture , password=$password",
    );
    context.read<ProfileBloc>().add(
          UpdateProfile(
              profile: ProfileModel(
                  userId: "",
                  name: name,
                  email: email,
                  profilephoto: profilePicture,
                  password: password)),
        );
  }

  //get the body from the send motivation..
  String Motivationbody = "";

  void _openEditDialog(ProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) {
        bool isNotificationEnabled = true; // You can use a controller if needed

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Edit Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close current dialog
                      showDialog(
                        context: context,
                        builder: (context) => ProfileEditDialog(
                          password: profile.password,
                          currentName: profile.name,
                          currentEmail: profile.email,
                          currentPhoto: profile.profilephoto,
                          onSave: onSave,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Appcolors.deepdarColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Edit Profile',
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Appcolors.maintextColor)),
                        ),
                      ),
                    ),
                  ),

                  // Notifications Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      color: Appcolors.deepdarColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Notifications',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Appcolors.maintextColor))),
                        Switch(
                          value: isNotificationEnabled,
                          onChanged: (value) async {
                            setState(() {
                              isNotificationEnabled = value;
                              if (isNotificationEnabled) {
                                NotiService().scheduleMorningnotifications(
                                    title: 'Morning Notification',
                                    body: Motivationbody,
                                    hour: 9,
                                    minute: 00);
                              } else {
                                NotiService().cancelNotifications();
                              }
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Appcolors.innerdarkcolor,
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey[800],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //load the streak and diapky it in the UI...
  // Future<Map<String, bool>> getCurrentSreeak() async {
  //   final emailKey = await _secureStorage.read(key: 'emailid');
  //   if (emailKey == null) return {};

  //   final now = DateTime.now();
  //   final todayWeekday = now.weekday;
  //   final startOfWeek = now.subtract(Duration(days: todayWeekday - 1));

  //   final streakStr = await _secureStorage.read(key: 'streak_days_$emailKey');
  //   final List<String> streakDays =
  //       streakStr != null ? List<String>.from(jsonDecode(streakStr)) : [];

  //   Map<String, bool> status = {};
  //   for (int i = 0; i < 7; i++) {
  //     final day = startOfWeek.add(Duration(days: i));
  //     final dayStr = "${day.year}-${day.month}-${day.day}";
  //     final weekdayStr = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i];

  //     status[weekdayStr] = streakDays.contains(dayStr);
  //   }

  //   return status;
  // }
  Future<Map<String, bool>> getCurrentStreak() async {
    // ignore: unnecessary_cast
    final emailKey = await _secureStorage.read(key: 'emailid') as String?;
    if (emailKey == null) return {};

    final now = DateTime.now();

    // Get streak days with proper type handling
    final streakStr =
        // ignore: unnecessary_cast
        await _secureStorage.read(key: 'streak_days_$emailKey') as String?;
    List<String> streakDays = [];
    if (streakStr != null) {
      try {
        final decoded = jsonDecode(streakStr) as List<dynamic>;
        streakDays = decoded.map((e) => e.toString()).toList();
      } catch (e) {
        streakDays = [];
      }
    }

    // Get the last 7 days including today
    Map<String, bool> status = {};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStr = "${day.year}-${day.month}-${day.day}";
      final weekdayStr =
          ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][day.weekday - 1];

      status[weekdayStr] = streakDays.contains(dayStr);
    }

    return status;
  }

  Future<String> getMotivationMessage() async {
    final user_id = await _secureStorage.read(key: 'user_id_reminder');
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.sendMotivationEndpoint}?user_id=${user_id}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          Motivationbody = jsonResponse['message'];
        });
        return jsonResponse['message'] as String;
      } else {
        throw Exception('Failed to load motivation message');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 Dispatching LoadProfile event...");
    context
        .read<ProfileBloc>()
        .add(LoadProfile()); // Dispatch event to load profile
    getCurrentStreak();
    getMotivationMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Appcolors.mainbgColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // No back button when opened from BottomNavigation
          backgroundColor: Appcolors.mainbgColor,
          centerTitle: false,
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    color: Appcolors.maintextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 22)),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.black, // border color
              height: 1.0,
            ),
          ),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
            builder: ((context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                final profile = state.profile;
                return Container(
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 40, top: 20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Appcolors.whitecolor,
                                  child: Text(
                                    profile.name.substring(0, 1).toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                            color: Appcolors.blackcolor,
                                            fontSize: 50,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                //display the username and email as coulmn...
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        //first word capital
                                        Text(
                                          profile.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  color:
                                                      Appcolors.maintextColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Text(
                                          profile.name
                                              .substring(1)
                                              .toLowerCase(),
                                          style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  color:
                                                      Appcolors.maintextColor,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      profile.email,
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              color: Appcolors.maintextColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            color: Colors.black,
                          ),
                          //need to display the chittis streak
                          // Weekly Streak UI Here
                          FutureBuilder<Map<String, dynamic>>(
                            future: getCurrentStreak(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final data = snapshot.data!;
                              final totalStreakCount =
                                  data.values.where((v) => v).length;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Appcolors
                                      .innerdarkcolor, // Light red background
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.2)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      children: [
                                        Image.asset(
                                          'lib/data/assets/fire.png',
                                          height: 60,
                                          width: 90,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "$totalStreakCount Days",
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${profile.name[0].toUpperCase()}${profile.name.substring(1)}'s Streak",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Appcolors
                                                        .maintextColor),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: const Color(0xFFEDA89F)),
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children:
                                                  data.entries.map((entry) {
                                                final day = entry.key;
                                                final loggedIn = entry.value;
                                                return Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor: loggedIn
                                                          ? Colors.red
                                                          : Colors
                                                              .grey.shade300,
                                                      child: loggedIn
                                                          ? const Icon(
                                                              Icons.check,
                                                              size: 12,
                                                              color:
                                                                  Colors.white)
                                                          : null,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      day,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        color: Colors.black87,
                                                      ),
                                                    )
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                          ProfilePageButton(
                              iconUrl: 'lib/data/assets/mental_growth.svg',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MentalGrowthPage()));
                              },
                              text: 'Mental Growth'),
                          ProfilePageButton(
                              iconUrl: 'lib/data/assets/chatsessionicon.svg',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ReminderPage()));
                              },
                              text: 'Reminder Sparks'),
                          ProfilePageButton(
                              iconUrl: 'lib/data/assets/vision_board.svg',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            VisionBoardPage()));
                              },
                              text: 'Vision Board'),
                          ProfilePageButton(
                              iconUrl: 'lib/data/assets/personal_info.svg',
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StoryPage()));
                              },
                              text: 'Your Story'),
                          ProfilePageButton(
                              iconUrl: 'lib/data/assets/settings.svg',
                              onTap: () {
                                _openEditDialog(profile);
                              },
                              text: 'Settings'),
                          ProfilePageButton(
                              iconUrl: 'lib/data/assets/logout.svg',
                              onTap: () {
                                context.read<AuthCubit>().logout();
                              },
                              text: 'Logout')
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Center(
                    child: Text(
                  "Failed to load profile",
                  style: TextStyle(color: Appcolors.whitecolor),
                ));
              }
            }),
            listener: (context, state) {}));
  }
}
