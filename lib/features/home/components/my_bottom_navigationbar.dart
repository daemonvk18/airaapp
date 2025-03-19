import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:airaapp/features/home/presentation/home_events/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBottomNavigation extends StatelessWidget {
  final int currentIndex;
  MyBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Appcolors.greyblackcolor,
        selectedItemColor: Appcolors.bluecolor,
        unselectedItemColor: Appcolors.whitecolor,
        onTap: (value) {
          context.read<HomeBloc>().add(ChangeTab(value));
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ]);
  }
}
