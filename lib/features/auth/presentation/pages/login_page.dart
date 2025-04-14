/*

the user can log in with their email,pw

-----------------------------------------------

once the user logins they are navigated to the home page

if the user doesnot have any account they can go to register page and create an account

*/

import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/auth/presentation/components/my_button.dart';
import 'package:airaapp/features/auth/presentation/components/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //textcontrollers
  final emailcontroller = TextEditingController();
  final pwcontroller = TextEditingController();

  //login method
  void loginmethod() {
    //first get the email,pw
    final email = emailcontroller.text;
    final password = pwcontroller.text;

    //grab the auth cubit
    final authcubit = context.read<AuthCubit>();

    if (email.isNotEmpty && password.isNotEmpty) {
      authcubit.loginmethod(email, password);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("failed to login")));
    }
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    pwcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Appcolors.mainbgColor,
            image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.dstATop,
                ),
                image: AssetImage(
                  'lib/data/assets/bgimage.jpeg',
                ))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //add the navigate pop button
              // Align(
              //     alignment: Alignment.centerLeft,
              //     child: Padding(
              //       padding: const EdgeInsets.only(top: 20, left: 10),
              //       child: IconButton(
              //           onPressed: () => Navigator.of(context).pop(),
              //           icon: Icon(
              //             Icons.arrow_back,
              //             color: Appcolors.maintextColor,
              //           )),
              //     )),
              //give some space at the begining
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              //aira text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("I'm ",
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontSize: height * 0.04,
                              fontWeight: FontWeight.w700,
                              color: Appcolors.maintextColor))),
                  Text(
                    ' A',
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: height * 0.04,
                            fontWeight: FontWeight.w700,
                            color:
                                Appcolors.gesturetextColor.withOpacity(0.5))),
                  ),
                  Text(
                    'IRA',
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: height * 0.04,
                            fontWeight: FontWeight.w700,
                            color: Appcolors.maintextColor)),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              //logo
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset(
                    'lib/data/assets/firstpageimage.png',
                    height: height * 0.15,
                  )),

              //email textfield
              MyTextField(
                hintText: "email",
                obscureText: false,
                textController: emailcontroller,
                textfieldcolor: Appcolors.innerdarkcolor,
              ),

              //password textfield
              MyTextField(
                hintText: 'password',
                obscureText: true,
                textController: pwcontroller,
                textfieldcolor: Appcolors.innerdarkcolor,
              ),

              //login button
              MyButton(
                  onTap: () {
                    //first show the loading screen for 2 secs
                    loginmethod();
                  },
                  text: 'Signin'),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              //text(dont have an account)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //text(already have an account)
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.w600,
                            color: Appcolors.maintextColor)),
                  ),
                  GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        ' Register now!',
                        style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.bold,
                                color: Appcolors.gesturetextColor
                                    .withOpacity(0.5))),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
