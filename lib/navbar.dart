import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_seeder/info_page.dart';
import 'dart:convert';
import 'footer.dart';
import 'navbar.dart';

class NavBar extends StatelessWidget {
  final Function(String) onSearchImage;
  final Function() onSmartSeederIconPressed;
  final TextEditingController searchController;

  NavBar({
    required this.onSearchImage,
    required this.onSmartSeederIconPressed,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.yellow,
      elevation: 0,
      titleSpacing: 0,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // IconButton(
          //   icon: Icon(Icons.agriculture, size: 40),
          //   color: Colors.green,
          //   onPressed: onSmartSeederIconPressed,
          // ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              color: Colors.white,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for crops...',
                  border: InputBorder.none,
                ),
                onSubmitted: (query) => _search(context, query),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.green,
            child: TextButton(
              onPressed: () {
                _search(context, searchController.text);
              },
              child: Text(
                'Search',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _search(BuildContext context, String query) async {
    if (query.isNotEmpty) {
      try {
        String url = 'http://127.0.0.1:8000/api/get/';

        var response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          var results = data as List<dynamic>;

          var foundCrop = results.firstWhere(
            (crop) => crop['name'].toLowerCase() == query.toLowerCase(),
            orElse: () => null,
          );

          if (foundCrop != null) {
            String imageUrl = 'http://127.0.0.1:8000${foundCrop['image']}';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageScreen(imageUrl: imageUrl, cropName: foundCrop['name']),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No image found for "$query"')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching images')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}




class ImageScreen extends StatelessWidget {
  final String imageUrl;
  final String cropName;

  const ImageScreen({
    Key? key,
    required this.imageUrl,
    required this.cropName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double cardHeight = 200.0; // Height of the small card
    double cardWidth = 150.0;  // Width of the small card

    return Scaffold(
      body: Column(
        children: [
          NavBar(
            searchController: TextEditingController(),
            onSearchImage: (imageUrl) {
              // Implement desired behavior for a found image
            },
            onSmartSeederIconPressed: () {
              // Implement desired behavior for the icon press
            },
          ),
          Expanded(
            child: Stack( // Using Stack to position the card in the top-left corner
              children: [
                Align(
                  alignment: Alignment.topLeft, // Place the card in the top-left corner
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to InfoPage when the card is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfoPage(cropName: cropName),
                        ),
                      );
                    },
                    child: Container(
                      width: cardWidth, // Constrain the width
                      height: cardHeight, // Constrain the height
                      child: Card(
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover, // Ensure image fills the space
                                    width: double.infinity, // Stretch to full width
                                  )
                                : Center(
                                    child: Text('No Image Available'),
                                  ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                cropName,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
