import 'package:flutter/material.dart';

class HeroLayoutCard extends StatelessWidget {
  final ImageInfo imageInfo;

  const HeroLayoutCard({super.key, required this.imageInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 5.0,
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              imageInfo.url,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          // Text Overlays
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imageInfo.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  imageInfo.subtitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/models/image_info.dart
enum ImageInfo {
  image0('The Flow', 'Sponsored | Season 1 Now Streaming',
      'assets/images/water.jpg'),
  image1('Through the Pane', 'Sponsored | Season 1 Now Streaming',
      'assets/images/water.jpg'),
  image2('Iridescence', 'Sponsored | Season 1 Now Streaming',
      'assets/images/water.jpg'),
  image3('Sea Change', 'Sponsored | Season 1 Now Streaming',
      'assets/images/water.jpg'),
  image4('Blue Symphony', 'Sponsored | Season 1 Now Streaming',
      'assets/images/water.jpg'),
  image5('When It Rains', 'Sponsored | Season 1 Now Streaming',
      'assets/images/water.jpg');

  const ImageInfo(this.title, this.subtitle, this.url);
  final String title;
  final String subtitle;
  final String url;
}
