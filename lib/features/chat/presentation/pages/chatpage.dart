import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_states.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
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
  final String? sessionId;
  final String? sessionTitle;
  ChatPage({super.key, this.sessionId, this.sessionTitle});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textcontroller = TextEditingController();
  final secureStorage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPicker = false;

  List<ChatMessage> messages = [];
  Map<String, Set<String>> feedbackMap =
      {}; // Changed to String to track all feedback types
  String username = "";
  String firstChar = "";

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      context.read<ChatBloc>().add(InitializeWithSession(widget.sessionId!));
    } else {
      context.read<ChatBloc>().add(CreateNewSessionEvent());
    }
    loadFeedback();
    getUser();
    _scrollToBottom();
  }

  Future<void> getUser() async {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      setState(() {
        username = state.profile.name;
        firstChar = state.profile.name.substring(0, 1).toUpperCase();
      });
    }
  }

  Future<void> _emojiSelected(Emoji emoji) async {
    textcontroller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textcontroller.text.length));
  }

  Future<void> _sendMessage() async {
    final message = textcontroller.text.trim();
    if (message.isEmpty) return;

    final chatBloc = context.read<ChatBloc>();
    final currentState = chatBloc.state;

    if (currentState is! ChatLoaded || currentState.sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session not initialized properly')),
      );
      return;
    }

    chatBloc.add(SendMessage(message, currentState.sessionId!));
    textcontroller.clear();
    _scrollToBottom();
  }

  Future<void> sendFeedback(String responseId, String feedbackType,
      {String comment = "", String responseTime = ""}) async {
    if (responseId.isEmpty || responseId == "no_id") return;

    final url = Uri.parse(ApiConstants.sendfeedbackpoint);
    final token = await secureStorage.read(key: 'session_token');

    // Prepare the request body based on feedback type
    Map<String, dynamic> requestBody = {
      "response_id": responseId,
      "feedback_type": feedbackType,
    };

    // Add additional fields based on feedback type
    if (feedbackType == "comment") {
      requestBody["comment"] = comment;
    } else if (feedbackType == "daily_reminders") {
      requestBody["response_time"] = responseTime; // morning/afternoon/night
      if (comment.isNotEmpty) {
        requestBody["comment"] = comment;
      }
    } else if (comment.isNotEmpty) {
      requestBody["comment"] = comment;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print(response);
      final prefs = await SharedPreferences.getInstance();

      // For like/dislike, remove opposite feedback if it exists
      if (feedbackType == "like") {
        feedbackMap[responseId]?.remove("dislike");
      } else if (feedbackType == "dislike") {
        feedbackMap[responseId]?.remove("like");
      }

      // Add the new feedback
      feedbackMap[responseId] ??= Set<String>();
      feedbackMap[responseId]!.add(feedbackType);

      // Save to preferences
      await prefs.setStringList(
          "feedback_$responseId", feedbackMap[responseId]!.toList());

      if (comment.isNotEmpty) {
        await prefs.setString("comment_$responseId", comment);
      }

      if (feedbackType == "daily_reminders") {
        await prefs.setString("reminder_time_$responseId", responseTime);
      }

      setState(() {});
    }
  }

  //load feedback function...
  Future<void> loadFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedFeedback = <String, Set<String>>{};

    for (var msg in messages) {
      final savedFeedback = prefs.getStringList("feedback_${msg.responseId}");
      if (savedFeedback != null) {
        loadedFeedback[msg.responseId] = Set<String>.from(savedFeedback);
      }
    }

    if (mounted) {
      setState(() {
        feedbackMap = loadedFeedback;
      });
    }
  }

  //scrollbottom function.....
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

  //comment function.....
  void _showCommentDialog(String responseId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Comment"),
        content: TextField(
          controller: commentController,
          decoration: InputDecoration(
            hintText: "Your comment...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final comment = commentController.text.trim();
              if (comment.isNotEmpty) {
                sendFeedback(responseId, "comment", comment: comment);
              }
              Navigator.pop(context);
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  //time selection function('daily_reminders')....
  void _showTimeSelectionDialog(String responseId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text("Morning"),
            onTap: () {
              sendFeedback(responseId, "daily_reminders",
                  responseTime: "morning");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Afternoon"),
            onTap: () {
              sendFeedback(responseId, "daily_reminders",
                  responseTime: "afternoon");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text("Night"),
            onTap: () {
              sendFeedback(responseId, "daily_reminders",
                  responseTime: "evening");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  //daily_reminders,goals,personal_info.....
  void _showMoreOptionsMenu(String responseId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Daily Reminders"),
            onTap: () {
              Navigator.pop(context);
              _showTimeSelectionDialog(responseId);
            },
          ),
          ListTile(
            leading: Icon(Icons.flag),
            title: Text("Goals"),
            onTap: () {
              sendFeedback(responseId, "goals");
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Personal Info"),
            onTap: () {
              sendFeedback(responseId, "personal_info");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.blackcolor,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            //small aira logo
            SizedBox(
                height: 41,
                width: 41,
                child: Image.asset('lib/data/assets/homepageaira.png')),
            SizedBox(
              width: 5,
            ),
            //aira text
            Text(
              'Aira',
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    color: Appcolors.textFiledtextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 25),
              ),
            ),
          ],
        ),
        backgroundColor: Appcolors.innerdarkcolor,
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Appcolors.maintextColor,
            )),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  messages = state.messages!;
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatInitial) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'A',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: Appcolors.bluecolor),
                            ),
                          ),
                          Text(
                            'IRA',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: Appcolors.whitecolor),
                            ),
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
                  _scrollToBottom();
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
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: state.messages!.length,
                      itemBuilder: (context, index) {
                        final message = state.messages![index];
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
                                child: message.isUser
                                    ? Text(message.text,
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.018,
                                              color:
                                                  message.text == 'Thinking...'
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
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                                color: Appcolors.greytextcolor),
                                          ),
                                          strong: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.02,
                                                color: Appcolors.greytextcolor),
                                          ),
                                          // ... other markdown styles ...
                                        ),
                                      ),
                              ),
                              if (!message.isUser &&
                                  message.text != 'Thinking...' &&
                                  !message.isFromHistory)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.thumb_up,
                                        color: feedbackMap[message.responseId]
                                                    ?.contains("like") ??
                                                false
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        sendFeedback(
                                            message.responseId, "like");
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.thumb_down,
                                        color: feedbackMap[message.responseId]
                                                    ?.contains("dislike") ??
                                                false
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        sendFeedback(
                                            message.responseId, "dislike");
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.comment,
                                        color: feedbackMap[message.responseId]
                                                    ?.contains("comment") ??
                                                false
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        _showCommentDialog(message.responseId);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.more_vert),
                                      onPressed: () {
                                        _showMoreOptionsMenu(
                                            message.responseId);
                                      },
                                    )
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Row(
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
                          child: TextField(
                            style: TextStyle(color: Appcolors.whitecolor),
                            controller: textcontroller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type your message...",
                              hintStyle: TextStyle(color: Appcolors.whitecolor),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),

                      //icon button to send the message
                      GestureDetector(
                          onTap: _sendMessage,
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ],
      ),
    );
  }
}
