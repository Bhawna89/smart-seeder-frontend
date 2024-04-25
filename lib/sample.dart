import 'package:flutter/material.dart';
import 'package:smart_seeder/main.dart';
import 'navbar.dart'; // Assuming NavBar is in the same directory
import 'footer.dart'; // Assuming Footer is in the same directory

class AnotherWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: NavBar(
          searchController: TextEditingController(), // If needed for NavBar
          onSearchImage: (imageUrl) {
            // Implement search behavior
          },
          onSmartSeederIconPressed: () {
            // Implement behavior for smart seeder icon
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Welcome to the New Widget', // This text can be customized
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Example content: a simple button with a message
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Button Pressed!')),
                );
              },
              child: Text('Press Me'),
            ),
          ),
          Footer(
            onBackButtonPressed: () {
              Navigator.pop(context); // Return to the previous page
            },
            onHomePageButtonPressed: () {
              // Navigate to the home page
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => CropImageSearch()), // Reference to home page
                (route) => false, // Clears all other routes
              );
            },
          ),
        ],
      ),
    );
  }
}
