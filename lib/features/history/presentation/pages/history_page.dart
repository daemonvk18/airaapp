import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/pages/chatpage.dart';
import 'package:airaapp/features/history/domain/model/chat_session.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_event.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_state.dart';
import 'package:airaapp/features/history/presentation/pages/chatmessagepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../chat/presentation/chat_bloc/chat_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final chatRepo = ChatRepoImpl();
  @override
  void initState() {
    super.initState();
    debugPrint("Fetching all chat sessions...");
    context.read<ChatHistoryBloc>().add(LoadChatSessions());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     context.read<ChatHistoryBloc>().add(LoadChatHistory());
          //   },
          //   child: const Icon(Icons.refresh),
          // ),
          backgroundColor: Appcolors.blackcolor,
          appBar: AppBar(
            backgroundColor: Appcolors.blackcolor,
            centerTitle: false,
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('H',
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Appcolors.logouttext))),
                Text(
                  'istory',
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Appcolors.logouttext)),
                ),
              ],
            ),
            actions: [
              //button for creating new session...
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Create New Session',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) =>
                            ChatBloc(repository: chatRepo, chatRepo)
                              ..add(CreateNewSessionEvent()),
                        child: ChatPage(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<ChatHistoryBloc, ChatState>(
            builder: ((context, state) {
              if (state is ChatLoading) {
                return CircularProgressIndicator();
              } else if (state is ChatSessionsLoaded) {
                return ListView.builder(
                  itemCount: state.sessions.length,
                  itemBuilder: (context, index) {
                    ChatSession session = state.sessions[index];
                    return ListTile(
                      title: Text(
                        session.title,
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(color: Appcolors.whitecolor)),
                      ),
                      //
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatMessagePage(
                                      sessionId: session.sessionId,
                                    )));
                      },
                    );
                  },
                );
              } else if (state is ChatError) {
                return Text(state.message);
              }
              return Container();
            }),
          )),
    );
  }
}
