import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/visionBoard/components/vision_board_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditDialog extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentPhoto;
  final String password;
  final Function(String, String, String, String) onSave;

  const ProfileEditDialog(
      {super.key,
      required this.currentName,
      required this.currentEmail,
      required this.currentPhoto,
      required this.onSave,
      required this.password});

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _passwordController = TextEditingController(text: widget.password);
    _selectedImage = widget.currentPhoto;
  }

  // Picking the image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return AlertDialog(
      backgroundColor: Appcolors.lightdarlColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Appcolors.textFiledtextColor, // Customize border color
          width: 1.5,
        ),
      ),
      title: Center(
        child: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: height * 0.017,
              fontWeight: FontWeight.w700,
              color: Appcolors.textFiledtextColor,
            ),
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: height * 0.06,
            child: TextField(
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: height * 0.017,
                  fontWeight: FontWeight.w600,
                  color: Appcolors.textFiledtextColor,
                ),
              ),
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Name",
                hintStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: height * 0.017,
                    fontWeight: FontWeight.w600,
                    color: Appcolors.textFiledtextColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Appcolors.textFiledtextColor),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: height * 0.06,
            child: TextField(
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: height * 0.017,
                  fontWeight: FontWeight.w600,
                  color: Appcolors.textFiledtextColor,
                ),
              ),
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Email",
                hintStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: height * 0.017,
                    fontWeight: FontWeight.w600,
                    color: Appcolors.textFiledtextColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Appcolors.textFiledtextColor),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: height * 0.06,
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: "New Password",
                hintStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: height * 0.017,
                    fontWeight: FontWeight.w600,
                    color: Appcolors.textFiledtextColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Appcolors.textFiledtextColor),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              obscureText: true,
            ),
          ),
        ],
      ),
      actions: [
        VisionBoardButton(onTap: () => Navigator.pop(context), text: 'cancel'),
        VisionBoardButton(
          onTap: () {
            widget.onSave(
              _nameController.text,
              _emailController.text,
              _passwordController.text,
              _selectedImage ?? widget.currentPhoto,
            );
            Navigator.pop(context);
          },
          text: 'save',
        ),
      ],
    );
  }
}
