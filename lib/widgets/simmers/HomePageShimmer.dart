import 'package:difwa_app/widgets/simmers/ButtonShimmer.dart';
import 'package:difwa_app/widgets/simmers/CustomAppbarShimmer.dart';
import 'package:difwa_app/widgets/simmers/ImageCarouselShimmer.dart';
import 'package:difwa_app/widgets/simmers/OrderDetailsShimmer.dart';
import 'package:difwa_app/widgets/simmers/PackageSelectorShimmer%20.dart';
import 'package:flutter/material.dart';

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomAppbarShimmer()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              // Image Carousel Shimmer
              SizedBox(
                height: screenHeight * 0.20,
                child: const ImageCarouselShimmer(),
              ),
              const SizedBox(height: 10),

              // Package Selector Shimmer
              const PackageSelectorShimmer(),
              const SizedBox(height: 16),

              // Order Details Shimmer
              const OrderDetailsShimmer(),
              const SizedBox(height: 20),

              // Order Now Button Shimmer
              const ButtonShimmer(),
              const SizedBox(height: 4),

              // Subscribe Now Button Shimmer
              const ButtonShimmer(),
            ],
          ),
        ),
      ),
    );
  }
}
