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
        style: TextStyle(color: Appcolors.whitecolor),
        controller: textController,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.urbanist(
              textStyle: TextStyle(
                  fontSize: 18,
                  color: Appcolors.textFiledtextColor,
                  fontWeight: FontWeight.w700)),
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
