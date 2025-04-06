import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/auth/presentation/auth_cubits/authcubit.dart';
import 'package:airaapp/features/auth/presentation/components/my_button.dart';
import 'package:airaapp/features/auth/presentation/components/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //textcontrollers
  final usernamecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final pwcontroller = TextEditingController();
  final cnfrmpwcontroller = TextEditingController();

  //register method
  void registermethod() {
    //first get the emai,pw,cnfrmpw
    final username = usernamecontroller.text;
    final email = emailcontroller.text;
    final pw = pwcontroller.text;
    final cnfrmpw = cnfrmpwcontroller.text;

    //get the auth cubit
    final authcubit = context.read<AuthCubit>();

    if (username.isNotEmpty &&
        email.isNotEmpty &&
        pw.isNotEmpty &&
        cnfrmpw.isNotEmpty) {
      //check if pw and cnfrm are equal are not
      if (pw == cnfrmpw) {
        //create the account
        authcubit.registemethod(email, pw, username);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("The password you entered are not valid")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('invalid data')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              //give some space at the begining
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              //logo
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset('lib/data/assets/airalogo.png')),

              // //welcome to
              // Text(
              //   "Welcome to",
              //   style: GoogleFonts.urbanist(
              //       textStyle: TextStyle(
              //           fontSize: 25,
              //           fontWeight: FontWeight.bold,
              //           color: Appcolors.whitecolor)),
              // ),

              // //aira text
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text('A',
              //         style: GoogleFonts.urbanist(
              //             textStyle: TextStyle(
              //                 fontSize: 30,
              //                 fontWeight: FontWeight.w700,
              //                 color: Appcolors.bluecolor))),
              //     Text(
              //       'IRA',
              //       style: GoogleFonts.urbanist(
              //           textStyle: TextStyle(
              //               fontSize: 30,
              //               fontWeight: FontWeight.w700,
              //               color: Appcolors.whitecolor)),
              //     ),
              //   ],
              // ),

              //usewrname textfield
              MyTextField(
                hintText: "username",
                obscureText: false,
                textController: usernamecontroller,
                textfieldcolor: Appcolors.innerdarkcolor,
              ),

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

              //confirm password textfield
              MyTextField(
                hintText: "confirm password",
                obscureText: true,
                textController: cnfrmpwcontroller,
                textfieldcolor: Appcolors.innerdarkcolor,
              ),

              //login button
              MyButton(
                  onTap: () {
                    registermethod();
                  },
                  text: 'Signup'),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              //text(dont have an account)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //text(already have an account)
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.urbanist(
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Appcolors.maintextColor)),
                  ),
                  GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        ' Sigin!',
                        style: GoogleFonts.urbanist(
                            textStyle: TextStyle(
                                fontSize: 16,
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
