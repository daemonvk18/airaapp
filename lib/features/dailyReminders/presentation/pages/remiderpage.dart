import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_events.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_states.dart';
import 'package:airaapp/features/dailyReminders/presentation/components/add_reminder_dialog.dart';
import 'package:airaapp/features/dailyReminders/presentation/components/reminder_card.dart';
import 'package:airaapp/features/history/components/history_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../bloc/reminder_bloc.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReminderBloc>().add(LoadReminders());
  }

  void _showAddReminderDialog() {
    final bloc = context.read<ReminderBloc>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const AddReminderDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back)),
        title: Text(
          'My Reminders',
          style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: height * 0.025,
                  color: Appcolors.maintextColor)),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black, // border color
            height: 1.0,
          ),
        ),
        backgroundColor: Appcolors.mainbgColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: _showAddReminderDialog,
              child: Container(
                padding: const EdgeInsets.all(7),
                height: 39,
                width: 39,
                decoration: BoxDecoration(
                    color: Appcolors.innerdarkcolor,
                    borderRadius: BorderRadius.circular(12)),
                child: SvgPicture.asset('lib/data/assets/add_reminder.svg'),
              ),
            ),
          )
        ],
        elevation: 0,
      ),
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
            image: const AssetImage('lib/data/assets/bgimage.jpeg'),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const Expanded(child: _ReminderListView()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            border: Border.all(color: Appcolors.textFiledtextColor),
            borderRadius: BorderRadius.circular(12),
            color: Appcolors.deepdarColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where intentions are planned and progress begins.',
                maxLines: 2,
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: height * 0.015,
                        fontWeight: FontWeight.w700,
                        color: Appcolors.maintextColor))),
            const SizedBox(height: 5),
            Text(
                'Slide the sticky note to mark it complete - each swipe, a step forward 🌿',
                maxLines: 2,
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: height * 0.015,
                        fontWeight: FontWeight.w500,
                        color: Appcolors.maintextColor))),
          ],
        ),
      ),
    );
  }
}

class _ReminderListView extends StatelessWidget {
  const _ReminderListView();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return BlocConsumer<ReminderBloc, ReminderState>(
      listener: (context, state) {
        if (state is ReminderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ReminderOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is ReminderLoading) {
          return FutureBuilder(
            future: Future.delayed(const Duration(seconds: 3)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const Center(
                    child: Text("Processing...")); // You can replace this
              } else {
                return Container(
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
                      image: const AssetImage('lib/data/assets/bgimage.jpeg'),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'lib/data/assets/lottie/fireloading.json',
                          width: height * 0.05,
                          height: height * 0.05,
                          fit: BoxFit.contain,
                        ),
                        //loading text
                        Text(
                          'Loading...',
                          style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Appcolors.textFiledtextColor,
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.02)),
                        )
                      ],
                    ),
                  ),
                );
              }
            },
          );
        } else if (state is RemindersLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: state.reminders.length,
            itemBuilder: (context, index) {
              return ReminderCard(reminder: state.reminders[index]);
            },
          );
        } else if (state is ReminderError) {
          return Center(child: Text(state.message));
        } else if (state is ReminderEmpty) {
          return _buildEmptyState(context);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            maxLines: 2,
            'No reminders yet. Want a little nudge from me?',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: height * 0.017,
                    fontWeight: FontWeight.w700,
                    color: Appcolors.maintextColor)),
          ),
          const SizedBox(height: 5),
          Text(
            'Just tap the button below and I\'ll help you set one up',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: height * 0.017,
                    fontWeight: FontWeight.w400,
                    color: Appcolors.maintextColor)),
          ),
          const SizedBox(height: 10),
          HistoryButton(
              onTap: () => _showAddReminderDialog(context),
              iconUrl: 'lib/data/assets/add_reminder.svg',
              text: 'Add a New Reminder')
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final bloc = context.read<ReminderBloc>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const AddReminderDialog(),
      ),
    );
  }
}
