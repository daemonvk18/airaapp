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
    return BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
      builder: (context, historystate) {
        if (historystate is ChatLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (historystate is ChatHistoryLoaded) {
          // return ListView.builder(
          //   shrinkWrap: true, // Add this
          //   physics: ClampingScrollPhysics(), // Add this
          //   itemCount: state.history.length,
          //   itemBuilder: (context, index) {
          //     final message = state.history[index];
          //     bool isUser = message.role.toLowerCase() == "user";

          //     return Align(
          //       alignment: isUser
          //           ? Alignment.centerRight
          //           : Alignment.centerLeft, // Right for user, left for AI
          //       child: Container(
          //         margin: EdgeInsets.only(
          //             left: isUser ? 60 : 10, top: 5, bottom: 5, right: 10),
          //         padding: EdgeInsets.all(12),
          //         decoration: BoxDecoration(
          //           color: isUser
          //               ? Appcolors.greyblackcolor
          //               : Colors.transparent, // Blue for user, grey for AI
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Column(
          //           crossAxisAlignment: isUser
          //               ? CrossAxisAlignment.end
          //               : CrossAxisAlignment.start,
          //           children: [
          //             isUser
          //                 ? Text(message.message,
          //                     style: GoogleFonts.poppins(
          //                       textStyle: TextStyle(
          //                         fontSize:
          //                             MediaQuery.of(context).size.height * 0.02,
          //                         color: isUser
          //                             ? Appcolors.chatpagetextcolor
          //                             : Appcolors.chatpagetextcolor,
          //                       ),
          //                     ))
          //                 : MarkdownBody(
          //                     data: message.message,
          //                     styleSheet: MarkdownStyleSheet(
          //                       p: GoogleFonts.poppins(
          //                         textStyle: TextStyle(
          //                             fontWeight: FontWeight.w500,
          //                             fontSize:
          //                                 MediaQuery.of(context).size.height *
          //                                     0.02,
          //                             color: Appcolors.greytextcolor),
          //                       ),
          //                       strong: GoogleFonts.poppins(
          //                         textStyle: TextStyle(
          //                           fontWeight: FontWeight.bold,
          //                           fontSize:
          //                               MediaQuery.of(context).size.height *
          //                                   0.02,
          //                           color: Appcolors.greytextcolor,
          //                         ),
          //                       ),
          //                       h1: GoogleFonts.poppins(
          //                         textStyle: TextStyle(
          //                             fontWeight: FontWeight.w500,
          //                             fontSize:
          //                                 MediaQuery.of(context).size.height *
          //                                     0.02,
          //                             color: Appcolors.greytextcolor),
          //                       ),
          //                       h2: GoogleFonts.poppins(
          //                         textStyle: TextStyle(
          //                             fontWeight: FontWeight.w500,
          //                             fontSize:
          //                                 MediaQuery.of(context).size.height *
          //                                     0.02,
          //                             color: Appcolors.greytextcolor),
          //                       ),
          //                       h3: GoogleFonts.poppins(
          //                         textStyle: TextStyle(
          //                             fontWeight: FontWeight.w500,
          //                             fontSize:
          //                                 MediaQuery.of(context).size.height *
          //                                     0.02,
          //                             color: Appcolors.greytextcolor),
          //                       ),
          //                       blockquote: GoogleFonts.poppins(
          //                         textStyle: TextStyle(
          //                             fontWeight: FontWeight.w500,
          //                             fontSize:
          //                                 MediaQuery.of(context).size.height *
          //                                     0.02,
          //                             color: Appcolors.greytextcolor),
          //                       ),
          //                     ),
          //                   ),
          //             const Spacer(),
          //             //add the textfield here

          //             // Text(
          //             //   message.message,
          //             //   style: TextStyle(
          //             //     color: Appcolors.chatpagetextcolor,
          //             //   ),
          //             // ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // );
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                for (final message in historystate.history)
                  Container(
                    margin: EdgeInsets.only(
                      left: message.role.toLowerCase() == "user" ? 60 : 10,
                      right: message.role.toLowerCase() == "user" ? 10 : 60,
                      top: 5,
                      bottom: 5,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.role.toLowerCase() == "user"
                          ? Appcolors.greyblackcolor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: message.role.toLowerCase() == "user"
                          ? null
                          : Border.all(color: Appcolors.greyblackcolor),
                    ),
                    child: message.role.toLowerCase() == "user"
                        ? Text(
                            message.message,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: Appcolors.chatpagetextcolor,
                              ),
                            ),
                          )
                        : MarkdownBody(
                            data: message.message,
                            styleSheet: MarkdownStyleSheet(
                              p: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Appcolors.greytextcolor,
                                ),
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          );
        } else if (historystate is ChatError) {
          return Center(child: const Text("Error loading messages"));
        }
        return Center(child: const Text("No messages found"));
      },
    );
  }
}
