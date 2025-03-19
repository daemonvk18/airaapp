import 'package:flutter/material.dart';

class LikeButton extends StatefulWidget {
  final String response_id;
  final Function(BuildContext, String, String) onFeedback;
  final bool isSelected;
  const LikeButton(
      {super.key,
      required this.onFeedback,
      required this.response_id,
      required this.isSelected});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: widget.isSelected
          ? Icon(
              Icons.thumb_up_sharp,
              size: 15,
            )
          : Icon(
              Icons.thumb_up_outlined,
              size: 15,
            ),
      onPressed: () {
        widget.onFeedback(context, widget.response_id, "like");
        //open a dialog box and take the comment
      },
    );
  }
}
