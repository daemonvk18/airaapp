import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisionBoardButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const VisionBoardButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
            color: Appcolors.deepdarColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Appcolors.maintextColor)),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Appcolors.maintextColor,
                    fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
