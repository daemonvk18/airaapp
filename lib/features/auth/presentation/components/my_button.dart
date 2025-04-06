import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const MyButton({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Appcolors.redColor.withOpacity(0.5)),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.urbanist(
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Appcolors.whitecolor,
                      fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }
}
