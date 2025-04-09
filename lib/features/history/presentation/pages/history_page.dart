import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/pages/chatpage.dart';
import 'package:airaapp/features/history/components/history_buttons.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/domain/model/chat_session.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_event.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../chat/presentation/chat_bloc/chat_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final chatRepo = ChatRepoImpl();
  final historyRepo = DataChatHistoryRepo();
  @override
  void initState() {
    super.initState();
    debugPrint("Fetching all chat sessions...");
    Future.microtask(() {
      context.read<ChatHistoryBloc>().add(LoadChatSessions());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
          backgroundColor: Appcolors.mainbgColor,
          appBar: AppBar(
            backgroundColor: Appcolors.mainbgColor,
            centerTitle: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //add the aira logo
                Image.asset(
                  'lib/data/assets/homepageaira.png',
                  height: 25,
                  width: 25,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Chats',
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Appcolors.logouttext)),
                ),
              ],
            ),
            actions: [
              //navigate out of the page

              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Refresh the sessions list
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: BlocBuilder<ChatHistoryBloc, ChatHistoryState>(
            builder: ((context, state) {
              if (state is ChatLoading) {
                return CircularProgressIndicator();
              } else if (state is ChatSessionsLoaded) {
                return Column(
                  children: [
                    //add the create new session button
                    HistoryButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (context) => ChatBloc(
                                    repository: chatRepo,
                                    chatRepo,
                                    chatHistoryRepo: historyRepo)
                                  ..add(CreateNewSessionEvent()),
                                child: ChatPage(),
                              ),
                            ),
                          );
                        },
                        iconUrl: 'lib/data/assets/newsession.svg',
                        text: 'New session'),
                    //add the refresh button as well
                    HistoryButton(
                        onTap: () {
                          context
                              .read<ChatHistoryBloc>()
                              .add(LoadChatSessions());
                        },
                        iconUrl: "",
                        text: 'Refresh'),
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.sessions.length,
                        itemBuilder: (context, index) {
                          ChatSession session = state.sessions[index];
                          return ListTile(
                            leading: SvgPicture.asset(
                                'lib/data/assets/chatsessionicon.svg'),
                            title: Text(
                              session.title,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      color: Appcolors.maintextColor)),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => ChatBloc(
                                      repository: chatRepo,
                                      chatRepo,
                                      chatHistoryRepo: historyRepo,
                                    )..add(InitializeWithSession(
                                        session.sessionId)),
                                    child: ChatPage(
                                      sessionId: session.sessionId,
                                      sessionTitle: session.title,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
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
