// import 'package:airaapp/features/chat/domain/model/chat_message.dart';
// import 'package:airaapp/features/chat/domain/repository/chat_message_repo.dart';
// import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
// import 'package:airaapp/features/chat/presentation/chat_bloc/chat_states.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ChatBloc extends Bloc<ChatEvent, ChatState> {
//   final ChatRepo chatrepo;
//   final List<ChatMessage> messages = [];
//   ChatBloc({required this.chatrepo}) : super(ChatInitial()) {
//     on<SendMessage>(
//       (event, emit) async {
//         messages.add(ChatMessage(
//           isUser: true,
//           text: event.message,
//           response_id: '',
//         ));
//         // Emit new state with updated messages
//         emit(ChatLoaded(message: List.from(messages)));
//         try {
//           final response = await chatrepo.sendmessage(event.message);
//           messages.add(response);
//           emit(ChatLoaded(message: List.from(messages)));
//         } catch (e) {
//           emit(ChatError(message: e.toString()));
//         }
//       },
//     );
//   }
// }

import 'package:airaapp/features/chat/domain/model/chat_message.dart';
import 'package:airaapp/features/chat/domain/repository/chat_message_repo.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_events.dart';
import 'package:airaapp/features/chat/presentation/chat_bloc/chat_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepo chatrepo;
  final List<ChatMessage> messages = [];

  ChatBloc({required this.chatrepo}) : super(ChatInitial()) {
    // Load chat history on initialization
    on<LoadChatHistory>(
      (event, emit) async {
        emit(ChatLoading());
        try {
          messages.clear();
          final savedMessages = await chatrepo.getSavedChat();
          messages.addAll(savedMessages);
          emit(ChatLoaded(
            message: List.from(messages),
          ));
        } catch (e) {
          emit(ChatError(message: "Failed to load chat history: $e"));
        }
      },
    );

    // Handle sending a new message
    // on<SendMessage>(
    //   (event, emit) async {
    //     final userMessage = ChatMessage(
    //         isUser: true,
    //         text: event.message,
    //         response_id: '',
    //         response_time: 0.0);
    //     messages.add(userMessage);
    //     emit(ChatLoaded(
    //       message: List.from(messages),
    //     )); // Update UI immediately
    //     try {
    //       // Send message to API
    //       final response = await chatrepo.sendmessage(event.message);
    //       messages.add(response);
    //       print(messages);
    //       // Save chat history
    //       await chatrepo.saveChat(messages);

    //       // Emit updated state
    //       emit(ChatLoaded(
    //         message: List.from(messages),
    //       ));
    //     } catch (e) {
    //       messages.remove(userMessage); // Remove the failed message
    //       emit(ChatError(message: "Failed to send message: $e"));
    //       emit(ChatLoaded(
    //         message: List.from(messages),
    //       )); // Restore previous state
    //     }
    //   },
    // );
    on<SendMessage>(
      (event, emit) async {
        final userMessage = ChatMessage(
          isUser: true,
          text: event.message,
          response_id: '',
          response_time: 0.0, // User messages don’t have response_time
        );
        messages.add(userMessage);
        emit(ChatLoaded(message: List.from(messages))); // Show user message

        try {
          // Add "Thinking..." message
          final thinkingMessage = ChatMessage(
            isUser: false,
            text: "Thinking...",
            response_id: '',
            response_time: 0.0,
          );
          messages.add(thinkingMessage);
          emit(ChatLoaded(message: List.from(messages))); // Show "Thinking..."

          // Send message to API
          final response = await chatrepo.sendmessage(event.message);

          // Wait for the response_time before replacing "Thinking..."
          await Future.delayed(
              Duration(milliseconds: (response.response_time * 1000).toInt()));

          // Remove "Thinking..." message
          messages.remove(thinkingMessage);

          // Add AI response
          messages.add(response);

          // Save chat history
          await chatrepo.saveChat(messages);

          // Emit updated state with AI response
          emit(ChatLoaded(
            message: List.from(messages),
          ));
        } catch (e) {
          messages.remove(userMessage); // Remove the failed message
          emit(ChatError(message: "Failed to send message: $e"));
          emit(ChatLoaded(
            message: List.from(messages),
          )); // Restore previous state
        }
      },
    );

    // Clear chat history on logout
    on<ClearChatHistory>(
      (event, emit) async {
        await chatrepo.clearChatHistory();
        messages.clear(); // Clear the messages in memory
        emit(ChatLoaded(
          message: [],
        )); // Update UI
      },
    );
  }
}
