import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),

          /// Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerWidget.rectangular(height: 30, width: 100),
          ),
          const SizedBox(height: 10),

          /// Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: const [
                ShimmerWidget.circular(height: 80, width: 80),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget.rectangular(height: 16, width: 120),
                    SizedBox(height: 6),
                    ShimmerWidget.rectangular(height: 14, width: 160),
                    SizedBox(height: 6),
                    ShimmerWidget.rectangular(height: 14, width: 100),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// Profile Options List
          Column(
            children: List.generate(8, (index) {
              return ShimmerWidget.rectangular(
                  height: 60,
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6));
            }),
          ),
        ],
      ),
    );
  }
}

/// Reusable Shimmer Widget
class ShimmerWidget extends StatelessWidget {
  final double height, width;
  final double radius;
  final EdgeInsets? margin;
  final bool isCircular;

  const ShimmerWidget.rectangular({
    super.key,
    required this.height,
    required this.width,
    this.radius = 12,
    this.margin,
  }) : isCircular = false;

  const ShimmerWidget.circular({
    super.key,
    required this.height,
    required this.width,
  })  : radius = height / 2,
        isCircular = true,
        margin = null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}
