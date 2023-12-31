import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransferPage extends StatefulWidget {
  final String friendName;
  final double debtAmount;
  final String roomName;
  final String roomMaster;
  // final List<dynamic> bankAccounts;

  TransferPage({
    required this.friendName,
    required this.debtAmount,
    required this.roomName,
    required this.roomMaster,
    // required this.bankAccounts,
  });

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _imageFile;
  bool _isImageSelected = false;

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

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

      // Save the receipt data in the 'Payment' document in the 'debtRoom' collection
      FirebaseFirestore.instance
          .collection('debtRoom')
          .doc(widget.roomName)
          .set(
        {
          'Payment': {
            'receiptUrl': receiptUrl,
            'friendName': widget.friendName,
            'debtAmount': widget.debtAmount,
            'option': "Online Transfer",
          }
        },
        SetOptions(merge: true),
      ).then((_) {
        print('Receipt data saved successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt uploaded successfully')),
        );
        setState(() {
          _isImageSelected = false; // Reset image selection
        });
      }).catchError((error) {
        print('Error saving receipt data: $error');
        // Show an error message or handle the error
      });
    });
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = image;
      _isImageSelected = true;
    });
  }

  Future<void> _takePicture() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _imageFile = image;
      _isImageSelected = true;
    });
  }

  Future<List<dynamic>> fetchBankAccounts() async {
    final roomMaster = widget.roomMaster;
    print(' Room Master Username:$roomMaster');
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bankInformation')
          .doc(roomMaster)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        final bankAccounts = data?['bankAccounts'] as List<dynamic>;

        // Convert the list of dynamic to List<Map<String, dynamic>>
        final bankAccountList = bankAccounts
            .map((account) => account as Map<String, dynamic>)
            .toList();

        return bankAccountList;
      }
    } catch (error) {
      print('Error fetching bank accounts: $error');
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<List<dynamic>>(
                stream: Stream.fromFuture(fetchBankAccounts()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Loading indicator while fetching data
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final bankAccounts = snapshot.data ?? [];

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: bankAccounts.length,
                      separatorBuilder: (context, index) =>
                          Divider(), // Add a divider between items
                      itemBuilder: (context, index) {
                        final account = bankAccounts[index];
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Bank Name: ${account['bankName']}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(' ${account['accountNumber']}'),
                                IconButton(
                                  icon: Icon(Icons.copy),
                                  onPressed: () {
                                    _copyToClipboard(account['accountNumber']);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Container(
              width: 200,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _isImageSelected
                  ? Image.file(File(_imageFile!.path))
                  : Center(child: Text('No image selected')),
            ),
            SizedBox(height: 16),
            if (!_isImageSelected)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Select Image'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _takePicture,
                    child: Text('Take Picture'),
                  ),
                ],
              ),
            SizedBox(height: 16),
            if (_isImageSelected)
              ElevatedButton(
                onPressed: _uploadReceipt,
                child: Text('Upload Receipt'),
              ),
          ],
        ),
      ),
    );
  }
}
