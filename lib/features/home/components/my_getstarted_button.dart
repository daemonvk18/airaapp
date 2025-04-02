import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetStartedButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const GetStartedButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Appcolors.startedbuttoncolor),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Appcolors.whitecolor)),
          ),
        ),
      ),
    );
  }
}
