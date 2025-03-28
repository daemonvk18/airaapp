import 'dart:convert';

import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_states.dart';
import 'package:airaapp/features/chat/presentation/componenets/dislike_button.dart';
import 'package:airaapp/features/chat/presentation/componenets/like_button.dart';
import 'package:airaapp/features/profile/presentation/pages/profile_page.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textcontroller = TextEditingController();

  final secureStorage = FlutterSecureStorage();

  //final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();

  Map<String, bool> feedbackMap = {}; // Store feedback states

  //profile username
  String username = "";

  bool isWaitingForResponse = false; // ✅ Track API response waiting state

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatHistory());
    loadFeedback();
    getUser();
    _scrollToBottom();
  }

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

  //sendfeedback function
  Future<void> sendFeedback(
      String response_id, String feedback, String comment) async {
    if (response_id.isEmpty || response_id == "no_id") {
      print(
          "⚠ Invalid response_id: $response_id. Feedback cannot be submitted.");
      return;
    }
    final url = Uri.parse(ApiConstants.sendfeedbackpoint);
    final token = await secureStorage.read(key: 'session_token');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "response_id": response_id,
        "feedback_type": feedback,
        "comment": comment, // ✅ Sending comment along with feedback
      }),
    );
    if (response.statusCode == 200) {
      print(response.body);
      print("Feedback submitted successfully for: $response_id");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          "feedback_$response_id", feedback); //  Store as string
      await prefs.setString(
          "comment_$response_id", comment); // ✅ Store the comment
      //  Update the feedback in UI
      setState(() {
        feedbackMap[response_id] = (feedback == "like");
      });
    } else {
      print('Error submitting feedback');
    }
  }

  //load the feedback option
  Future<void> loadFeedback() async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, bool> loadedFeedback = {};

    for (var msg in messages) {
      final savedFeedback =
          prefs.getString("feedback_${msg.response_id}"); //Retrieve as String
      if (savedFeedback != null) {
        loadedFeedback[msg.response_id] =
            (savedFeedback == "like"); //Convert to bool
      }
    }

    // ✅ Ensure UI updates
    if (mounted) {
      setState(() {
        feedbackMap = loadedFeedback;
      });
    }

    print("Feedback loaded successfully.");
  }

  // Scroll to the bottom when a new message is added
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Appcolors.blackcolor,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'AIRA',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    color: Appcolors.greytextcolor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25)),
          ),
          backgroundColor: Appcolors.blackcolor,
          leading: Padding(
            padding: EdgeInsets.all(10), // Adjust padding as needed
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // Go back on tap
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                height: 50,
                width: 50,
                child: Icon(
                  CupertinoIcons.back,
                  color: Appcolors.logouttext,
                ),
                decoration: BoxDecoration(
                    color: Appcolors.greyblackcolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          actions: [
            //option to visit profile
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              showBackbutton: true,
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.12,
                  child: Center(
                    child: Text(
                      username.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Appcolors.greytextcolor)),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                      color: Appcolors.greyblackcolor,
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            //give some space before the profile section
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
            )
          ],
        ),
        body: Column(
          children: [
            //expanded
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) {
                    final newMessages = state.message ?? [];

                    setState(() {
                      messages = newMessages;
                      isWaitingForResponse = true;
                    });

                    //Ensure feedback is loaded after setting messages
                    Future.delayed(Duration(seconds: 2), loadFeedback);

                    // Simulate AI response delay using actual AI response time....
                    Future.delayed(Duration(seconds: 0), () {
                      setState(() {
                        isWaitingForResponse =
                            false; // Hide loading text once response arrives
                      });
                    });
                  }
                },
                builder: (context, state) {
                  print(state);
                  //loading state
                  if (state is ChatInitial) {
                    return Column(
                      children: [
                        //AIRA TEXT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('A',
                                style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: Appcolors.bluecolor))),
                            Text(
                              'IRA',
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: Appcolors.whitecolor)),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (state is ChatLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (state is ChatError) {
                    return Center(child: Text(state.message));
                  } else if (state is ChatLoaded) {
                    final newmessages = state.message ?? [];
                    _scrollToBottom();
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      //itemCount: newmessages.length,
                      itemCount: newmessages.length,
                      itemBuilder: (context, index) {
                        //temporary code(to show the loading....)
                        // if (index == newmessages.length &&
                        //     isWaitingForResponse) {
                        //   // Show loading message at the end
                        //   return Align(
                        //     alignment: Alignment.centerLeft,
                        //     child: Container(
                        //       margin: EdgeInsets.only(
                        //           left: 10, top: 5, bottom: 5, right: 10),
                        //       padding: const EdgeInsets.all(10),
                        //       decoration: BoxDecoration(
                        //         color: Colors.transparent,
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       child: Text(
                        //         isWaitingForResponse ? "Thinking..." : "",
                        //         style: GoogleFonts.poppins(
                        //           textStyle: TextStyle(
                        //             fontSize:
                        //                 MediaQuery.of(context).size.height *
                        //                     0.018,
                        //             color: Appcolors.whitecolor,
                        //             fontStyle: FontStyle.italic,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   );
                        // }

                        final message = newmessages[index];
                        return Align(
                          alignment: message.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: message.isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(
                                      left: message.isUser ? 60 : 10,
                                      top: 5,
                                      bottom: 5,
                                      right: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: message.isUser
                                        ? Appcolors.greyblackcolor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: message.isUser && !isWaitingForResponse
                                      ? Text(message.text,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.018,
                                                color: message.text ==
                                                        'Thinking...'
                                                    ? Appcolors.whitecolor
                                                    : Appcolors
                                                        .chatpagetextcolor),
                                          ))
                                      : MarkdownBody(
                                          data: message.text,
                                          styleSheet: MarkdownStyleSheet(
                                            p: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.02,
                                                  color:
                                                      Appcolors.greytextcolor),
                                            ),
                                            strong: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                                color: Appcolors.greytextcolor,
                                              ),
                                            ),
                                            h1: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.02,
                                                  color:
                                                      Appcolors.greytextcolor),
                                            ),
                                            h2: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.02,
                                                  color:
                                                      Appcolors.greytextcolor),
                                            ),
                                            h3: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.02,
                                                  color:
                                                      Appcolors.greytextcolor),
                                            ),
                                            blockquote: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.02,
                                                  color:
                                                      Appcolors.greytextcolor),
                                            ),
                                          ),
                                        )),
                              if (!message.isUser)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    LikeButton(
                                      onFeedback: showFeedbackDialog,
                                      response_id: message.response_id,
                                      isSelected:
                                          feedbackMap[message.response_id] ==
                                              true,
                                    ),
                                    DisLikeButton(
                                      onFeedback: showFeedbackDialog,
                                      responseId: message.response_id,
                                      isSelected:
                                          feedbackMap[message.response_id] ==
                                              false,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            //input field
            Row(
              children: [
                //textfield for sending message
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      enabled: !isWaitingForResponse,
                      style: TextStyle(color: Appcolors.whitecolor),
                      controller: textcontroller,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                if (textcontroller.text.trim().isNotEmpty) {
                                  context
                                      .read<ChatBloc>()
                                      .add(SendMessage(textcontroller.text));
                                  textcontroller.clear();
                                }
                              },
                              icon:
                                  SvgPicture.asset('lib/data/assets/send.svg')),
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Appcolors.greytextcolor),
                              borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Appcolors.whitecolor),
                              borderRadius: BorderRadius.circular(15)),
                          hintText: "Type your message...",
                          hintStyle: TextStyle(color: Appcolors.whitecolor)),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
          ],
        ));
  }

  //show dialog for taking the feedback
  void showFeedbackDialog(
      BuildContext context, String response_id, String feedbackType) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Provide Feedback"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter your comment about this response:"),
            SizedBox(height: 10),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Your comment...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final comment = commentController.text.trim();
              sendFeedback(response_id, feedbackType,
                  comment); // ✅ Send feedback + comment
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}
