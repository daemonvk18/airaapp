import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateNewSEssion extends StatelessWidget {
  final void Function()? onTap;
  const CreateNewSEssion({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: height * 0.06,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFEBD1CD), // soft pink background
              borderRadius: BorderRadius.circular(15), // rounded corners
              border: Border.all(color: Colors.black87), // thin border
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("lib/data/assets/newsession.svg"),
                SizedBox(
                  width: 5,
                ),
                Text('New Session',
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: height * 0.02,
                            color: Appcolors.maintextColor)))
              ],
            )),
      ),
    );
  }
}
