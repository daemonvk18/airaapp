// features/chat/presentation/components/comment_button.dart
import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSelected;

  const CommentButton({
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.comment,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      onPressed: onPressed,
    );
  }
}
