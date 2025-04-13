import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/myStory/presentation/bloc/story_events.dart';
import 'package:airaapp/features/myStory/presentation/bloc/story_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          backgroundColor: Appcolors.mainbgColor,
          title: Text(
            'Your Story',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Appcolors.maintextColor)),
          )),
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
                    child: CircularProgressIndicator(
                  color: Appcolors.deepdarColor,
                )));
          } else if (state is StoryLoaded) {
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
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Appcolors.maintextColor,
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
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
                                    fontSize: 16,
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
                                  fontSize: 16,
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
