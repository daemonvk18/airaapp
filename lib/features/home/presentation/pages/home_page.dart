import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/chat/presentation/pages/chatpage.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/presentation/pages/history_page.dart';
import 'package:airaapp/features/home/components/create_new_session_button.dart';
import 'package:airaapp/features/home/components/my_bottom_navigationbar.dart';
import 'package:airaapp/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:airaapp/features/home/presentation/home_events/home_event.dart';
import 'package:airaapp/features/home/presentation/home_states/home_states.dart';
import 'package:airaapp/features/profile/presentation/pages/profile_page.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //profile username
  String username = "";
  final chatRepo = ChatRepoImpl();
  final historyRepo = DataChatHistoryRepo();

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
      if (state is HomeLoading) {}

      return Scaffold(
        backgroundColor: Appcolors.blackcolor,
        drawer: HistoryPage(),
        body: SingleChildScrollView(
          child: Container(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //leave some space at the top
                SizedBox(height: currentIndex == 0 ? 20 : 0),
                //menu bar button to open the drawer
                if (currentIndex != 1)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Builder(
                      builder: (context) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () {
                            Scaffold.of(context)
                                .openDrawer(); // Now this context has access to the Scaffold
                          },
                          icon: SvgPicture.asset("lib/data/assets/menubar.svg"),
                        ),
                      ),
                    ),
                  ),

                //indexedstack for the pages
                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: [_buildhomescreen(context), ProfilePage()],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: MyBottomNavigation(
          currentIndex: currentIndex,
        ),
      );
    }));
  }

  Widget _buildhomescreen(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //aira logo
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Image.asset('lib/data/assets/homepageaira.png')),

        //welcome to aira text
        Text(
          "Welcome to",
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontSize: height * 0.04,
                  fontWeight: FontWeight.bold,
                  color: Appcolors.maintextColor)),
        ),
        Text('AIRA',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: height * 0.04,
                    fontWeight: FontWeight.w700,
                    color: Appcolors.maintextColor))),

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
                textAlign: TextAlign.center,
                maxLines: 5,
                overflow: TextOverflow.clip,
                "Hi, I'm AIRA — your thoughtful\ncompanion who listens, reflects, and\ngrows with you. Let's take on each\nday together, one meaningful\nconversation at a time.",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.maintextColor,
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        CreateNewSEssion(onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => ChatBloc(
                  repository: chatRepo,
                  chatRepo,
                  chatHistoryRepo: historyRepo,
                ),
                child: ChatPage(),
              ),
            ),
          );
        })
      ],
    );
  }
}
