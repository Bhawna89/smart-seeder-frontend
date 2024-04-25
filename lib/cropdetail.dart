// crop_detail_page.dart
import 'package:flutter/material.dart';

class CropDetailPage extends StatelessWidget {
  final String cropName;

  CropDetailPage({required this.cropName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$cropName Details'),
      ),
      body: Center(
        child: Text('Details about $cropName will go here.'),
      ),
    );
  }
}
