import 'package:flutter/material.dart';

class DisLikeButton extends StatefulWidget {
  final String responseId;
  final Function(BuildContext, String, String) onFeedback;
  final bool isSelected;
  const DisLikeButton(
      {super.key,
      required this.onFeedback,
      required this.responseId,
      required this.isSelected});

  @override
  State<DisLikeButton> createState() => _DisLikeButtonState();
}

class _DisLikeButtonState extends State<DisLikeButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: widget.isSelected
          ? Icon(
              Icons.thumb_down_sharp,
              size: 15,
            )
          : Icon(
              Icons.thumb_down_outlined,
              size: 15,
            ),
      onPressed: () {
        widget.onFeedback(context, widget.responseId, "dislike");
      },
    );
  }
}
