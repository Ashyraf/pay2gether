import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetupPage extends StatefulWidget {
  final String roomName;
  final String friendName;

  MeetupPage({
    required this.roomName,
    required this.friendName,
  });

  @override
  _MeetupPageState createState() => _MeetupPageState();
}

class _MeetupPageState extends State<MeetupPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController locationController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _saveMeetupData() {
    if (selectedDate != null && selectedTime != null) {
      final meetUpData = {
        'date': selectedDate,
        'time': selectedTime!.format(context),
        'location': locationController.text,
        'friendName': widget.friendName,
        'option': "Meet Up",
      };

      FirebaseFirestore.instance
          .collection('debtRoom')
          .doc(widget.roomName)
          .set({'meetUp': meetUpData}, SetOptions(merge: true)).then((_) {
        print('Meetup data saved successfully');
        // Show a success message or perform any other actions
      }).catchError((error) {
        print('Error saving meetup data: $error');
        // Show an error message or handle the error
      });
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meetup Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                _selectDate(context);
              },
              child: Text('Select Date'),
            ),
            SizedBox(height: 16.0),
            if (selectedDate != null)
              Text('Selected Date: ${selectedDate.toString()}'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _selectTime(context);
              },
              child: Text('Select Time'),
            ),
            SizedBox(height: 16.0),
            if (selectedTime != null)
              Text('Selected Time: ${selectedTime.toString()}'),
            SizedBox(height: 16.0),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveMeetupData,
              child: Text('Meetup'),
            ),
          ],
        ),
      ),
    );
  }
}
