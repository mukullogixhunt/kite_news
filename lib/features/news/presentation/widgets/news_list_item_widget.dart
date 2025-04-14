import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stack_wealth_news/core/constants/media_constants.dart'; // Adjust if needed
import 'package:stack_wealth_news/core/extentions/context_extensions.dart';
import 'package:stack_wealth_news/core/utlis/common_helpers.dart'; // Your time formatter
import 'package:stack_wealth_news/features/news/domain/entities/article_entity.dart';

class NewsListItemWidget extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;
  final int itemIndex;

  const NewsListItemWidget({
    super.key,
    required this.article,
    required this.onTap,
    required this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
    final double imageWidth = context.width * 0.35;
    final double imageHeight = context.height * 0.22; // Or fixed: const double imageHeight = 155;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// --- Left Image ---
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                height: imageHeight,
                width: imageWidth,
                imageUrl: article.urlToImage ?? '', // Handle null URL
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: imageHeight,
                    width: imageWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: imageHeight,
                  width: imageWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// --- Right Content Column ---
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- Top Meta Row (Avatar, Author, Time) ---
                  Row(
                    children: [
                      // Author Avatar (Using placeholder)
                      ClipOval(
                        child: CachedNetworkImage(
                          height: 20,
                          width: 20,
                          // Use itemIndex for placeholder variation
                          imageUrl: "${MediaConstants.baseAvatar}${itemIndex % 100}", // Use your constant
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
                            child: Container(height: 20, width: 20, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(radius: 10, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: 12, color: Colors.grey[400])),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Author Name
                      Expanded(
                        child: Text(
                          article.author?.split(',').first ?? article.source.name,
                          style: context.textTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Timestamp
                      Text(
                        formatTimeAgo(article.publishedAt), // Use helper
                        style: context.textTheme.bodySmall?.copyWith(fontSize: 12, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// --- Title ---
                  Text(
                    article.title,
                    style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 16, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  /// --- Description ---
                  if (article.description != null && article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      style: context.textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 13, height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 8),

                  /// --- Source Chip ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      article.source.name.toUpperCase(),
                      style: context.textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[700], letterSpacing: 0.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}