import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'navbar.dart'; // Import the NavBar component
import 'footer.dart'; // Import the Footer component
import 'info_page.dart'; // Import InfoPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Image Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CropImageSearch(),
    );
  }
}

class CropData {
  final String name;
  final String imageUrl;

  CropData({required this.name, required this.imageUrl});
}

class CropImageSearch extends StatefulWidget {
  @override
  _CropImageSearchState createState() => _CropImageSearchState();
}

class _CropImageSearchState extends State<CropImageSearch> {
  final TextEditingController _searchController = TextEditingController();
  List<CropData> _cropDataList = [];
  List<CropData> _filteredDataList = [];

  @override
  void initState() {
    super.initState();
    _fetchCropData();
  }

  void _fetchCropData() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/get/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<CropData> cropDataList = [];

        String baseUrl = 'http://127.0.0.1:8000'; // Base URL for image paths

        for (var crop in data) {
          String imageUrl = crop['image']; // Assumed key for image URL
          if (!imageUrl.startsWith('http')) {
            imageUrl = '$baseUrl$imageUrl'; // Ensure full URL
          }
          String cropName = crop['name']; // Assumed key for crop name
          cropDataList.add(CropData(name: cropName, imageUrl: imageUrl));
        }

        setState(() {
          _cropDataList = cropDataList;
          _filteredDataList = List.from(cropDataList);
        });
      } else {
        throw Exception('Failed to load crop data');
      }
    } catch (e) {
      print('Error fetching crop data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: NavBar(
          searchController: _searchController,
          onSearchImage: (imageUrl) {
            // Implement desired behavior for a found image
          },
          onSmartSeederIconPressed: () {
            // Implement desired behavior for the icon press
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Adjust the number of images in a row
                crossAxisSpacing: 10.0, // Consistent spacing between items
               // Consistent spacing between rows
              ),
              itemCount: _filteredDataList.length,
              itemBuilder: (BuildContext context, int index) {
                final crop = _filteredDataList[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to InfoPage, passing the crop name
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InfoPage(cropName: crop.name), 
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: crop.imageUrl.isNotEmpty
                            ? Image.network(
                                crop.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            : Center(
                                child: Text('No Image Available'),
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            crop.name,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 40,
            child: Footer(
              onBackButtonPressed: () {
                // Implement back button behavior
              },
              onHomePageButtonPressed: () {
                // Implement home page behavior
              }
            ),
          ),
        ],
      ),
    );
  }
}
