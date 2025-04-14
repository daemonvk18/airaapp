import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisionBoardButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const VisionBoardButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height * 0.06,
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
                    fontWeight: FontWeight.w600,
                    color: Appcolors.maintextColor,
                    fontSize: height * 0.018)),
          ),
        ),
      ),
    );
  }
}
