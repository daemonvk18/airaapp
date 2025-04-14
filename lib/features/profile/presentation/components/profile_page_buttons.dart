import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePageButton extends StatelessWidget {
  final String text;
  final String iconUrl;
  final void Function()? onTap;
  const ProfilePageButton(
      {super.key,
      required this.iconUrl,
      required this.onTap,
      required this.text});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
            padding: const EdgeInsets.only(left: 22),
            width: MediaQuery.of(context).size.width,
            height: height * 0.06,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFEBD1CD), // soft pink background
              borderRadius: BorderRadius.circular(15), // rounded corners
              border: Border.all(
                  color: Appcolors.textFiledtextColor), // thin border
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(iconUrl),
                SizedBox(
                  width: 5,
                ),
                Text(text,
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: height * 0.017,
                            color: Appcolors.maintextColor)))
              ],
            )),
      ),
    );
  }
}
