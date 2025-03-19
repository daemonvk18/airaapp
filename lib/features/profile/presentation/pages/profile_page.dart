import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/profile/domain/model/profile.dart';
import 'package:airaapp/features/profile/presentation/components/profileeditdialog.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_events.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final bool showBackbutton;
  const ProfilePage({super.key, this.showBackbutton = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void onSave(
      String name, String email, String password, String profilePicture) {
    debugPrint(
      "📝 Updating Profile: Name=$name, Email=$email, Photo=$profilePicture , password=$password",
    );
    context.read<ProfileBloc>().add(
          UpdateProfile(
              profile: ProfileModel(
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

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 Dispatching LoadProfile event...");
    context
        .read<ProfileBloc>()
        .add(LoadProfile()); // Dispatch event to load profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Appcolors.blackcolor,
        appBar: AppBar(
          leading: widget.showBackbutton
              ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context), // Go back on tap
                    child: Container(
                      //padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      height: 25,
                      width: 25,
                      child: Icon(
                        CupertinoIcons.back,
                        color: Appcolors.logouttext,
                      ),
                      decoration: BoxDecoration(
                          color: Appcolors.greyblackcolor,
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              : null, // No back button when opened from BottomNavigation
          backgroundColor: Appcolors.blackcolor,
          centerTitle: true,
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    color: Appcolors.logouttext,
                    fontWeight: FontWeight.w500,
                    fontSize: 22)),
          ),
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
            builder: ((context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                final profile = state.profile;
                return Center(
                  child: Column(
                    children: [
                      //leave some space at the starting
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          //instead of showing the default photo lets just keep the starting letter as image
                          CircleAvatar(
                            radius: 50,
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //first word capital
                          Text(
                            profile.name.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Appcolors.profilenametext,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Text(
                            profile.name.substring(1).toLowerCase(),
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Appcolors.profilenametext,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Text(
                        profile.email,
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: Appcolors.greytextcolor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          _openEditDialog(profile);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: Appcolors.greyblackcolor,
                              borderRadius: BorderRadius.circular(7)),
                          child: Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Appcolors.logouttext,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.37)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthCubit>().logout();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: Appcolors.greyblackcolor,
                              borderRadius: BorderRadius.circular(7)),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    color: Appcolors.logouttext,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.37)),
                          ),
                        ),
                      )
                    ],
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
