import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final String roomName;
  final String friendName;

  const ReportDialog({
    required this.roomName,
    required this.friendName,
  });

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReason;
  String? optionalReason;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedReason,
            hint: Text('Reason'),
            onChanged: (value) {
              setState(() {
                selectedReason = value;
              });
            },
            items: [
              DropdownMenuItem(
                value: 'Reason 1',
                child: Text('Added in the wrong Room.'),
              ),
              DropdownMenuItem(
                value: 'Reason 2',
                child: Text('Wrong amount of debt.'),
              ),
              DropdownMenuItem(
                value: 'Reason 3',
                child: Text('others.'),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Optional',
            ),
            onChanged: (value) {
              optionalReason = value;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.red,
          ),
          child: Text('Send Report'),
          onPressed: () {
            _sendReport();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _sendReport() {
    final report = {
      'friendName': widget.friendName,
      'roomName': widget.roomName,
      'reason': selectedReason,
      'optionalReason': optionalReason,
    };

    FirebaseFirestore.instance.collection('debtRoom').doc(widget.roomName).set({
      'reports': [report]
    }, SetOptions(merge: true)).then((value) {
      // Report sent successfully
      print('Report sent successfully!');
    }).catchError((error) {
      // Error occurred while sending the report
      print('Error sending report: $error');
    });
  }
}
