import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_event.dart';
import 'package:airaapp/features/history/presentation/pages/chatmessageview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessagePage extends StatelessWidget {
  final String sessionId;
  final chatrepo = DataChatHistoryRepo();
  ChatMessagePage({super.key, required this.sessionId});

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
      body: BlocProvider(
        create: (context) => ChatHistoryBloc(chatrepo: chatrepo, chatrepo)
          ..add(LoadChatHistory(sessionId)),
        child: ChatMessageView(),
      ),
    );
  }
}
