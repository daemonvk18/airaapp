import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/dailyReminders/domain/models/reminder_model.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_events.dart';
import 'package:airaapp/features/visionBoard/components/vision_board_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/reminder_bloc.dart';

class ReminderCard extends StatelessWidget {
  final ReminderEntity reminder;

  const ReminderCard({Key? key, required this.reminder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;
    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      secondaryBackground: _buildCompleteBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Appcolors.innerdarkcolor,
              title: const Text('Confirm'),
              content:
                  const Text('Are you sure you want to delete this reminder?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<ReminderBloc>().add(DeleteReminder(reminder.id));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "${reminder.title}"'),
            ),
          );
        } else {
          context.read<ReminderBloc>().add(
                UpdateReminder(
                  reminderId: reminder.id,
                  status: 'completed',
                ),
              );
        }
      },
      child: ClipPath(
        clipper: RibbonClipper(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Appcolors.deepdarColor,
            border: Border(
                left: BorderSide(
                    width: 15, color: Appcolors.stylingColor.withOpacity(0.5))),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          child: Text(
                            reminder.title,
                            style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Appcolors.maintextColor,
                                    fontSize: height * 0.016)),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Time: ${_formatTime(reminder.scheduledTime)}',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Appcolors.maintextColor,
                              fontSize: 8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${_formatDate(reminder.scheduledTime)}',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Appcolors.maintextColor,
                              fontSize: 8)),
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showEditDialog(context);
                        // context.read<ReminderBloc>().add(LoadReminders());
                      },
                      child: _buildIcon(
                        'lib/data/assets/edit_icon.svg',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: () {
                          context.read<ReminderBloc>().add(UpdateReminder(
                              reminderId: reminder.id,
                              title: reminder.title,
                              scheduledTime: reminder.scheduledTime,
                              status: 'not_done'));
                          //context.read<ReminderBloc>().add(LoadReminders());
                        },
                        child: _buildIcon('lib/data/assets/cross.svg')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: reminder.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Appcolors.lightdarlColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Appcolors.textFiledtextColor, // Set your border color
            width: 2, // Set border width
          ),
        ),
        title: Text(
          'Edit Reminder',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Appcolors.maintextColor,
            ),
          ),
        ),
        content: TextField(
          controller: textController,
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Appcolors.maintextColor,
            ),
          ), // Optional: text color
          decoration: InputDecoration(
            filled: true,
            fillColor: Appcolors.deepdarColor,
            labelText: 'Reminder Title',
            labelStyle: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Appcolors.maintextColor,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        actions: [
          VisionBoardButton(
            onTap: () => Navigator.of(context).pop(),
            text: 'cancel',
          ),
          VisionBoardButton(
            onTap: () {
              if (textController.text.isNotEmpty) {
                context.read<ReminderBloc>().add(
                      UpdateReminder(
                        reminderId: reminder.id,
                        title: textController.text,
                        scheduledTime: reminder.scheduledTime,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            text: 'save',
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 30),
          Text('Delete', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCompleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.white, size: 30),
          Text('Complete', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildIcon(String url) {
    return CircleAvatar(
        backgroundColor: Colors.red.shade400,
        radius: 15,
        child: SvgPicture.asset(
          url,
          height: 15,
          width: 15,
        ));
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString.split(' ').first;
    }
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final hour = date.hour;
      final minute = date.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : hour;
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      final timePart =
          dateString.split(' ').length > 1 ? dateString.split(' ')[1] : '';
      return timePart.split(':').take(2).join(':');
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    //path.moveTo(40, 0); // Start with some padding from left
    path.lineTo(size.width - 40, 0); // Top edge
    path.lineTo(size.width - 80, size.height / 2); // Right arrow point
    path.lineTo(size.width - 32, size.height); // Bottom right corner
    path.lineTo(0, size.height); // Bottom edge
    //path.lineTo(80, size.height / 2); // Left arrow point
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
