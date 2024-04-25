import 'package:flutter/material.dart';
import 'package:smart_seeder/sample.dart';
import 'navbar.dart';
import 'footer.dart';
import 'main.dart';
// Import the new widget for navigation

class InfoPage extends StatelessWidget {
  final String cropName;

  InfoPage({required this.cropName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: NavBar(
          searchController: TextEditingController(),
          onSearchImage: (imageUrl) {
            // Define behavior for search image
          },
          onSmartSeederIconPressed: () {
            // Define behavior for smart seeder icon press
          },
        ),
      ),
      body: Column(
        children: [
          // Display crop information in a table
          DataTable(
            columns: [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text('Value')),
            ],
            rows: [
              DataRow(
                cells: [
                  DataCell(Text('Furrow Depth')),
                  DataCell(Text('20 cm')), // Example value
                ],
              ),
              DataRow(
                cells: [
                  DataCell(Text('Plate Size')),
                  DataCell(Text('15x15 cm')), // Example value
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          // "Start" button with navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to another widget
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnotherWidget()), // Change this to the desired widget
                );
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.green, // Green background
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                padding: const EdgeInsets.all(16), // Padding for the button
                alignment: Alignment.center, // Center the text
                child: Text(
                  'Start', // Button text
                  style: TextStyle(color: Colors.white, fontSize: 16), // White text
                ),
              ),
            ),
          ),
          Spacer(),
          Footer(
            onBackButtonPressed: () {
              Navigator.pop(context);
            },
            onHomePageButtonPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => CropImageSearch()), // Reference to the home page
                (route) => false, // Removes all previous routes
              );
            },
          ),
        ],
      ),
    );
  }
}
