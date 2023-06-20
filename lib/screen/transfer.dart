import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransferPage extends StatefulWidget {
  final String friendName;
  final double debtAmount;
  final String roomName;

  TransferPage({
    required this.friendName,
    required this.debtAmount,
    required this.roomName,
  });

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imageFile;

  Future<void> _uploadReceipt() async {
    if (_imageFile == null) {
      return;
    }

    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('receipt_images/$fileName.jpg');
    final UploadTask uploadTask = storageRef.putFile(File(_imageFile!.path));

    await uploadTask.whenComplete(() async {
      final String receiptUrl = await storageRef.getDownloadURL();

      // Save the receipt data in the 'donePayment' document in the 'debtRoom' collection
      FirebaseFirestore.instance
          .collection('debtRoom')
          .doc(widget.roomName)
          .set(
        {
          'donePayment': {
            'receiptUrl': receiptUrl,
            'friendName': widget.friendName,
            'debtAmount': widget.debtAmount,
          }
        },
        SetOptions(merge: true),
      ).then((_) {
        print('Receipt data saved successfully');
        // Show a success message or perform any other actions
      }).catchError((error) {
        print('Error saving receipt data: $error');
        // Show an error message or handle the error
      });
    });
  }

  Future<void> _takePicture() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer Page'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Friend Name: ${widget.friendName}'),
          Text('Debt Amount: ${widget.debtAmount}'),
          ElevatedButton(
            onPressed: _uploadReceipt,
            child: Text('Send Receipt'),
          ),
          ElevatedButton(
            onPressed: _takePicture,
            child: Text('Take Picture'),
          ),
          if (_imageFile != null) Image.file(File(_imageFile!.path)),
        ],
      ),
    );
  }
}
