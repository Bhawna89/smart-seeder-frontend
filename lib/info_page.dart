import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_seeder/main.dart';
import 'package:smart_seeder/sample.dart';
import 'dart:convert';
import 'navbar.dart';
import 'footer.dart';

class InfoPage extends StatefulWidget {
  final String cropName; // Name of the crop
  final int cropId; // ID of the crop to fetch data for

  InfoPage({required this.cropName, required this.cropId});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  late double plateSize = 0.0; // Default value for depth of seed
  bool isLoading = true; // Track loading status

  @override
  void initState() {
    super.initState();
    _fetchDepthOfSeed(); // Fetch the data when the widget is initialized
  }

  Future<void> _fetchDepthOfSeed() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/get_plate/${widget.cropId}/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
       // plateSize = data['depth_of_seed'];
        double value = data['depth_of_seed'];
        String roundedString = value.toStringAsFixed(2);
        double roundedValue = double.parse(roundedString);
         // Round to 2 decimal places
         plateSize = roundedValue;
      //double roundedValue = double.parse(roundedString); Get 'depth_of_seed' from the response
        isLoading = false; // Loading is complete
      });
    } else {
      setState(() {
        isLoading = false; // Stop loading
      });
      throw Exception('Failed to fetch data');
    }
  }

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
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
        children: [
          if (isLoading) 
            Center(child: CircularProgressIndicator()), // Show loading indicator
          if (!isLoading) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Crop Name: ${widget.cropName}', // Display the crop name
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            DataTable(
              columns: [
                DataColumn(label: Text('Parameter')),
                DataColumn(label: Text('Value (In mm)')),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(Text('Seed Depth')), // Label as "Plate Size"
                    DataCell(Text(plateSize.toString())), // Display fetched value
                  ],
                ),
              ],
            ),
          ],
          SizedBox(height: 10),
          // "Start" button with navigation
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnotherWidget()), // Change to desired widget
                );
              },
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Text(
                  'Start', // Button text
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          Spacer(), // Ensure footer is at the bottom
          Footer(
            onBackButtonPressed: () {
              Navigator.pop(context);
            },
            onHomePageButtonPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
    );
  }
}
