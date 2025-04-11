import 'package:airaapp/data/colors.dart';
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
    return Dialog(
      backgroundColor: Appcolors.lightdarlColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  widget.reminder == null
                      ? "Leave a note for your future self.\nI'll be here to remind you when the\nmoment is right ❤️"
                      : 'Update Reminder',
                  style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Appcolors.maintextColor))),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Reminder Text',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Appcolors.deepdarColor,
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter reminder text'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Appcolors.deepdarColor,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDate,
                        ),
                      ),
                      readOnly: true,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please select a date'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Appcolors.deepdarColor,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: _selectTime,
                        ),
                      ),
                      readOnly: true,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please select a time'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  VisionBoardButton(
                      onTap: () => Navigator.pop(context), text: 'cancel'),
                  VisionBoardButton(
                      onTap: () {
                        _submitForm();
                      },
                      text: 'save'),
                  // ElevatedButton(
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.deepPurple,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  //   onPressed: _submitForm,
                  //   child: const Text('Save',
                  //       style: TextStyle(color: Colors.white)),
                  // ),
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
