import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/dailyReminders/domain/models/reminder_model.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reminder_bloc.dart';

class ReminderCard extends StatelessWidget {
  final ReminderEntity reminder;

  const ReminderCard({Key? key, required this.reminder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reminder.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showEditDialog(context);
                            context.read<ReminderBloc>().add(LoadReminders());
                          },
                          child: _buildIcon(Icons.edit),
                        ),
                        const SizedBox(width: 8),
                        _buildIcon(Icons.close),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Time: ${_formatTime(reminder.scheduledTime)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${_formatDate(reminder.scheduledTime)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
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
        title: const Text('Edit Reminder'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Reminder Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
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
            child: const Text('Save'),
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

  Widget _buildIcon(IconData iconData) {
    return CircleAvatar(
      backgroundColor: Colors.red.shade400,
      radius: 16,
      child: Icon(
        iconData,
        size: 16,
        color: Colors.white,
      ),
    );
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
    final double cutSize = 16; // Adjust for depth of the cut

    final path = Path();
    path.lineTo(size.width - cutSize, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - cutSize, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
