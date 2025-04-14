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
    final height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.07,
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
                    'lib/data/assets/navhomefull.svg',
                    height: height * 0.04,
                    width: height * 0.04,
                  ) // selected home icon
                : SvgPicture.asset('lib/data/assets/navhomeem.svg',
                    height: height * 0.04, width: height * 0.04),
          ),
          IconButton(
            onPressed: () {
              context.read<HomeBloc>().add(ChangeTab(1));
            },
            icon: currentIndex == 1
                ? SvgPicture.asset('lib/data/assets/navproffull.svg',
                    height: height * 0.04,
                    width: height * 0.04) // selected profile icon
                : SvgPicture.asset('lib/data/assets/navprofem.svg',
                    height: height * 0.04, width: height * 0.04),
          ),
        ],
      ),
    );
  }
}
