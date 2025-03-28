import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatMessageView extends StatelessWidget {
  const ChatMessageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatHistoryBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ChatHistoryLoaded) {
          return ListView.builder(
            itemCount: state.history.length,
            itemBuilder: (context, index) {
              final message = state.history[index];
              bool isUser = message.role.toLowerCase() == "user";

              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft, // Right for user, left for AI
                child: Container(
                  margin: EdgeInsets.only(
                      left: isUser ? 60 : 10, top: 5, bottom: 5, right: 10),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Appcolors.greyblackcolor
                        : Colors.transparent, // Blue for user, grey for AI
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      isUser
                          ? Text(message.message,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.02,
                                  color: isUser
                                      ? Appcolors.chatpagetextcolor
                                      : Appcolors.chatpagetextcolor,
                                ),
                              ))
                          : MarkdownBody(
                              data: message.message,
                              styleSheet: MarkdownStyleSheet(
                                p: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                      color: Appcolors.greytextcolor),
                                ),
                                strong: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.02,
                                    color: Appcolors.greytextcolor,
                                  ),
                                ),
                                h1: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                      color: Appcolors.greytextcolor),
                                ),
                                h2: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                      color: Appcolors.greytextcolor),
                                ),
                                h3: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                      color: Appcolors.greytextcolor),
                                ),
                                blockquote: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                      color: Appcolors.greytextcolor),
                                ),
                              ),
                            )
                      // Text(
                      //   message.message,
                      //   style: TextStyle(
                      //     color: Appcolors.chatpagetextcolor,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is ChatError) {
          return Center(child: const Text("Error loading messages"));
        }
        return Center(child: const Text("No messages found"));
      },
    );
  }
}
