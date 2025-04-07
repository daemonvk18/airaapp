import 'package:airaapp/data/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final String iconUrl;
  const HistoryButton(
      {super.key,
      required this.onTap,
      required this.iconUrl,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: 47,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFEBD1CD), // soft pink background
              borderRadius: BorderRadius.circular(15), // rounded corners
              border: Border.all(color: Colors.black87), // thin border
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconUrl.isNotEmpty) SvgPicture.asset(iconUrl),
                if (iconUrl.isEmpty)
                  Icon(
                    CupertinoIcons.refresh,
                    color: Appcolors.maintextColor,
                  ),
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
