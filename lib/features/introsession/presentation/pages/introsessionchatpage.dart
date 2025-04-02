import 'package:airaapp/features/home/presentation/pages/home_page.dart';
import 'package:airaapp/features/introsession/domain/entities/chat_message.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessioevents.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessioncubit.dart';
import 'package:airaapp/features/introsession/presentation/introsessioncubit/introsessionstates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IntroChatPage extends StatelessWidget {
  const IntroChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the chat when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntroSessionBloc>().add(StartIntroSession());
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Chat with AIRA')),
      body: Column(
        children: [
          Expanded(child: _ChatMessages()),
          _ChatInputField(),
        ],
      ),
    );
  }
}

class _ChatMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IntroSessionBloc, IntroChatState>(
      listener: (context, state) {
        if (state is IntroChatCompleted) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      },
      builder: (context, state) {
        if (state is IntroChatInitial || state is IntroChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is IntroChatError) {
          return Center(child: Text(state.message));
        }

        if (state is IntroChatMessageReceived) {
          if (state.isIntroComplete) {
            // Handle case where intro is already complete
            return const Center(child: Text('Intro already completed'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            reverse: true,
            itemCount: state.chatSession.messages.length,
            itemBuilder: (context, index) {
              final message =
                  state.chatSession.messages.reversed.toList()[index];
              return _ChatBubble(message: message);
            },
          );
        }

        return Container();
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Message message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ChatInputField extends StatefulWidget {
  const _ChatInputField({super.key});

  @override
  State<_ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<_ChatInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              final message = _controller.text.trim();
              if (message.isNotEmpty) {
                context.read<IntroSessionBloc>().add(
                      SendIntroMessage(message: message),
                    );
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}
