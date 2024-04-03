import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


import 'nappy.dart';

class NappyDataDetails extends StatefulWidget {
  final String? id;

  const NappyDataDetails({Key? key, this.id}) : super(key: key);

  @override
  _NappyDataDetailsState createState() => _NappyDataDetailsState();
}

class _NappyDataDetailsState extends State<NappyDataDetails> {
  final _formKey = GlobalKey<FormState>();
  final poopDateController = TextEditingController();
  final poopTimeController = TextEditingController();
  final nappyTypeController = TextEditingController();
  final poopImageController = TextEditingController();
  final poopNoteController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final List<String> nappyOption = ['Wet', 'Wet and Dirty'];
  int selectedNappyIndex = 0;
  File? image;


  Future<void> fetchImageFromFirebase(String imageUrl) async {
    try {
      final firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref(imageUrl);
      final String downloadUrl = await ref.getDownloadURL();

      final response = await http.get(Uri.parse(downloadUrl));
      final bytes = response.bodyBytes;

      setState(() {
        image = File('${DateTime.now().millisecondsSinceEpoch}.jpg')
          ..writeAsBytesSync(bytes);
        poopImageController.text = imageUrl.split('/').first;
      });
    } catch (e) {
      print('Failed to fetch image from Firebase Storage: $e');
    }
  }




  Future<void> uploadImageToFirebase() async {
    if (image != null) {
      final String folderName = 'images'; // Update with your desired folder name
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String destination = '$folderName/$fileName';

      try {
        await firebase_storage.FirebaseStorage.instance.ref(destination).putFile(image!);
      } catch (e) {
        print('Failed to upload image to Firebase Storage: $e');
      }

      setState(() {
        poopImageController.text = '$fileName';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    var nappyData = Provider.of<NappyModel>(context, listen: false).get(
        widget.id);
    var adding = nappyData == null;

    if (adding) {
      if (selectedDate == null) {
        selectedDate = DateTime.now();
        poopDateController.text = DateFormat.yMd().format(selectedDate!);
      }
      if (selectedTime == null) {
        selectedTime = TimeOfDay.now();
        poopTimeController.text = selectedTime!.format(context);
      }
      if (nappyTypeController.text.isEmpty) {
        nappyTypeController.text = nappyOption[0];
      }
    }
    if (!adding && selectedDate == null) {
      selectedDate = DateFormat.yMd().parse(nappyData!.poopDate);
      final parsedTime = DateFormat('h:mm a').parse(nappyData!.poopTime);
      selectedTime = TimeOfDay.fromDateTime(parsedTime);
      poopImageController.text = nappyData.poopImage;
      poopNoteController.text = nappyData.poopNote ?? '';
      poopDateController.text = DateFormat.yMd().format(selectedDate!);
      poopTimeController.text = DateFormat('h:mm a').format(parsedTime);
      if (nappyTypeController.text.isEmpty) {
        nappyTypeController.text = nappyData.nappyType;
      }
    }

    if (poopImageController.text.isNotEmpty && image == null) {
      print(poopImageController.text);
      fetchImageFromFirebase(poopImageController.text);
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
          poopDateController.text = DateFormat.yMd().format(selectedDate!);
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
          poopTimeController.text = picked.format(context);
        });
      }
    }

    Future<void> pickImageGallery() async {
      try {
        final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedImage == null) return;

        final pickedImageTemp = File(pickedImage.path);
        setState(() {
          if (image != null) {
            image!.deleteSync(); // Delete the previous image file
          }
          image = pickedImageTemp;
          poopImageController.text = pickedImage.path; // Update the image path in the text controller
        });
      } catch (e) {
        print('Failed to pick image: $e');
      }
    }

    Future<void> pickImageCamera() async {
      try {
        final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedImage == null) return;

        final pickedImageTemp = File(pickedImage.path);
        setState(() {
          if (image != null) {
            image!.deleteSync(); // Delete the previous image file
          }
          image = pickedImageTemp;
          poopImageController.text = pickedImage.path; // Update the image path in the text controller
        });
      } catch (e) {
        print('Failed to pick image: $e');
      }
    }



    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? 'Add Nappy Data' : 'Edit Nappy Data'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: poopDateController,
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                    style: TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Image.asset(
                          'images/calendar.png',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  TextFormField(
                    controller: poopTimeController,
                    readOnly: true,
                    onTap: () {
                      _selectTime(context);
                    },
                    style: TextStyle(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(right: 8.0),
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
                        padding: EdgeInsets.only(right: 8.0),
                        child: Image.asset(
                          'images/poop.png',
                        ),
                      ),
                      Text(
                        'Nappy Type',
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
                          children: nappyOption
                              .map(
                                (option) => Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
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
                            nappyOption.length,
                                (index) =>
                            nappyOption[index] == nappyTypeController.text,
                          ),
                          onPressed: (index) {
                            setState(() {
                              selectedNappyIndex = index;
                              nappyTypeController.text = nappyOption[index];
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          selectedColor: Colors.white,
                          fillColor: Colors.pinkAccent.shade100,
                          borderColor: Colors.grey.shade300,
                          selectedBorderColor: Colors.pinkAccent.shade100,
                          constraints: BoxConstraints(
                              minHeight: 20, minWidth: 100),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      image != null
                          ? Image.file(
                        image!,
                        width: 210,
                        height: 210,
                        fit: BoxFit.cover,
                      )
                          : poopImageController.text.isNotEmpty
                          ? Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/kit721-7ef30.appspot.com/o/images%2F${poopImageController.text}?alt=media',
                        width: 210,
                        height: 210,
                        fit: BoxFit.cover,
                      )
                          : SizedBox(width: 210, height: 210),

                      SizedBox(width: 20),
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: pickImageGallery,
                            icon: Icon(Icons.image_outlined),
                            label: Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: pickImageCamera,
                            icon: Icon(Icons.camera_alt_outlined),
                            label: Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  TextFormField(
                    controller: poopNoteController,
                    decoration: InputDecoration(
                      labelText: 'Note',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Image.asset(
                          'images/summary.png',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final String shareString =
                              "Poop date: " +
                                  poopDateController.text +
                                  " , Poop Time: " +
                                  poopTimeController.text +
                                  " , Nappy Type: " +
                                  nappyTypeController.text +
                                  ", Poop Note: " +
                                  poopNoteController.text +
                                  ", Image Location: " +
                                  poopImageController.text +
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
                          backgroundColor: Colors.pinkAccent.shade100,
                          // Set the background color of the button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            // Set the button's border radius
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                          // Adjust the button's padding
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await uploadImageToFirebase();
                            var newNappyData = Nappy(
                              poopDate: poopDateController.text,
                              poopTime: poopTimeController.text,
                              nappyType: nappyTypeController.text,
                              poopImage: poopImageController.text,
                              poopNote: poopNoteController.text.isEmpty
                                  ? ''
                                  : poopNoteController.text,
                            );

                            if (adding) {
                              await Provider.of<NappyModel>(context, listen: false)
                                  .add(newNappyData);
                            } else {
                              await Provider.of<NappyModel>(context, listen: false)
                                  .updateItem(widget.id!, newNappyData);
                            }
                            print(poopImageController.text);
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
                            borderRadius: BorderRadius.circular(20),
                            // Set the button's border radius
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                          // Adjust the button's padding
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void shareContent(BuildContext context,String shareContent) {
    final String content = shareContent;

    Share.share(content);
  }
}





