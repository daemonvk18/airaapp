// ... (all your imports remain the same)

import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/chat/data/data_chat_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_bloc.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/pages/chatpage.dart';
import 'package:airaapp/features/history/components/history_buttons.dart';
import 'package:airaapp/features/history/data/data_chathistory_repo.dart';
import 'package:airaapp/features/history/domain/model/chat_session.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_bloc.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_event.dart';
import 'package:airaapp/features/history/presentation/history_bloc/chathistory_state.dart';
import 'package:airaapp/features/profile/presentation/components/profile_page_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
          automaticallyImplyLeading: false,
          backgroundColor: Appcolors.mainbgColor,
          centerTitle: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.chat_bubble),
              const SizedBox(width: 5),
              Text(
                'Chats',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Appcolors.logouttext,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: BlocConsumer<ChatHistoryBloc, ChatHistoryState>(
          listener: (context, state) {
            if (state is ChatHistoryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is ChatHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatSessionsLoaded) {
              return Column(
                children: [
                  //create new session...
                  HistoryButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (context) => ChatBloc(
                              repository: chatRepo,
                              chatRepo,
                              chatHistoryRepo: historyRepo,
                            ), // Removed the `..add()`
                            child: ChatPage(),
                          ),
                        ),
                      );
                    },
                    iconUrl: 'lib/data/assets/newsession.svg',
                    text: 'New session',
                  ),
                  //refresh the page...
                  HistoryButton(
                    onTap: () {
                      context.read<ChatHistoryBloc>().add(LoadChatSessions());
                    },
                    iconUrl: "",
                    text: 'Refresh',
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.sessions.length,
                      itemBuilder: (context, index) {
                        ChatSession session = state.sessions[index];
                        return ListTile(
                          leading: SvgPicture.asset(
                            'lib/data/assets/chatsessionicon.svg',
                          ),
                          title: Text(
                            session.title,
                            style: GoogleFonts.poppins(
                              textStyle:
                                  TextStyle(color: Appcolors.maintextColor),
                            ),
                            overflow: TextOverflow
                                .ellipsis, // This will show "..." when the text overflows
                            maxLines:
                                1, // This ensures the text is limited to a single line
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
                                  )..add(
                                      InitializeWithSession(session.sessionId)),
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
                  ProfilePageButton(
                      iconUrl: 'lib/data/assets/logout.svg',
                      onTap: () {
                        context.read<AuthCubit>().logout();
                      },
                      text: 'Logout')
                ],
              );
            } else if (state is ChatHistoryError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink(); // fallback
          },
        ),
      ),
    );
  }
}
