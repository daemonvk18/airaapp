import 'dart:convert';
import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/dailyReminders/presentation/pages/remiderpage.dart';
import 'package:airaapp/features/profile/domain/model/profile.dart';
import 'package:airaapp/features/profile/presentation/components/profile_page_buttons.dart';
import 'package:airaapp/features/profile/presentation/components/profileeditdialog.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_events.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _openEditDialog(ProfileModel profile) {
    showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
          password: profile.password,
          currentName: profile.name,
          currentEmail: profile.email,
          currentPhoto: profile.profilephoto,
          onSave: onSave),
    );
  }

  //load the streak and diapky it in the UI...
  Future<Map<String, bool>> getCurrentSreeak() async {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final startOfWeek = now.subtract(Duration(days: todayWeekday - 1));
    final streakStr = await _secureStorage.read(key: 'streak_days');
    final List<String> streakDays =
        streakStr != null ? List<String>.from(jsonDecode(streakStr)) : [];

    Map<String, bool> status = {};
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayStr = "${day.year}-${day.month}-${day.day}";
      final weekdayStr = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i];

      status[weekdayStr] = streakDays.contains(dayStr);
    }

    return status;
  }

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 Dispatching LoadProfile event...");
    context
        .read<ProfileBloc>()
        .add(LoadProfile()); // Dispatch event to load profile
    getCurrentSreeak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Appcolors.mainbgColor,
        appBar: AppBar(
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
                          FutureBuilder<Map<String, bool>>(
                            future: getCurrentSreeak(),
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
                                            "${profile.name}'s Streak",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
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
                              onTap: () {},
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
                              onTap: () {},
                              text: 'Vision Board'),
                          ProfilePageButton(
                              iconUrl: 'lib/data/assets/personal_info.svg',
                              onTap: () {},
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
