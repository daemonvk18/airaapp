import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/chat/presentation/pages/chatpage.dart';
import 'package:airaapp/features/history/presentation/pages/history_page.dart';
import 'package:airaapp/features/home/components/my_bottom_navigationbar.dart';
import 'package:airaapp/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:airaapp/features/home/presentation/home_events/home_event.dart';
import 'package:airaapp/features/home/presentation/home_states/home_states.dart';
import 'package:airaapp/features/profile/presentation/pages/profile_page.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //profile username
  String username = "";

  //get the user name
  Future<void> getUser() async {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      setState(() {
        print(state.profile.name);
        username = state.profile.name;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    //final screenHeight = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocConsumer<HomeBloc, HomeState>(listener: (context, state) {
      if (state is ChatPageOpened) {
        Navigator.push(
                context, MaterialPageRoute(builder: (context) => ChatPage()))
            .then((_) {
          // Reset Bloc State when coming back to HomePage
          context.read<HomeBloc>().add(ResetHomeState());
        });
      }
    }, builder: ((context, state) {
      int currentIndex = 0;
      if (state is HomeTabChanged) {
        currentIndex = state.index;
      }

      return Scaffold(
        backgroundColor: Appcolors.blackcolor,
        drawer: HistoryPage(),
        appBar: currentIndex == 1
            ? null
            : AppBar(
                backgroundColor: Appcolors.blackcolor,
                leading: Builder(
                  // Use Builder to access Scaffold context
                  builder: (context) => GestureDetector(
                    onTap: () =>
                        Scaffold.of(context).openDrawer(), // Go back on tap
                    child: Padding(
                      padding: const EdgeInsets.all(5.5),
                      child: Container(
                        child: Icon(
                          Icons.menu,
                          color: Appcolors.logouttext,
                        ),
                        decoration: BoxDecoration(
                            color: Appcolors.greyblackcolor,
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ),
              ),
        body: IndexedStack(
          index: currentIndex,
          children: [_buildhomescreen(context), ProfilePage()],
        ),
        bottomNavigationBar: MyBottomNavigation(
          currentIndex: currentIndex,
        ),
      );
    }));
  }

  Widget _buildhomescreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //aira logo
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Image.asset('lib/data/assets/airahomepage.png')),

        //welcome to aira text
        Text(
          "Welcome to",
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Appcolors.whitecolor)),
        ),
        Text('AIRA',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Appcolors.usernamehometext))),

        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),

        //starting chating with app.....(text)
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "AIRA helps you navigate stress, boost",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.whitecolor,
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.w500)),
              ),
              Text(
                "confidence, and build a healthier mind",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.whitecolor,
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.w500)),
              ),
              Text(
                "with AI-driven insights.",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.whitecolor,
                        fontSize: MediaQuery.of(context).size.height * 0.02,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        ),
        // //get started button
        // GetStartedButton(
        //     onTap: () {
        //       context.read<HomeBloc>().add(NavigateToChat());
        //     },
        //     text: "Get Started")
      ],
    );
  }
}
