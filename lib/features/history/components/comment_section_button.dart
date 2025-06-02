import 'package:airaapp/data/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentSectionButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const CommentSectionButton(
      {super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height * 0.05,
        width: 102,
        decoration: BoxDecoration(
            border: Border.all(color: Appcolors.textFiledtextColor),
            color: Appcolors.deepdarColor,
            borderRadius: BorderRadius.circular(12)),
        child: Center(
            child: Text(
          text,
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  color: Appcolors.textFiledtextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        )),
      ),
    );
  }
}
