import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_event.dart';
import 'package:airaapp/features/history/presentation/pages/chatmessageview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessagePage extends StatefulWidget {
  final String sessionId;

  ChatMessagePage({super.key, required this.sessionId});

  @override
  State<ChatMessagePage> createState() => _ChatMessagePageState();
}

class _ChatMessagePageState extends State<ChatMessagePage> {
  //intialize a textcontroller for typing the message...
  final TextEditingController textcontroller = TextEditingController();
  //intialize a scrollcontroller for automatic scrolling...
  final ScrollController _scrollController = ScrollController();
  final chatrepo = DataChatHistoryRepo();

  Future<void> _sendMessage() async {
    final message = textcontroller.text.trim();
    if (message.isEmpty) return;

    context.read<ChatBloc>().add(SendMessage(message, widget.sessionId));
    textcontroller.clear();
    context.read<ChatHistoryBloc>().add(LoadChatHistoryEvent(widget.sessionId));
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
          leading: Padding(
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
          ),
          iconTheme: IconThemeData(color: Appcolors.whitecolor),
          backgroundColor: Appcolors.blackcolor,
          title: Text(
            "Chat Messages",
            style: GoogleFonts.urbanist(
                textStyle: TextStyle(
                    color: Appcolors.logouttext,
                    fontWeight: FontWeight.w600,
                    fontSize: 20)),
          )),
      body: Column(
        children: [
          //added expanded widget to maintain the free space for chatbubble and textfield
          Expanded(
            child: BlocProvider(
              create: (context) => ChatHistoryBloc(chatrepo: chatrepo, chatrepo)
                ..add(LoadChatHistoryEvent(widget.sessionId)),
              child: ChatMessageView(),
            ),
          ),

          // Input field area - fixed height content
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Appcolors.blackcolor, // Match your background
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Appcolors.whitecolor),
                    controller: textcontroller,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: _sendMessage,
                        icon: SvgPicture.asset('lib/data/assets/send.svg'),
                        padding: EdgeInsets.zero, // Remove default padding
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.greytextcolor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.whitecolor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: "Type your message...",
                      hintStyle: TextStyle(color: Appcolors.whitecolor),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
