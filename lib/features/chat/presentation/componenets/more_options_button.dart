// features/chat/presentation/components/more_options_button.dart
import 'package:flutter/material.dart';

class MoreOptionsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSelected;

  const MoreOptionsButton({
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.more_vert,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      onPressed: onPressed,
    );
  }
}
