import 'package:airaapp/data/colors.dart';
import 'package:airaapp/features/dailyReminders/data/notification_services.dart';
import 'package:airaapp/features/dailyReminders/domain/models/reminder_model.dart';
import 'package:airaapp/features/dailyReminders/presentation/bloc/reminder_events.dart';
import 'package:airaapp/features/visionBoard/components/vision_board_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/reminder_bloc.dart';

class AddReminderDialog extends StatefulWidget {
  final ReminderEntity? reminder;

  const AddReminderDialog({Key? key, this.reminder}) : super(key: key);

  @override
  _AddReminderDialogState createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  // ignore: unused_field
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.reminder?.title ?? '');
    // _dateController = TextEditingController(
    //   text: widget.reminder?.scheduledTime ?? '',
    // );
    // Initialize with existing reminder time or default to empty
    final existingDateTime = widget.reminder?.scheduledTime ?? '';
    _dateController = TextEditingController(
        text:
            existingDateTime.isNotEmpty ? existingDateTime.split(' ')[0] : '');
    _timeController = TextEditingController(
        text:
            existingDateTime.isNotEmpty ? existingDateTime.split(' ')[1] : '');

    // Parse existing datetime if available
    if (widget.reminder?.scheduledTime != null) {
      final parts = widget.reminder!.scheduledTime.split(' ');
      if (parts.length == 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');
        if (dateParts.length == 3 && timeParts.length >= 2) {
          _selectedDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Appcolors.lightdarlColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.reminder == null
                    ? "Leave a note for your future self"
                    : 'Update Reminder',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: height * 0.017,
                    fontWeight: FontWeight.w700,
                    color: Appcolors.maintextColor,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                maxLines: 2,
                widget.reminder == null
                    ? "I'll be here to remind you when the moment is right ❤️"
                    : 'Update Reminder',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: height * 0.017,
                    fontWeight: FontWeight.w500,
                    color: Appcolors.maintextColor,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: height * 0.06, // Set your desired height here
                child: TextFormField(
                  cursorColor: Appcolors.maintextColor,
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Reminder Text',
                    labelStyle: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: height * 0.017,
                            color: Appcolors.maintextColor)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.greyblackcolor),
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.greyblackcolor),
                        borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Appcolors.deepdarColor,
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter reminder text'
                      : null,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: height * 0.06,
                child: TextFormField(
                  cursorColor: Appcolors.maintextColor,
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    labelStyle: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: height * 0.017,
                            color: Appcolors.maintextColor)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.greyblackcolor),
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.greyblackcolor),
                        borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Appcolors.deepdarColor,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please select a date' : null,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: height * 0.06,
                child: TextFormField(
                  cursorColor: Appcolors.maintextColor,
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    labelStyle: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: height * 0.017,
                            color: Appcolors.maintextColor)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.greyblackcolor),
                        borderRadius: BorderRadius.circular(15)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Appcolors.greyblackcolor),
                        borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Appcolors.deepdarColor,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: _selectTime,
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please select a time' : null,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  VisionBoardButton(
                    onTap: () => Navigator.pop(context),
                    text: 'cancel',
                  ),
                  VisionBoardButton(
                    onTap: () async {
                      _submitForm();
                      final int year =
                          int.parse(_dateController.text.substring(0, 4));
                      final int month =
                          int.parse(_dateController.text.substring(5, 7));
                      final int day =
                          int.parse(_dateController.text.substring(8));
                      final hour =
                          int.parse(_timeController.text.substring(0, 2));
                      final int minute =
                          int.parse(_timeController.text.substring(3, 5));

                      NotiService().scheduleNotifications(
                        title:
                            "${_titleController.text[0].toUpperCase() + _titleController.text.substring(1)}?",
                        body: 'Have you finished it???🔥🔥',
                        year: year,
                        month: month,
                        day: day,
                        hour: hour,
                        minute: minute,
                      );
                    },
                    text: 'save',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateController.text =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
        _timeController.text =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      // Combine date and time into API format: "YYYY-MM-DD HH:MM:00"
      final formattedDateTime = '${_selectedDate!.year}-'
          '${_selectedDate!.month.toString().padLeft(2, '0')}-'
          '${_selectedDate!.day.toString().padLeft(2, '0')} '
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
          '${_selectedTime!.minute.toString().padLeft(2, '0')}:00';

      final bloc = context.read<ReminderBloc>();
      if (widget.reminder == null) {
        bloc.add(AddReminder(
          title: _titleController.text,
          scheduledTime: formattedDateTime,
        ));
      } else {
        bloc.add(UpdateReminder(
          reminderId: widget.reminder!.id,
          title: _titleController.text,
          scheduledTime: formattedDateTime,
        ));
      }
      Navigator.pop(context);
    }
  }
}
