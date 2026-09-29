import 'package:flutter/material.dart';

/// Network photo with loading and error placeholders.
/// [heroTag] enables the shared-image route transition.
class RestaurantImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final String? heroTag;

  const RestaurantImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colours = Theme.of(context).colorScheme;

    final Widget image = Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,

      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          height: height,
          color: colours.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator()),
        );
      },

      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: colours.surfaceContainerHighest,
          child: Icon(
            Icons.restaurant,
            size: 40,
            color: colours.onSurfaceVariant,
          ),
        );
      },
    );

    if (heroTag == null) {
      return image;
    }

    return Hero(tag: heroTag!, child: image);
  }
}
