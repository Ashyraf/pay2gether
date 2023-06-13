import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> uploadImageToFirebaseStorage(File imageFile) async {
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();

  Reference storageRef = _storage.ref().child('images/$fileName');
  UploadTask uploadTask = storageRef.putFile(imageFile);

  TaskSnapshot storageSnapshot = await uploadTask;

  String downloadURL = await storageSnapshot.ref.getDownloadURL();

  // Store the download URL in Firestore
  await _firestore.collection('images').add({
    'url': downloadURL,
    'fileName': fileName,
    // Other metadata or fields you want to store
  });
}
