import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stack_wealth_news/core/extentions/context_extensions.dart'; 

class NewsListItemShimmer extends StatelessWidget {
  const NewsListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final double imageWidth = context.width * 0.35;
    final double imageHeight = context.height * 0.22; 

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Shimmer Image Placeholder
            Container(
              height: imageHeight,
              width: imageWidth,
              decoration: BoxDecoration(
                color: Colors.white, /// Base color for shimmer container
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            /// Shimmer Text Placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Meta row placeholder
                  Row(children: [
                    Container(height: 20, width: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(height: 10, width: context.width * 0.2, color: Colors.white),
                    const Spacer(),
                    Container(height: 10, width: context.width * 0.1, color: Colors.white),
                  ]),
                  const SizedBox(height: 8),
                  /// Title lines
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  /// Description lines
                  Container(height: 12, width: context.width * 0.5, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 12, width: context.width * 0.4, color: Colors.white),
                  const SizedBox(height: 10),
                  /// Source chip placeholder
                  Container(height: 20, width: context.width * 0.25, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}