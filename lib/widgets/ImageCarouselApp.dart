import 'package:difwa_app/config/app_color.dart';
import 'package:flutter/material.dart';

class ImageCarouselPage extends StatefulWidget {
  const ImageCarouselPage({super.key});

  @override
  State<ImageCarouselPage> createState() => _ImageCarouselPageState();
}

class _ImageCarouselPageState extends State<ImageCarouselPage> {
  final List<Map<String, String>> _carouselItems = const [
    {
      'title': 'Freshness Delivered',
      'subtitle': 'Stay cool, stay hydrated',
      'image': 'https://i.ibb.co/XP9x24d/slider8.jpg'
    },
    {
      'title': 'Pure Hydration',
      'subtitle': 'Feel the freshness',
      'image': 'https://i.ibb.co/k2NnMJQc/slider7.jpg'
    },
    {
      'title': 'Health Booster',
      'subtitle': 'Water that energizes',
      'image': 'https://i.ibb.co/SXm5wDsk/slider6.jpg'
    },
    {
      'title': 'Natural Spring',
      'subtitle': 'Straight from nature',
      'image': 'https://i.ibb.co/5xCptbLp/slider3.jpg'
    },
    {
      'title': 'Stay Active',
      'subtitle': 'Hydration fuels performance',
      'image': 'https://i.ibb.co/jPFXbyPp/slider2.jpg'
    },
    {
      'title': 'Cooling Splash',
      'subtitle': 'Beat the heat with purity',
      'image': 'https://i.ibb.co/ccKh4xJ0/slider1.png'
    },
    {
      'title': 'Everyday Freshness',
      'subtitle': 'Feel alive, every sip',
      'image': 'https://i.ibb.co/h1r74h8S/slider4.jpg'
    },
    {
      'title': 'Premium Water',
      'subtitle': 'Subscribe now and get 20% off',
      'image': 'https://i.ibb.co/s9cXgDmF/slider5.jpg'
    },
  ];

  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Carousel slider
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _carouselItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(item['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            AppColors.textBlack.withOpacity(0.9),
                            Colors.transparent
                          ],
                        ),
                      ),
                    ),
                    // Text content
                    Positioned(
                      bottom: 40,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Dots indicator inside the carousel
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _carouselItems.length,
              (index) => buildDot(index),
            ),
          ),
        ),
      ],
    );
  }

  // Dot builder
  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.primary : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
