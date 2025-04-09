import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/dailyReminders/data/reminder_repo_impl.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_events.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_states.dart';
import 'package:airaapp/features/dailyReminders/presentation/components/add_reminder_dialog.dart';
import 'package:airaapp/features/dailyReminders/presentation/components/reminder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/reminder_bloc.dart';

class ReminderPage extends StatelessWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReminderBloc(
        reminderRepository: ReminderRepositoryImpl(),
      )..add(const LoadReminders()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text(
            'My Reminders',
            style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Appcolors.maintextColor)),
          ),
          centerTitle: false,
          backgroundColor: Appcolors.mainbgColor,
          actions: [
            //add the adding new session option
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => _showAddReminderDialog(context),
                child: Container(
                  padding: EdgeInsets.all(7),
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
                  image: AssetImage(
                    'lib/data/assets/bgimage.jpeg',
                  ))),
          child: Column(
            children: [
              _buildHeader(),
              const Expanded(child: _ReminderListView()),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final bloc = BlocProvider.of<ReminderBloc>(context);
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const AddReminderDialog(),
      ),
    );
  }
}

Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Appcolors.deepdarColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where intentions are planned and progress\nbegins.',
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Appcolors.maintextColor))),
          SizedBox(height: 8),
          Text(
              'Slide the sticky note to mark it complete - each\nswipe, a step forward',
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Appcolors.maintextColor))),
        ],
      ),
    ),
  );
}

class _ReminderListView extends StatelessWidget {
  const _ReminderListView();

  @override
  Widget build(BuildContext context) {
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
          return const Center(child: CircularProgressIndicator());
        } else if (state is RemindersLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.reminders.length,
            itemBuilder: (context, index) {
              return ReminderCard(reminder: state.reminders[index]);
            },
          );
        } else if (state is ReminderError) {
          return Center(child: Text(state.message));
        }
        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No reminders yet. Want a little nudge from me?',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Just tap the button below and I\'ll help you set one up:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => _showAddReminderDialog(context),
              child: const Text(
                'Add a New Reminder',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final bloc = BlocProvider.of<ReminderBloc>(context);
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const AddReminderDialog(),
      ),
    );
  }
}
