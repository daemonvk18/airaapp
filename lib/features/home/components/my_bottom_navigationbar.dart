import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/home/presentation/home_bloc/home_bloc.dart';
import 'package:airaapp/features/home/presentation/home_events/home_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyBottomNavigation extends StatelessWidget {
  final int currentIndex;
  MyBottomNavigation({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 79,
      decoration: BoxDecoration(
        color: Appcolors.mainbgColor,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              context.read<HomeBloc>().add(ChangeTab(0));
            },
            icon: currentIndex == 0
                ? SvgPicture.asset(
                    'lib/data/assets/navhomefull.svg') // selected home icon
                : SvgPicture.asset('lib/data/assets/navhomeem.svg'),
          ),
          IconButton(
            onPressed: () {
              context.read<HomeBloc>().add(ChangeTab(1));
            },
            icon: currentIndex == 1
                ? SvgPicture.asset(
                    'lib/data/assets/navproffull.svg') // selected profile icon
                : SvgPicture.asset('lib/data/assets/navprofem.svg'),
          ),
        ],
      ),
    );
  }
}
