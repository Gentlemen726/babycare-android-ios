import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'sleep.dart';

class SleepDetails extends StatefulWidget {
  final String? id;

  const SleepDetails({Key? key, this.id}) : super(key: key);

  @override
  _SleepDetailsState createState() => _SleepDetailsState();
}

class _SleepDetailsState extends State<SleepDetails> {
  final _formKey = GlobalKey<FormState>();
  final sleepDateController = TextEditingController();
  final sleepStartTimeController = TextEditingController();
  final sleepEndTimeController = TextEditingController();
  final sleepDurationController = TextEditingController();
  final sleepNoteController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      _isTimerRunning = false;
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
          sleepDurationController.text = formatDuration(_seconds);
        });
      });
      _isTimerRunning = true;
    }
    setState(() {});
  }

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String formattedDuration = duration.toString().split('.').first;
    return formattedDuration;
  }

  @override
  Widget build(BuildContext context) {
    var sleep = Provider.of<SleepModal>(context, listen: false).get(widget.id);
    var adding = sleep == null;

    if (adding) {
      if (selectedDate == null) {
        selectedDate = DateTime.now();
        sleepDateController.text = DateFormat.yMd().format(selectedDate!);
      }
      if (selectedStartTime == null) {
        selectedStartTime = TimeOfDay.now();
        sleepStartTimeController.text = selectedStartTime!.format(context);
      }
      if (selectedEndTime == null) {
        selectedEndTime = TimeOfDay.now();
        sleepEndTimeController.text = selectedEndTime!.format(context);
      }
      if (sleepDurationController.text.isEmpty) {
        sleepDurationController.text = "0:00:00";
      }
    }

    if (!adding && selectedDate == null) {
      selectedDate = DateFormat.yMd().parse(sleep.date);
      sleepDateController.text = DateFormat.yMd().format(selectedDate!);
      final parsedStartTime = DateFormat('h:mm a').parse(sleep.sleepStart);
      selectedStartTime = TimeOfDay.fromDateTime(parsedStartTime);
      sleepStartTimeController.text = DateFormat('h:mm a').format(parsedStartTime);
      final parsedEndTime = DateFormat('h:mm a').parse(sleep.sleepEnd);
      selectedEndTime = TimeOfDay.fromDateTime(parsedEndTime);
      sleepEndTimeController.text = DateFormat('h:mm a').format(parsedEndTime);
      sleepDurationController.text = sleep.sleepDuration;
      sleepNoteController.text = sleep.sleepNote!;
      if (sleepDurationController.text == "") {
        sleepDurationController.text = "0:00:00";
      }
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2024),
      );
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          sleepDateController.text = DateFormat.yMd().format(picked);
        });
      }
    }

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedStartTime ?? TimeOfDay.now(),
      );
      if (picked != null && picked != selectedStartTime) {
        setState(() {
          selectedStartTime = picked;
          sleepStartTimeController.text = picked.format(context);
        });
      }
    }
    Future<void> _selectEndTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedEndTime ?? TimeOfDay.now(),
      );
      if (picked != null && picked != selectedEndTime) {
        setState(() {
          selectedEndTime = picked;
          sleepEndTimeController.text = picked.format(context);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? 'Add Sleep' : 'Edit Sleep'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: sleepDateController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                      style: TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 8.0), // Adjust the right padding as needed
                          child: Image.asset(
                            'images/calendar.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    TextFormField(
                      controller: sleepStartTimeController,
                      readOnly: true,
                      onTap: () {
                        _selectTime(context);
                      },
                      style: TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 8.0), // Adjust the right padding as needed
                          child: Image.asset(
                            'images/chronometer.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    TextFormField(
                      controller: sleepEndTimeController,
                      readOnly: true,
                      onTap: () {
                        _selectEndTime(context);
                      },
                      style: TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 8.0), // Adjust the right padding as needed
                          child: Image.asset(
                            'images/chronometer.png',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0), // Adjust the right padding as needed
                          child: Image.asset(
                            'images/duration.png',
                          ),
                        ),
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 35),
                        Text(
                          sleepDurationController.text,
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(width: 35),
                        ElevatedButton(
                          onPressed: _toggleTimer,
                          child: Text(_isTimerRunning ? 'Stop' : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent, // Set the background color of the button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // Set the button's border radius
                            ),
                        ),)
                      ],
                    ),
                    SizedBox(height: 25),
                    TextFormField(
                      controller: sleepNoteController,
                      decoration: InputDecoration(
                          labelText: 'Note',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Image.asset(
                              'images/summary.png',
                            ),
                          )
                    )
                    ),
                    SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final String shareString = "Sleep date: " + sleepDateController.text + ", Sleep Start Time: " + sleepStartTimeController.text + " , Sleep End Time: " + sleepEndTimeController.text
                            + " , Sleep Duration: " + sleepDurationController.text + ", Sleep Note: " + sleepNoteController.text + ".";
                        shareContent(context,shareString);
                      },
                      icon: Icon(Icons.ios_share, color: Colors.white),
                      label: Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent.shade100, // Set the background color of the button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Set the button's border radius
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25), // Adjust the button's padding
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_isTimerRunning) {
                          _toggleTimer(); // Stop the timer if running
                        }
                        if (_formKey.currentState?.validate() ?? false) {
                          var newSleep = Sleep(
                            date: sleepDateController.text,
                            sleepStart: sleepStartTimeController.text,
                            sleepEnd: sleepEndTimeController.text,
                            sleepDuration: sleepDurationController.text,
                            sleepNote: sleepNoteController.text.isEmpty ? '' : sleepNoteController.text,
                          );

                          if (adding) {
                            await Provider.of<SleepModal>(context, listen: false)
                                .add(newSleep);
                          } else {
                            await Provider.of<SleepModal>(context, listen: false)
                                .updateItem(widget.id!, newSleep);
                          }

                          print(newSleep);
                          Navigator.pop(context);
                        }
                      },

                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700, // Set the background color of the button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Set the button's border radius
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25), // Adjust the button's padding
                      ),
                    ),
                  ]
                ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void shareContent(BuildContext context,String shareContent) {
    final String content = shareContent;

    Share.share(content);
  }
}
