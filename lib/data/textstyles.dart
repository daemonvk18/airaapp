import 'package:airaapp/data/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final List<TextStyle> textStyles = [
  GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: Appcolors.maintextColor,
  ),
  GoogleFonts.robotoMono(
    fontWeight: FontWeight.w400,
    fontSize: 18,
    color: Appcolors.maintextColor,
    letterSpacing: 1.2,
  ),
  GoogleFonts.lato(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    color: Appcolors.maintextColor,
    shadows: [
      Shadow(blurRadius: 3, color: Colors.black26, offset: Offset(2, 2))
    ],
  ),
  GoogleFonts.dancingScript(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: Appcolors.maintextColor,
  ),
  GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: Appcolors.maintextColor,
  ),
  GoogleFonts.bebasNeue(
    fontSize: 26,
    color: Appcolors.maintextColor,
    letterSpacing: 1.5,
  ),
  GoogleFonts.indieFlower(
    fontSize: 20,
    fontWeight: FontWeight.normal,
    color: Appcolors.maintextColor,
  ),
  GoogleFonts.righteous(
    fontSize: 22,
    color: Appcolors.maintextColor,
    fontWeight: FontWeight.w700,
  ),
  GoogleFonts.shadowsIntoLight(
    fontSize: 19,
    color: Appcolors.maintextColor,
    fontWeight: FontWeight.w400,
  ),
  GoogleFonts.pressStart2p(
    fontSize: 12,
    color: Appcolors.maintextColor,
    fontWeight: FontWeight.bold,
  ),
  GoogleFonts.amaticSc(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Appcolors.maintextColor,
  ),
  GoogleFonts.freckleFace(
    fontSize: 20,
    color: Appcolors.maintextColor,
  ),
];
