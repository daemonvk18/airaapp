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
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<ChatHistoryBloc>().add(LoadChatSessions());
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.017,
            fontWeight: FontWeight.w700,
            color: Appcolors.maintextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, ChatSession session) {
    double height = MediaQuery.of(context).size.height;

    return ListTile(
      hoverColor: Appcolors.innerdarkcolor,
      leading: SvgPicture.asset(
        'lib/data/assets/chatsessionicon.svg',
      ),
      title: Text(
        session.title,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: Appcolors.maintextColor,
            fontWeight: FontWeight.w500,
            fontSize: height * 0.015,
          ),
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
              )..add(InitializeWithSession(session.sessionId)),
              child: ChatPage(
                sessionId: session.sessionId,
                sessionTitle: session.title,
              ),
            ),
          ),
        );
      },
      trailing: IconButton(
          onPressed: () {
            context.read<ChatHistoryBloc>().add(
                  DeleteChatSession(session.sessionId),
                );
          },
          icon: Icon(CupertinoIcons.delete)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
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
              //add the chatbubble icon here
              SvgPicture.asset('lib/data/assets/chatbubble.svg'),
              const SizedBox(width: 5),
              Text(
                'Chats',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: width * 0.05,
                    fontWeight: FontWeight.w700,
                    color: Appcolors.textFiledtextColor,
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
              return Center(
                  child: CircularProgressIndicator(
                color: Appcolors.innerdarkcolor,
              ));
            } else if (state is ChatSessionsLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                            ),
                            child: ChatPage(),
                          ),
                        ),
                      );
                    },
                    iconUrl: 'lib/data/assets/newsession.svg',
                    text: 'New session',
                  ),
                  SizedBox(
                    height: height * 0.02,
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
                    child: Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final yesterday = today.subtract(Duration(days: 1));

                        final todaySessions = <ChatSession>[];
                        final yesterdaySessions = <ChatSession>[];
                        final previousSessions = <ChatSession>[];

                        for (var session in state.sessions) {
                          final created = DateTime.parse(session.createdAt);
                          final createdDate = DateTime(
                              created.year, created.month, created.day);

                          if (createdDate == today) {
                            todaySessions.add(session);
                          } else if (createdDate == yesterday) {
                            yesterdaySessions.add(session);
                          } else {
                            previousSessions.add(session);
                          }
                        }

                        final List<Widget> sessionWidgets = [];

                        if (todaySessions.isNotEmpty) {
                          sessionWidgets.add(_buildSectionHeader("Today"));
                          sessionWidgets.addAll(todaySessions.map((session) =>
                              _buildSessionTile(context, session)));
                        }

                        if (yesterdaySessions.isNotEmpty) {
                          sessionWidgets.add(_buildSectionHeader("Yesterday"));
                          sessionWidgets.addAll(yesterdaySessions.map(
                              (session) =>
                                  _buildSessionTile(context, session)));
                        }

                        if (previousSessions.isNotEmpty) {
                          sessionWidgets.add(_buildSectionHeader("Previous"));
                          sessionWidgets.addAll(previousSessions.map(
                              (session) =>
                                  _buildSessionTile(context, session)));
                        }

                        return ListView(
                          children: sessionWidgets,
                        );
                      },
                    ),
                  ),

                  HistoryButton(
                      onTap: () {
                        context.read<AuthCubit>().logout();
                      },
                      iconUrl: 'lib/data/assets/logout.svg',
                      text: 'Logout'),
                  const SizedBox(
                    height: 20,
                  ),
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
