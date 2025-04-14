import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/auth/presentation/components/firstpagebutton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: Appcolors.mainbgColor,
            image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.15),
                  BlendMode.dstATop,
                ),
                image: AssetImage(
                  'lib/data/assets/bgimage.jpeg',
                ))),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //leave some space at the beginning
              SizedBox(
                height: height * 0.2,
              ),
              //add the i am aira text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "I'm  ",
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: height * 0.045,
                            color: Appcolors.maintextColor)),
                  ),
                  Text(
                    'A',
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: height * 0.045,
                            color:
                                Appcolors.gesturetextColor.withOpacity(0.5))),
                  ),
                  Text(
                    'IRA',
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: height * 0.045,
                            color: Appcolors.maintextColor)),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.05,
              ),
              //add the logo here
              Image.asset(
                'lib/data/assets/firstpageimage.png',
                height: height * 0.35,
              ),
              //add the login button
              FirstPageButton(
                  onTap: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  text: 'Login'),
              //add the sign up button
              FirstPageButton(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => RegisterPage()));
                  },
                  text: 'Singup')
              //need to add the google button ,lets add it afterwards
            ],
          ),
        ),
      ),
    );
  }
}
