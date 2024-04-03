import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';

import 'feed.dart';

class FeedDetails extends StatefulWidget {
  final String? id;

  const FeedDetails({Key? key, this.id}) : super(key: key);

  @override
  _FeedDetailsState createState() => _FeedDetailsState();
}

class _FeedDetailsState extends State<FeedDetails> {
  final _formKey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final durationController = TextEditingController();
  final milkTypeController = TextEditingController();
  final sideController = TextEditingController();
  final startTimeController = TextEditingController();
  final quantityController = TextEditingController();
  final noteController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final List<String> milkTypeOptions = ['Bottle Milk', 'Mothers Milk'];
  int selectedMilkTypeIndex = 0;
  final List<String> feedSideOptions = ['Left Side', 'Right Side'];
  int selectedFeedSideIndex = 0;

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
          durationController.text = formatDuration(_seconds);
        });
      });
      _isTimerRunning = true;
    }
    setState(() {}); // Update the button label
  }

  String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String formattedDuration = duration.toString().split('.').first;
    return formattedDuration;
  }

  @override
  Widget build(BuildContext context) {
    var feed = Provider.of<FeedModel>(context, listen: false).get(widget.id);
    var adding = feed == null;

    if (adding) {
      if (selectedDate == null) {
        selectedDate = DateTime.now();
        dateController.text = DateFormat.yMd().format(selectedDate!);
      }
      if (selectedTime == null) {
        selectedTime = TimeOfDay.now();
        startTimeController.text = selectedTime!.format(context);
      }
      if (durationController.text.isEmpty) {
        durationController.text = "0:00:00";
      }
    }

    if (!adding && selectedDate == null) {
      selectedDate = DateFormat.yMd().parse(feed.feedDate);
      dateController.text = DateFormat.yMd().format(selectedDate!);
      final parsedTime = DateFormat('h:mm a').parse(feed.feedStartTime);
      selectedTime = TimeOfDay.fromDateTime(parsedTime);
      startTimeController.text = DateFormat('h:mm a').format(parsedTime);
      milkTypeController.text = feed.milkType;
      sideController.text = feed.feedSide;
      durationController.text = feed.feedDuration;
      quantityController.text = feed.quantity;
      noteController.text = feed.feedNote!;
      if(durationController.text == ""){
        durationController.text = "0:00:00";
      }
    }

    if (adding && milkTypeController.text.isEmpty) {
      milkTypeController.text = milkTypeOptions[0];
    }

    if (adding && sideController.text.isEmpty) {
      sideController.text = feedSideOptions[0];
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
          dateController.text = DateFormat.yMd().format(picked);
        });
      }
    }

    Future<void> _selectTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );
      if (picked != null && picked != selectedTime) {
        setState(() {
          selectedTime = picked;
          startTimeController.text = picked.format(context);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? 'Add Feed' : 'Edit Feed'),
      ),
      body: SingleChildScrollView(
          child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                    TextFormField(
                      controller: dateController,
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
                    SizedBox(height: 20),
                    TextFormField(
                      controller: startTimeController,
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
                    SizedBox(height: 20),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8.0), // Adjust the right padding as needed
                        child: Image.asset(
                          'images/feedingbottle.png',
                        ),
                      ),
                      Text(
                        'Milk Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 30),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade100,
                        ),
                        child: ToggleButtons(
                          children: milkTypeOptions
                              .map(
                                (option) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                              .toList(),
                          isSelected: List.generate(
                            milkTypeOptions.length,
                                (index) => milkTypeOptions[index] == milkTypeController.text,
                          ),
                          onPressed: (index) {
                            setState(() {
                              selectedMilkTypeIndex = index;
                              milkTypeController.text = milkTypeOptions[index];
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          selectedColor: Colors.white,
                          fillColor: Colors.pinkAccent.shade100,
                          borderColor: Colors.transparent,
                          selectedBorderColor: Colors.pinkAccent.shade100,
                          constraints: BoxConstraints(minHeight: 30, minWidth: 80),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0), // Adjust the right padding as needed
                          child: Image.asset(
                            'images/breastfeeding.png',
                          ),
                        ),
                        Text(
                          'Feed Side',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 30),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade200,
                          ),
                          child: ToggleButtons(
                            children: feedSideOptions
                                .map(
                                  (option) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            )
                                .toList(),
                            isSelected: List.generate(
                              feedSideOptions.length,
                                  (index) => feedSideOptions[index] == sideController.text,
                            ),
                            onPressed: (index) {
                              setState(() {
                                selectedFeedSideIndex = index;
                                sideController.text = feedSideOptions[index];
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            selectedColor: Colors.white,
                            fillColor: Colors.pinkAccent.shade100,
                            borderColor: Colors.transparent,
                            selectedBorderColor: Colors.pinkAccent.shade100,
                            constraints: BoxConstraints(minHeight: 20, minWidth: 80),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
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
                              durationController.text,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    SizedBox(height: 20),
                    TextFormField(
                      controller: quantityController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Quantity',

                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 8.0), // Adjust the right padding as needed
                          child: Image.asset(
                            'images/measure.png',
                            width: 27,
                            height: 27,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Note',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 8.0), // Adjust the right padding as needed
                          child: Image.asset(
                            'images/summary.png',
                          ),
                        ),
                      ),
                      controller: noteController,
                    ),
                    SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final String shareString = "Feed date = " + dateController.text + " , Feed Time: " ;
                      shareContent(context,shareString);
                    },
                    icon: Icon(Icons.save, color: Colors.white),
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
                        if (_formKey.currentState?.validate() ?? false) {
                          if (adding) {
                            feed = Feed(
                              feedDate: '',
                              feedDuration: '',
                              milkType: '',
                              feedSide: '',
                              feedStartTime: '',
                              quantity: '',
                              feedNote: '',
                            );
                          }

                          feed!.feedDate = dateController.text;
                          feed!.feedStartTime = startTimeController.text;
                          feed!.milkType = milkTypeController.text;
                          feed!.feedSide = sideController.text;
                          feed!.quantity = quantityController.text;
                          feed!.feedDuration = durationController.text;
                          feed!.feedNote = noteController.text.isEmpty ? '' : noteController.text;
                          feed!.quantity = quantityController.text;

                          if (adding) {
                            await Provider.of<FeedModel>(context, listen: false).add(feed!);
                          } else {
                            await Provider.of<FeedModel>(context, listen: false).updateItem(widget.id!, feed!);
                          }

                          print(feed.toString());
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
                    )
                  ]
              )
                  ],
                ),
              ),
            ),
        ),
      ));
  }

  void shareContent(BuildContext context,String shareContent) {
    final String content = shareContent; // Replace with your actual content

    Share.share(content);
  }
}
