import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/home/presentation/pages/home_page.dart';
import 'package:airaapp/features/introsession/domain/entities/chat_message.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessioevents.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessioncubit.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessionstates.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class IntroChatPage extends StatelessWidget {
  const IntroChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // Initialize the chat when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntroSessionBloc>().add(StartIntroSession());
    });

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Appcolors.mainbgColor,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: Colors.black, // border color
              height: 1.0,
            ),
          ),
          title: Text(
            'Intro Session',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: height * 0.025,
                    color: Appcolors.maintextColor)),
          )),
      body: Column(
        children: [
          Expanded(child: _ChatMessages()),
          _ChatInputField(),
        ],
      ),
    );
  }
}

class _ChatMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IntroSessionBloc, IntroChatState>(
      listener: (context, state) {
        if (state is IntroChatCompleted) {
          //show the lottie for 3 sec and then move to homepage
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      },
      builder: (context, state) {
        if (state is IntroChatInitial || state is IntroChatLoading) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 3)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
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
                      child: Text(
                    "Processing...",
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Appcolors.textFiledtextColor,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.02)),
                  )),
                ); // You can replace this
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
                          width: MediaQuery.of(context).size.height * 0.05,
                          height: MediaQuery.of(context).size.height * 0.05,
                          fit: BoxFit.contain,
                        ),
                        //loading text
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
                );
              }
            },
          );
        }

        if (state is IntroChatError) {
          return Center(child: Text(state.message));
        }

        if (state is IntroChatMessageReceived) {
          if (state.isIntroComplete) {
            // Handle case where intro is already complete
            return const Center(child: Text('Intro already completed'));
          }
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
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              reverse: true,
              itemCount: state.chatSession.messages.length,
              itemBuilder: (context, index) {
                final message =
                    state.chatSession.messages.reversed.toList()[index];
                return _ChatBubble(message: message);
              },
            ),
          );
        }

        return Container();
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
            left: message.isUser ? 90 : 0,
            right: message.isUser ? 0 : 90,
            top: 4,
            bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Appcolors.lightdarlColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.content,
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: height * 0.016,
                    fontWeight: FontWeight.w500,
                    color: Appcolors.maintextColor))),
      ),
    );
  }
}

class _ChatInputField extends StatefulWidget {
  // ignore: unused_element
  const _ChatInputField({super.key});

  @override
  State<_ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<_ChatInputField> {
  final _controller = TextEditingController();
  bool _showEmojiPicker = false;

  Future<void> _onEmojiSelected(Emoji emoji) async {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  padding: EdgeInsets.all(10),
                  color: Appcolors.innerdarkcolor,
                  child: Row(
                    children: [
                      //emoji text option...
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _showEmojiPicker = !_showEmojiPicker;
                            });
                          },
                          icon: SvgPicture.asset("lib/data/assets/emoji.svg")),

                      //expaded textfield...
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: height * 0.057,
                            child: TextField(
                              cursorColor: Appcolors.maintextColor,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      color: Appcolors.maintextColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: height * 0.016)),
                              controller: _controller,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type your message...",
                                hintStyle: TextStyle(
                                    color: Appcolors.textFiledtextColor),
                              ),
                              onSubmitted: (_) {
                                context.read<IntroSessionBloc>().add(
                                      SendIntroMessage(
                                          message: _controller.text.trim()),
                                    );
                                _controller.clear();
                              },
                            ),
                          ),
                        ),
                      ),

                      //icon button to send the message
                      GestureDetector(
                          onTap: () {
                            context.read<IntroSessionBloc>().add(
                                  SendIntroMessage(
                                      message: _controller.text.trim()),
                                );
                            _controller.clear();
                          },
                          child: SvgPicture.asset(
                            "lib/data/assets/send.svg",
                            // ignore: deprecated_member_use
                            color: Appcolors.textFiledtextColor,
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showEmojiPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) {
                _onEmojiSelected(emoji);
              },
            ),
          ),
      ],
    );
  }
}
