import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ByteData>(
      future: rootBundle.load('assets/images/duck.gif'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the Future is still running, display a loading indicator
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Handle any errors that occurred during loading
          return Center(
            child: Text('Error loading GIF'),
          );
        } else {
          // If the Future is complete, create the Image widget
          final image = Image.memory(Uint8List.view(snapshot.data!.buffer));
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                image,
                SizedBox(height: 20.0),
                CircularProgressIndicator(), // You can add other loading indicators or text here
              ],
            ),
          );
        }
      },
    );
  }
}
