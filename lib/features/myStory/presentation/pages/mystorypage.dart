import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/myStory/presentation/bloc/story_events.dart';
import 'package:airaapp/features/myStory/presentation/bloc/story_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../bloc/story_bloc.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<StoryBloc>().add(GenerateStory());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Appcolors.mainbgColor,
        title: Text(
          'My Story',
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: height * 0.025,
                  color: Appcolors.maintextColor)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black, // border color
            height: 1.0,
          ),
        ),
      ),
      body: BlocConsumer<StoryBloc, StoryState>(
        listener: (context, state) {
          // You can use this for showing SnackBars or dialogs on error or success
          if (state is StoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is StoryInitial || state is StoryLoading) {
            return FutureBuilder(
              future: Future.delayed(const Duration(seconds: 3)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return const Center(
                      child: Text("Processing...")); // You can replace this
                } else {
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
                        image: const AssetImage('lib/data/assets/bgimage.jpeg'),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'lib/data/assets/lottie/fire.json',
                            width: height * 0.05,
                            height: height * 0.05,
                            fit: BoxFit.contain,
                          ),
                          //loading text
                          Text(
                            'Loading...',
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Appcolors.textFiledtextColor,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02)),
                          )
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          } else if (state is StoryLoaded) {
            return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Appcolors.mainbgColor,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        'lib/data/assets/grass.png',
                      ))),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //leave some space at the begining
                    SizedBox(
                      height: 10,
                    ),
                    //add the context text here
                    Text('Written by You, Guided by Dreams',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: height * 0.018,
                            fontWeight: FontWeight.w400,
                            color: Appcolors.maintextColor.withOpacity(0.6),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Appcolors.lightdarlColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //basic context text here
                            Text('This story will evolve as you do',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: height * 0.018,
                                    fontWeight: FontWeight.w700,
                                    color: Appcolors.maintextColor,
                                  ),
                                )),
                            //add a divider in between
                            Divider(
                              color: Appcolors.maintextColor,
                            ),
                            Text(
                              state.story.content,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: height * 0.018,
                                  fontWeight: FontWeight.w400,
                                  color: Appcolors.maintextColor,
                                ),
                              ),
                            ),
                            //add a copy button
                            IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: state.story.content));
                                },
                                icon: SvgPicture.asset(
                                  'lib/data/assets/copy.svg',
                                  height: 20,
                                  width: 20,
                                ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is StoryError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
