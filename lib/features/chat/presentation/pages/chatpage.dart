import 'dart:convert';
import 'package:airaapp/core/api_constants.dart';
import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_states.dart';
import 'package:airaapp/features/chat/presentation/pages/airaprofile.dart';
import 'package:airaapp/features/history/components/comment_section_button.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_bloc.dart';
import 'package:airaapp/features/profile/presentation/profilecubit/profile_state.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
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
  final FocusNode _focusNode = FocusNode();

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

  Future<void> _onEmojiSelected(Emoji emoji) async {
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

  // Calculate dynamic margin
  double calculateDynamicMargin(
      String text, BuildContext context, bool isUser) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Length thresholds
    const minMargin = 0.1; // 10% of screen
    const maxMargin = 0.4; // 40% of screen
    const minTextLength = 5;
    const maxTextLength = 100;

    // Clamp the text length
    final clampedLength = text.length.clamp(minTextLength, maxTextLength);

    // Map text length to margin (longer message => smaller margin)
    final marginFactor = maxMargin -
        ((clampedLength - minTextLength) / (maxTextLength - minTextLength)) *
            (maxMargin - minMargin);

    final margin = screenWidth * marginFactor;
    return isUser ? margin : screenWidth - margin - 25; // Adjust if needed
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
  // ignore: unused_element
  void _showCommentDialog(String responseId, BuildContext context) async {
    TextEditingController commentController = TextEditingController();
    final height = MediaQuery.of(context).size.height;
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Appcolors.innerdarkcolor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //icon
                      SvgPicture.asset(
                          "lib/data/assets/comment_context_icon.svg"),
                      const SizedBox(
                        width: 5,
                      ),
                      //context related text
                      Text(
                        'Whispher a Thought',
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: Appcolors.textFiledtextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: height * 0.019)),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Appcolors.textFiledtextColor),
                      color: Appcolors.deepdarColor, // Soft peach
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: Appcolors.maintextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: height * 0.016)),
                      controller: commentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Nice Replies, Loved them.",
                        hintStyle: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                color: Appcolors.textFiledtextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: height * 0.016)),
                      ),
                      cursorColor: Colors.black,
                      maxLines: 3,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommentSectionButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          text: 'cancel'),
                      CommentSectionButton(
                          onTap: () async {
                            final comment = commentController.text.trim();
                            if (comment.isNotEmpty) {
                              sendFeedback(responseId, "comment",
                                  comment: comment);
                            }
                            Navigator.pop(context);
                            _thanksCommetDialog(context);
                            await Future.delayed(Duration(seconds: 2));
                            Navigator.of(context).pop();
                          },
                          text: 'share it')
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  //thanks giving show of comment section
  void _thanksCommetDialog(BuildContext context) async {
    final height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Appcolors.innerdarkcolor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 270,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //show a row of icon and context heading...
                Row(
                  children: [
                    //icon
                    SvgPicture.asset(
                        "lib/data/assets/comment_context_icon.svg"),
                    const SizedBox(
                      width: 5,
                    ),
                    //context related text
                    Text(
                      'Whispher a Thought',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: Appcolors.textFiledtextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: height * 0.018)),
                    )
                  ],
                ),
                //context related text
                Text(
                  "Your words are a gift—\nthank you for sharing\nthem.",
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: Appcolors.textFiledtextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: height * 0.018)),
                )
              ],
            ),
          ),
        ),
      ),
    );
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
  }

  //time selection function('daily_reminders')....
  void _showTimeSelectionDialog(String responseId, BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Appcolors.innerdarkcolor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //leave some space here
            const SizedBox(
              height: 10,
            ),
            //show the context text here
            Text(
              'Hey, when works best for\nyour reminder?',
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      color: Appcolors.textFiledtextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: height * 0.019)),
            ),
            ListTile(
              hoverColor: Appcolors.deepdarColor,
              leading: SvgPicture.asset('lib/data/assets/morning.svg'),
              title: Text(
                "Morning",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.textFiledtextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: height * 0.018)),
              ),
              onTap: () {
                sendFeedback(responseId, "daily_reminders",
                    responseTime: "morning");
                Navigator.pop(context);
                _showLastDialogBox(context);
              },
            ),
            ListTile(
              hoverColor: Appcolors.deepdarColor,
              leading: Image.asset('lib/data/assets/afternoon.png'),
              title: Text(
                "Afternoon",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.textFiledtextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: height * 0.018)),
              ),
              onTap: () {
                sendFeedback(responseId, "daily_reminders",
                    responseTime: "afternoon");
                Navigator.pop(context);
                _showLastDialogBox(context);
              },
            ),
            ListTile(
              hoverColor: Appcolors.deepdarColor,
              leading: SvgPicture.asset('lib/data/assets/evening.svg'),
              title: Text(
                "Night",
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.textFiledtextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: height * 0.018)),
              ),
              onTap: () {
                sendFeedback(responseId, "daily_reminders",
                    responseTime: "evening");
                Navigator.pop(context);
                _showLastDialogBox(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLastDialogBox(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Appcolors.innerdarkcolor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 277,
          height: 155,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              children: [
                //show a row of icon and context heading...
                Row(
                  children: [
                    //icon
                    SvgPicture.asset("lib/data/assets/party.svg"),
                    const SizedBox(
                      width: 5,
                    ),
                    //context related text
                    Text(
                      'Yay!!',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              color: Appcolors.textFiledtextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: height * 0.019)),
                    )
                  ],
                ),
                //context related text
                Text(
                  maxLines: 5,
                  "This thought now glows gently in your Daily Sparks, ready to guide you when the time is right.",
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          color: Appcolors.textFiledtextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: height * 0.018)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //daily_reminders,goals,personal_info.....
  void _showMoreOptionsMenu(String responseId, BuildContext context) async {
    final height = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Appcolors.innerdarkcolor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //add the context text here
              Text(
                'Would you like me to\nadd this to your...',
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.textFiledtextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: height * 0.019)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: ListTile(
                  hoverColor: const Color(0xFFEDA89F),
                  leading:
                      SvgPicture.asset('lib/data/assets/chatsessionicon.svg'),
                  title: Text(
                    "Daily Reminders",
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: Appcolors.textFiledtextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: height * 0.018)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showTimeSelectionDialog(responseId, context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  hoverColor: const Color(0xFFEDA89F),
                  leading: SvgPicture.asset("lib/data/assets/vision_board.svg"),
                  title: Text(
                    "Goals",
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: Appcolors.textFiledtextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: height * 0.018)),
                  ),
                  onTap: () async {
                    sendFeedback(responseId, "goals");
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Appcolors.innerdarkcolor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: SizedBox(
                          width: 277,
                          height: 155,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //show a row of icon and context heading...
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //icon
                                    SvgPicture.asset(
                                        "lib/data/assets/party.svg"),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    //context related text
                                    Text(
                                      'Yay!!',
                                      style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              color:
                                                  Appcolors.textFiledtextColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: height * 0.019)),
                                    )
                                  ],
                                ),
                                //context related text
                                Text(
                                  "This dream now lives on\nyour Vision Board,\nquietly cheering you on.",
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          color: Appcolors.textFiledtextColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: height * 0.018)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                    await Future.delayed(Duration(seconds: 2));
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  hoverColor: const Color(0xFFEDA89F),
                  leading:
                      SvgPicture.asset("lib/data/assets/personal_info.svg"),
                  title: Text(
                    "Personal Info",
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            color: Appcolors.textFiledtextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: height * 0.018)),
                  ),
                  onTap: () async {
                    sendFeedback(responseId, "personal_info");
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Appcolors.innerdarkcolor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: SizedBox(
                          width: 260,
                          height: 164,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12),
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //show a row of icon and context heading...
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //icon
                                      SvgPicture.asset(
                                          "lib/data/assets/party.svg"),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      //context related text
                                      Text(
                                        'Yay!!',
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                color: Appcolors
                                                    .textFiledtextColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: height * 0.019)),
                                      )
                                    ],
                                  ),
                                  //context related text
                                  Text(
                                    "Woven into your Mind\nMap, this memory will\nguide you when needed.",
                                    style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                            color: Appcolors.textFiledtextColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: height * 0.018)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    await Future.delayed(Duration(seconds: 2));
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Appcolors.blackcolor,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            //small aira logo
            Image.asset(
              'lib/data/assets/airahomepage.png',
              height: height * 0.05,
              width: height * 0.05,
            ),
            const SizedBox(
              width: 6,
            ),
            //aira text
            Column(
              children: [
                Text(
                  'Aira',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.textFiledtextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: height * 0.021),
                  ),
                ),
                Text(
                  'online',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        color: Appcolors.textFiledtextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: height * 0.012),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Appcolors.innerdarkcolor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black, // border color
            height: 1.0,
          ),
        ),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Appcolors.maintextColor,
            )),
        actions: [
          //add the three dots icon to go to the aira profile page
          PopupMenuButton<String>(
            constraints: BoxConstraints(maxHeight: height * 0.07),
            color: Appcolors.innerdarkcolor,
            icon: Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'view_profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiraProfilePage(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view_profile',
                child: Text(
                  'View Profile',
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: height * 0.017,
                          fontWeight: FontWeight.w400,
                          color: Appcolors.maintextColor)),
                ),
              ),
            ],
          ),
        ],
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
                              image: const AssetImage(
                                  'lib/data/assets/bgimage.jpeg'),
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
                                        MediaQuery.of(context).size.height *
                                            0.02)),
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
                              image: const AssetImage(
                                  'lib/data/assets/bgimage.jpeg'),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'lib/data/assets/lottie/fire.json',
                                  width:
                                      MediaQuery.of(context).size.height * 0.08,
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                //loading text
                                Text(
                                  'Loading...',
                                  style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Appcolors.textFiledtextColor,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02)),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                } else if (state is ChatError) {
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
                      child: Center(child: Text(state.message)));
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
                      padding: const EdgeInsets.all(5),
                      itemCount: state.messages!.length,
                      itemBuilder: (context, index) {
                        final message = state.messages![index];
                        return Align(
                          alignment: message.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    minWidth: message.isUser ? 0 : 80,
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.8),
                                child: ChatBubble(
                                  clipper: ChatBubbleClipper1(
                                    type: message.isUser
                                        ? BubbleType.sendBubble
                                        : BubbleType.receiverBubble,
                                  ),
                                  alignment: message.isUser
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  margin: EdgeInsets.only(
                                      top: 8,
                                      bottom: 8,
                                      left: message.isUser
                                          ? calculateDynamicMargin(
                                              message.text, context, true)
                                          : 0,
                                      right: message.isUser
                                          ? 0
                                          : calculateDynamicMargin(
                                              message.text, context, true)),
                                  backGroundColor: Appcolors.innerdarkcolor,
                                  child: Column(
                                    children: [
                                      //display the user or ai message...
                                      message.isUser
                                          ? Text(message.text,
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.016,
                                                    color: message.text ==
                                                            'Thinking...'
                                                        ? Appcolors.whitecolor
                                                        : Appcolors
                                                            .maintextColor),
                                              ))
                                          : MarkdownBody(
                                              data: message.text,
                                              styleSheet: MarkdownStyleSheet(
                                                p: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.016,
                                                      color: Appcolors
                                                          .greytextcolor),
                                                ),
                                                strong: GoogleFonts.poppins(
                                                  textStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.016,
                                                      color: Appcolors
                                                          .greytextcolor),
                                                ),
                                                // ... other markdown styles ...
                                              ),
                                            ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Spacer(),
                                          //here the display the time
                                          if (message.text != 'Thinking...')
                                            Text(
                                              "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                                              style: GoogleFonts.poppins(
                                                textStyle: TextStyle(
                                                  color:
                                                      Appcolors.maintextColor,
                                                  fontSize: height * 0.01,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          //add some space such that it doesn't comw out
                                          SizedBox(
                                            width: height * 0.01,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //display all of the icons in here...(like,dislike,comment,threedots)
                              if (!message.isUser &&
                                  message.text != 'Thinking...' &&
                                  !message.isFromHistory)
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 10,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          // ignore: deprecated_member_use
                                          icon: SvgPicture.asset(
                                            "lib/data/assets/like.svg",
                                            height: height * 0.02,
                                            // ignore: deprecated_member_use
                                            color: feedbackMap[
                                                            message.responseId]
                                                        ?.contains("like") ??
                                                    false
                                                ? Appcolors.redColor
                                                : Appcolors.textFiledtextColor,
                                          ),
                                          onPressed: () async {
                                            sendFeedback(
                                                message.responseId, "like");
                                            //show the dialog box box for two seconds
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Dialog(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Container(
                                                    //width: 277,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            14),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF5D6D0), // light pink background
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: Appcolors
                                                            .textFiledtextColor, // soft grey border
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              "lib/data/assets/like_context.svg",
                                                              height: 20,
                                                              width: 20,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              'Love This',
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: Appcolors
                                                                      .maintextColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      height *
                                                                          0.018,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 15),
                                                        Text(
                                                          "Glad you liked it! I've got\nmore where that came\nfrom.",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            textStyle:
                                                                TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: height *
                                                                  0.018,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );

                                            await Future.delayed(
                                                const Duration(seconds: 2));
                                            Navigator.of(context)
                                                .pop(); // Close the dialog after 2 seconds
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        width: 10,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: SvgPicture.asset(
                                            "lib/data/assets/dislike.svg",
                                            height: height * 0.02,
                                            // ignore: deprecated_member_use
                                            color: feedbackMap[
                                                            message.responseId]
                                                        ?.contains("dislike") ??
                                                    false
                                                ? Appcolors.redColor
                                                : Appcolors.textFiledtextColor,
                                          ),
                                          onPressed: () async {
                                            sendFeedback(
                                                message.responseId, "dislike");
                                            //show the dialog box box for two seconds
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      height: height * 0.2,
                                                      decoration: BoxDecoration(
                                                          color: Appcolors
                                                              .innerdarkcolor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                              color: Appcolors
                                                                  .maintextColor)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(14.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            //row of icon and a caption...
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      height *
                                                                          0.056,
                                                                ),
                                                                //icon
                                                                SvgPicture.asset(
                                                                    "lib/data/assets/dislike_context.svg"),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  'Needs Work',
                                                                  style: GoogleFonts.poppins(
                                                                      textStyle: TextStyle(
                                                                          color: Appcolors
                                                                              .textFiledtextColor,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              height * 0.018)),
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            //text for like(context)...
                                                            Text(
                                                              "Every exchange helps\nme learn—I'll be even\nmore thoughtful next\ntime.",
                                                              style: GoogleFonts.poppins(
                                                                  textStyle: TextStyle(
                                                                      color: Appcolors
                                                                          .textFiledtextColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          height *
                                                                              0.017)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                });
                                            await Future.delayed(
                                                const Duration(seconds: 2));
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        width: 10,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: SvgPicture.asset(
                                            "lib/data/assets/comment.svg",
                                            height: height * 0.02,

                                            // ignore: deprecated_member_use
                                            color: feedbackMap[
                                                            message.responseId]
                                                        ?.contains("comment") ??
                                                    false
                                                ? Appcolors.redColor
                                                : Appcolors.textFiledtextColor,
                                          ),
                                          onPressed: () {
                                            _showCommentDialog(
                                                message.responseId, context);
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        width: 10,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: SvgPicture.asset(
                                            "lib/data/assets/copy.svg",
                                            height: height * 0.02,
                                          ),
                                          onPressed: () async {
                                            Clipboard.setData(ClipboardData(
                                                text: message.text));
                                            //show a dialog box for two secs...
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    backgroundColor: Appcolors
                                                        .innerdarkcolor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                    child: SizedBox(
                                                      height: 135,
                                                      width: 277,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          //show the birds,clouds...
                                                          SvgPicture.asset(
                                                              'lib/data/assets/copy_context.svg'),
                                                          //show the text context
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'Copied with care,',
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                        textStyle:
                                                                            TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.018,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Appcolors
                                                                      .textFiledtextColor,
                                                                )),
                                                              ),
                                                              Text(
                                                                'Your message is',
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                        textStyle:
                                                                            TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.018,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Appcolors
                                                                      .textFiledtextColor,
                                                                )),
                                                              ),
                                                              Text(
                                                                'ready to fly.',
                                                                style: GoogleFonts
                                                                    .poppins(
                                                                        textStyle:
                                                                            TextStyle(
                                                                  fontSize:
                                                                      height *
                                                                          0.018,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Appcolors
                                                                      .textFiledtextColor,
                                                                )),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                            await Future.delayed(
                                                const Duration(seconds: 2));
                                            Navigator.of(context)
                                                .pop(); // Close the dialog after 2 seconds
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        width: 10,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: SvgPicture.asset(
                                            "lib/data/assets/three_dots.svg",
                                            height: height * 0.02,
                                          ),
                                          onPressed: () {
                                            _showMoreOptionsMenu(
                                                message.responseId, context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
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
          if (widget.sessionTitle != 'Introduction Session')
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Appcolors.innerdarkcolor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Emoji button
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                            if (_showEmojiPicker) {
                              // Unfocus keyboard when emoji picker is shown
                              _focusNode.unfocus();
                            } else {
                              // Refocus if emoji picker is hidden (optional)
                              FocusScope.of(context).requestFocus(_focusNode);
                            }
                          });
                        },
                        icon: SvgPicture.asset("lib/data/assets/emoji.svg"),
                      ),

                      // Expanded TextField with auto height
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 40,
                            maxHeight: 150,
                          ),
                          child: Scrollbar(
                            child: TextField(
                              cursorColor: Appcolors.maintextColor,
                              focusNode: _focusNode,
                              controller: textcontroller,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      color: Appcolors.maintextColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: height * 0.016)),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type your message...",
                                hintStyle: TextStyle(
                                    color: Appcolors.textFiledtextColor),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                      ),

                      // Send button
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 10),
                          child: SvgPicture.asset(
                            "lib/data/assets/send.svg",
                            height: height * 0.026,
                            // ignore: deprecated_member_use
                            color: Appcolors.textFiledtextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Emoji picker if visible
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
            ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ],
      ),
    );
  }
}
