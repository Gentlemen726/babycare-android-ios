import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'growth.dart';

class GrowthDetails extends StatefulWidget {
  final String? id;

  const GrowthDetails({Key? key, this.id}) : super(key: key);

  @override
  _GrowthDetailsState createState() => _GrowthDetailsState();
}

class _GrowthDetailsState extends State<GrowthDetails> {
  final _formKey = GlobalKey<FormState>();
  final measuredDateController = TextEditingController();
  int selectedFeet = 0;
  int selectedInch = 0;
  DateTime? selectedDate;

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
        measuredDateController.text = DateFormat.yMd().format(selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var growth = Provider.of<GrowthModel>(context, listen: false).get(widget.id);
    var adding = growth == null;

    if (adding) {
      if (selectedDate == null) {
        selectedDate = DateTime.now();
        measuredDateController.text = DateFormat.yMd().format(selectedDate!);
      }
    }

    if (!adding && selectedDate == null) {
      selectedDate = DateFormat.yMd().parse(growth!.measuredDate);
      measuredDateController.text = DateFormat.yMd().format(selectedDate!);
      // Parse the height value to separate feet and inch
      var height = growth!.height.replaceAll(' ', '');
      selectedFeet = int.parse(height.split('ft')[0]);
      selectedInch = int.parse(height.split('in')[0].split('ft')[1]);

      measuredDateController.text = growth.measuredDate;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? 'Add Growth Data' : 'Edit Growth Data'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: measuredDateController,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Height',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<int>(
                    value: selectedFeet,
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          selectedFeet = value;
                        });
                      }
                    },
                    items: List<DropdownMenuItem<int>>.generate(9, (int index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('$index ft'),
                      );
                    }),
                  ),
                  DropdownButton<int>(
                    value: selectedInch,
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          selectedInch = value;
                        });
                      }
                    },
                    items: List<DropdownMenuItem<int>>.generate(12, (int index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('$index in'),
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final String shareString = "Poop date: " +
                          measuredDateController.text +
                          " , Feet : " +
                          selectedFeet.toString() +
                          " , Inch: " +
                          selectedInch.toString() +
                          ".";
                      shareContent(context, shareString);
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
                      if (_formKey.currentState?.validate() ?? false) {
                        var newGrowth = Growth(
                          height: "$selectedFeet ft $selectedInch in",
                          measuredDate: measuredDateController.text,
                        );

                        if (adding) {
                          await Provider.of<GrowthModel>(context, listen: false).add(newGrowth);
                        } else {
                          await Provider.of<GrowthModel>(context, listen: false).updateItem(growth.id, newGrowth);
                        }

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
                      backgroundColor: Colors.greenAccent.shade700,
                      // Set the background color of the button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Set the button's border radius
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25), // Adjust the button's padding
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void shareContent(BuildContext context, String shareContent) {
    final String content = shareContent;

    Share.share(content);
  }
}
