import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final Function() onBackButtonPressed; // Back button callback
  final Function() onHomePageButtonPressed; // Home button callback

  Footer({
    required this.onBackButtonPressed,
    required this.onHomePageButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    bool canGoBack = Navigator.canPop(context); // Check if there's a screen to go back to

    return Container(
      color: Colors.yellow, // Footer background color
      padding: EdgeInsets.only(top: 3.0, bottom: 16.0), // Consistent padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ensure even spacing
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.green), // Back button
            onPressed: canGoBack ? () => Navigator.pop(context) : onBackButtonPressed, // Handle conditionally
            tooltip: canGoBack ? "Back" : "Cannot go back", // Optional tooltip
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.green), // Home button
            onPressed: onHomePageButtonPressed, // Navigate to home
          ),
          IconButton(
            icon: Icon(Icons.info, color: Colors.green), // Info button
            onPressed: () {
              _showAboutDialog(context); // Display the "About" dialog
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context, // Correct context for the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("About This App"), // Dialog title
          content: Text(
            "Version: 1.0\n"
            "Developed by: Your Name\n"
            "Description: This app helps you search for crop images and provides additional information.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
