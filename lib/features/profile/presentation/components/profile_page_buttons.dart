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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
            padding: const EdgeInsets.only(left: 20),
            width: MediaQuery.of(context).size.width,
            height: 61,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFEBD1CD), // soft pink background
              borderRadius: BorderRadius.circular(15), // rounded corners
              border: Border.all(color: Colors.black87), // thin border
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
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Appcolors.maintextColor)))
              ],
            )),
      ),
    );
  }
}
