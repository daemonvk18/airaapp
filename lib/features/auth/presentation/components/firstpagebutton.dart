import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstPageButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const FirstPageButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
              color: Appcolors.innerdarkcolor,
              border: Border.all(color: Appcolors.maintextColor),
              borderRadius: BorderRadius.circular(12)),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Appcolors.maintextColor)),
            ),
          ),
        ),
      ),
    );
  }
}
