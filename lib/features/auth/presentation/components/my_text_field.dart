import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  final bool obscureText;
  final Color textfieldcolor;
  const MyTextField(
      {super.key,
      required this.hintText,
      required this.obscureText,
      required this.textfieldcolor,
      required this.textController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
      child: TextField(
        textAlign: TextAlign.start,
        cursorColor: Appcolors.maintextColor,
        style: GoogleFonts.poppins(
            textStyle: TextStyle(
                color: Appcolors.textFiledtextColor,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        controller: textController,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontSize: 16,
                  color: Appcolors.textFiledtextColor,
                  fontWeight: FontWeight.w600)),
          fillColor: Appcolors.innerdarkcolor,
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Appcolors.greyblackcolor),
              borderRadius: BorderRadius.circular(18)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Appcolors.whitecolor),
              borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
