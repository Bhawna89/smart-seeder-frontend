import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final Function() onBackButtonPressed;
  final Function() onHomePageButtonPressed;

  Footer({
    required this.onBackButtonPressed,
    required this.onHomePageButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      padding: EdgeInsets.only(top: 3.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.green),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                onBackButtonPressed();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.green),
            onPressed: onHomePageButtonPressed,
          ),
          IconButton(
            icon: Icon(Icons.info, color: Colors.green),
            onPressed: () {
              _showAboutDialog(context); // Correct context to ensure dialog appears
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context, // Using the correct context
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("About This App"),
          content: Text(
            "Version: 1.0\n"
            "Developed by: Your Name\n"
            "Description: This app helps you search for crop images and provides additional information. "
            "It is designed to be user-friendly and efficient.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
